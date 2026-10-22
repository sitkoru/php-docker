#!/bin/bash
set -euxo pipefail
revision=$1
checksum=$2
apt-get update
apt-get install -y --no-install-recommends $PHPIZE_DEPS libargon2-dev libcurl4-openssl-dev libonig-dev libreadline-dev libsodium-dev libsqlite3-dev libssl-dev libxml2-dev zlib1g-dev
curl -fsSL "https://github.com/php/php-src/commit/${revision}.patch" -o /tmp/security.patch
echo "$checksum  /tmp/security.patch" | sha256sum -c -
configure_options=$(php-config --configure-options)
docker-php-source extract
cd /usr/src/php
patch -p1 --fuzz=0 < /tmp/security.patch
CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" ./configure $configure_options
make -j2
make install
# Сохраняем исправленные исходники для сборки встроенных расширений и проверки PHPT.
make clean
tar -cJf /usr/src/php.tar.xz --exclude=.git -C /usr/src/php .
printf '%s\n' "$revision" > /usr/local/etc/php/security-revision
