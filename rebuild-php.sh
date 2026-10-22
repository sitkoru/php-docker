#!/bin/bash
set -euxo pipefail
case "$PHP_VERSION" in
  7.4.33) revision=712e60f9edfd03f0960fc4fc3c2c375f42b90aa2; checksum=5fe57ca6ee96d59b36c6e0ca842843c50884f177bef1e85234cf669b577f5e48 ;;
  8.0.30) revision=82f8f31b16a035c1b67cc253e79f7cc288f4cc20; checksum=534478c973cef6f493605b7af907f639a364912ee92c24598ddae44c3bc72d1c ;;
  8.1.34) revision=1d7dec178a094e6e75b229ce22754045f8c6070a; checksum=c85ad0fddcbff7f2318617eeaa54d271135463b5bf70a01228447e3ed78de96e ;;
  8.2.35) exit 0 ;;
  *) echo "Unsupported PHP_VERSION: $PHP_VERSION" >&2; exit 1 ;;
esac
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
