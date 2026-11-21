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
def docker(*args, detached=False, **kwargs):
    cleanup_name = None
    if args[0] == 'run':
        args = (args[0], '--memory=256m', '--pids-limit=64', *args[1:])
        if '-p' not in args:
            args = (args[0], '--network=none', *args[1:])
        if not detached:
            cleanup_name = 'php-cli-' + uuid.uuid4().hex[:12]
            args = (args[0], '--name', cleanup_name, *args[1:])
    try:
        return subprocess.run(['docker', *args], check=kwargs.pop('check', True), text=True,
                              timeout=kwargs.pop('timeout', 60), **kwargs)
    finally:
        if cleanup_name:
            subprocess.run(['docker', 'rm', '-f', cleanup_name], check=False,
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=10)

def record(kind, data):
    return struct.pack('!BBHHBB', 1, kind, 1, len(data), 0, 0) + data

modules = 'bcmath exif gd gmp grpc intl memcache memcached mongodb mysqli pcntl pdo_mysql pdo_pgsql pgsql redis soap sodium xsl zip'.split() + ['Zend OPcache']
if target == 'dev':
    modules += ['xdebug', 'ast']
version = docker('run', '--rm', image, 'php', '-r', 'echo PHP_MAJOR_VERSION,".",PHP_MINOR_VERSION;', capture_output=True).stdout
if version == '7.2':
    modules = [module for module in modules if module not in ('grpc', 'mongodb')] + ['ftp']
    docker('run', '--rm', image, 'sh', '-ec', '''
        . /etc/os-release
        test "$VERSION_CODENAME" = trixie
        dpkg-query -W -f='${Version}' php7.2-fpm | grep -Eq '^7[.]2[.]34-.*[+]debsuryorg13[.]'
        for tool in cc make phpize phpize7.2; do
            if command -v "$tool" >/dev/null; then
                echo "Unexpected build tool: $tool" >&2
                exit 1
            fi
        done
    ''')
actual = docker('run', '--rm', image, 'php', '-m', capture_output=True).stdout.splitlines()
assert set(modules) <= set(actual), set(modules) - set(actual)
docker('run', '--rm', image, 'php-fpm', '-t')
if target in ('ssh', 'with-nginx-ssh'):
    docker('run', '--rm', image, 'sh', '-c', 'command -v sshd && command -v rsync')
if target.startswith('with-nginx'):
    docker('run', '--rm', image, 'nginx', '-t')
# EOL backport меняет OOM-семантику; поддерживаемая 8.2 использует другое исправление.
if version != '8.2':
    code = open(os.path.join(os.path.dirname(__file__), 'oom.php')).read().replace('<?php', '', 1)
    oom = docker('run', '--rm', image, 'php', '-d', 'memory_limit=16M', '-r', code, check=False, capture_output=True, timeout=30)
    assert oom.returncode == 1, oom
    assert 'Allowed memory size' in oom.stdout + oom.stderr, oom
    assert 'UNSAFE_SHUTDOWN' not in oom.stdout + oom.stderr, oom
try:
    docker('run', '-d', '--name', name, '-p', '127.0.0.1::9000', image, 'php-fpm', detached=True)
    docker('exec', name, 'sh', '-c', "printf '%s' '<?php echo \"FPM_OK\";' > /tmp/health.php")
    port = int(docker('port', name, '9000', capture_output=True).stdout.strip().rsplit(':', 1)[1])
    params = {'SCRIPT_FILENAME': '/tmp/health.php', 'REQUEST_METHOD': 'GET', 'SERVER_PROTOCOL': 'HTTP/1.1', 'GATEWAY_INTERFACE': 'CGI/1.1'}
    payload = b''.join(bytes([len(k), len(v)]) + k.encode() + v.encode() for k, v in params.items())
    response = b''
    for attempt in range(20):
        try:
            with socket.create_connection(('127.0.0.1', port), timeout=3) as sock:
                sock.sendall(record(1, struct.pack('!HB5x', 1, 0)) + record(4, payload) + record(4, b'') + record(5, b''))
                while chunk := sock.recv(65536):
                    response += chunk
        except (ConnectionRefusedError, ConnectionResetError, BrokenPipeError):
            if response or attempt == 19:
                raise
        # Docker может открыть порт на хосте раньше, чем FPM начнёт отвечать.
        if response:
            break
        time.sleep(.25)
    assert b'FPM_OK' in response, response
finally:
    docker('rm', '-f', name)
print(f'PASS: {image}: CLI, modules, FPM request, target tools')
