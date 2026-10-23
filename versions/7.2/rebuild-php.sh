#!/bin/bash
set -euxo pipefail
apt-get update
apt-get install -y --no-install-recommends $PHPIZE_DEPS libargon2-dev libcurl4-openssl-dev libonig-dev libedit-dev libsodium-dev libsqlite3-dev libssl-dev libxml2-dev zlib1g-dev
configure_options=$(php-config --configure-options)
docker-php-source extract
cd /usr/src/php
for patch_file in /patches/*.patch; do patch -p1 --fuzz=0 < "$patch_file"; done
CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" ./configure $configure_options
make -j2
make install
# Сохраняем исправленные исходники для сборки встроенных расширений и проверки PHPT.
make clean
tar -cJf /usr/src/php.tar.xz --exclude=.git -C /usr/src/php .
printf '%s\n' "debian/e0bcd488d9f8da024d9e1a254113539a846cac6d" > /usr/local/etc/php/security-revision
