#!/bin/bash
set -euxo pipefail
apt-get update
apt-get install -y --no-install-recommends $PHPIZE_DEPS libxml2-dev zlib1g-dev libfreetype6-dev libjpeg-dev libpng-dev libxslt-dev libpq-dev libzip-dev libmemcached-dev libgmp-dev libicu-dev binutils
docker-php-source extract
for extension in redis-6.0.2 mongodb-1.20.1 grpc-1.62.0 memcached-3.2.0; do
    pecl bundle -d /usr/src/php/ext "$extension"
    docker-php-ext-install -j2 "${extension%-*}"
done
docker-php-ext-configure gd --with-freetype --with-jpeg
docker-php-ext-install -j2 pdo_pgsql pgsql soap zip xsl opcache pcntl gd bcmath pdo_mysql mysqli gmp exif intl fileinfo
case "$PHP_VERSION" in
  7.4.*) memcache=4.0.5.2 ;;
  *) memcache=8.2 ;;
esac
pecl bundle -d /usr/src/php/ext "memcache-$memcache"
docker-php-ext-install -j2 memcache
strip --strip-debug "$(php-config --extension-dir)"/*.so
