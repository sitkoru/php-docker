#!/usr/bin/env python3
"""Проверка готового образа через CLI и настоящий FastCGI-запрос."""
import os
import socket
import struct
import subprocess
import sys
import time
import uuid

image, target = sys.argv[1:]
name = 'php-verify-' + uuid.uuid4().hex[:12]
def docker(*args, **kwargs):
    if args[0] == 'run':
        args = (args[0], '--memory=256m', '--pids-limit=64', *args[1:])
    return subprocess.run(['docker', *args], check=True, text=True, timeout=60, **kwargs)

def record(kind, data):
    return struct.pack('!BBHHBB', 1, kind, 1, len(data), 0, 0) + data

modules = 'bcmath exif gd gmp grpc intl memcache memcached mongodb mysqli pcntl pdo_mysql pdo_pgsql pgsql redis soap sodium xsl zip Zend OPcache'.split()
modules = modules[:-2] + ['Zend OPcache']
if target == 'dev':
    modules += ['xdebug', 'ast']
actual = docker('run', '--rm', image, 'php', '-m', capture_output=True).stdout.splitlines()
assert set(modules) <= set(actual), set(modules) - set(actual)
docker('run', '--rm', image, 'php-fpm', '-t')
if target in ('ssh', 'with-nginx-ssh'):
    docker('run', '--rm', image, 'sh', '-c', 'command -v sshd && command -v rsync')
if target.startswith('with-nginx'):
    docker('run', '--rm', image, 'nginx', '-t')
# EOL backport меняет OOM-семантику; поддерживаемая 8.2 использует другое исправление.
if docker('run', '--rm', image, 'php', '-r', 'echo PHP_MAJOR_VERSION,".",PHP_MINOR_VERSION;', capture_output=True).stdout != '8.2':
    code = open(os.path.join(os.path.dirname(__file__), 'oom.php')).read().replace('<?php', '', 1)
    oom = subprocess.run(['docker', 'run', '--memory=128m', '--pids-limit=32', '--network=none', '--rm', image, 'php', '-d', 'memory_limit=16M', '-r', code], text=True, capture_output=True, timeout=30)
    assert oom.returncode == 1, oom
    assert 'Allowed memory size' in oom.stdout + oom.stderr, oom
    assert 'UNSAFE_SHUTDOWN' not in oom.stdout + oom.stderr, oom
try:
    docker('run', '-d', '--name', name, '-p', '127.0.0.1::9000', image, 'php-fpm')
    docker('exec', name, 'sh', '-c', "printf '%s' '<?php echo \"FPM_OK\";' > /tmp/health.php")
    port = int(docker('port', name, '9000', capture_output=True).stdout.strip().rsplit(':', 1)[1])
    params = {'SCRIPT_FILENAME': '/tmp/health.php', 'REQUEST_METHOD': 'GET', 'SERVER_PROTOCOL': 'HTTP/1.1', 'GATEWAY_INTERFACE': 'CGI/1.1'}
    payload = b''.join(bytes([len(k), len(v)]) + k.encode() + v.encode() for k, v in params.items())
    for attempt in range(20):
        try:
            sock = socket.create_connection(('127.0.0.1', port), timeout=3)
            break
        except OSError:
            if attempt == 19:
                raise
            time.sleep(.25)
    with sock:
        sock.sendall(record(1, struct.pack('!HB5x', 1, 0)) + record(4, payload) + record(4, b'') + record(5, b''))
        response = b''
        while True:
            chunk = sock.recv(65536)
            if not chunk:
                break
            response += chunk
        assert b'FPM_OK' in response, response
finally:
    docker('rm', '-f', name)
print(f'PASS: {image}: CLI, modules, FPM request, target tools')
