#!/bin/sh
set -eu
php /checks/runtime.php
php -i > /tmp/php5-abi-check
grep -qx 'PHP API => 20131106' /tmp/php5-abi-check
grep -qx 'PHP Extension => 20131226' /tmp/php5-abi-check
grep -qx 'Zend Extension => 220131226' /tmp/php5-abi-check
grep -qx 'Thread Safety => disabled' /tmp/php5-abi-check
rm /tmp/php5-abi-check
php-fpm -t
set +e
output=$(php -n -d memory_limit=8M /checks/oom.php 2>&1)
status=$?
set -e
[ "$status" -eq 1 ]
printf '%s\n' "$output" | grep -q 'Allowed memory size'
if printf '%s\n' "$output" | grep -q SHUTDOWN_RAN; then exit 1; fi
echo 'OOM exits without shutdown: OK'
if [ "${PHP_IMAGE_TARGET:-}" = dev ]; then composer --version; fi
