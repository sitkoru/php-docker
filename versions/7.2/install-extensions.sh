#!/bin/bash
set -euxo pipefail
apt-get update
apt-get install -y --no-install-recommends $PHPIZE_DEPS libxml2-dev zlib1g-dev libfreetype6-dev libjpeg-dev libpng-dev libxslt-dev libpq-dev libzip-dev libmemcached-dev libgmp-dev libicu-dev libssl-dev binutils
docker-php-source extract
for extension in "$@"; do
    sh /download-pecl.sh "$extension"
    pecl bundle -d /usr/src/php/ext /tmp/extension.tgz
    docker-php-ext-install -j2 "${extension%-*}"
done
docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
docker-php-ext-install -j2 pdo_pgsql pgsql soap zip xsl opcache pcntl gd bcmath pdo_mysql mysqli gmp exif intl fileinfo
strip --strip-debug "$(php-config --extension-dir)"/*.so
