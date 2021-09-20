#!/bin/bash
php8pattern="8.*.*"
php5pattern="5.6.*"
php7pattern="7.*.*"
php73pattern="7.3.*"
php74pattern="7.3.*"
apt update && apt install -y \
    libxml2-dev \
    zlib1g-dev \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-tools \
    libpng-dev \
    libxslt-dev \
    libpq-dev \
    libzip-dev \
    libmemcached-dev \
    libgmp-dev \
    binutils \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/ \
    && docker-php-source extract \
    && if [[ $PHP_VERSION =~ $php5pattern ]]; then pecl bundle -d /usr/src/php/ext redis-4.0.0; else pecl bundle -d /usr/src/php/ext redis; fi \
    && docker-php-ext-install -j$(nproc) redis \
    && if [[ ! $PHP_VERSION =~ $php5pattern ]]; then pecl bundle -d /usr/src/php/ext mongodb; fi \
    && if [[ ! $PHP_VERSION =~ $php5pattern ]]; then docker-php-ext-install -j$(nproc) mongodb; fi \
    && if [[ ! $PHP_VERSION =~ $php5pattern ]]; then pecl bundle -d /usr/src/php/ext grpc; fi \
    && if [[ ! $PHP_VERSION =~ $php5pattern ]]; then docker-php-ext-install -j$(nproc) grpc; fi \
    && if [[ $PHP_VERSION =~ $php5pattern ]]; then pecl bundle -d /usr/src/php/ext memcached-2.2.0; else pecl bundle -d /usr/src/php/ext memcached-3.1.5; fi \
    && docker-php-ext-install -j$(nproc) memcached \
    && docker-php-ext-configure gmp \
    && if [[ $PHP_VERSION =~ $php5pattern ]]; then docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/; fi \
    && if [[ $PHP_VERSION =~ $php73pattern ]]; then docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/; fi \
    && if [[ $PHP_VERSION =~ $php74pattern ]]; then docker-php-ext-configure gd --with-freetype --with-jpeg; fi \
    && if [[ $PHP_VERSION =~ $php8pattern ]]; then docker-php-ext-configure gd --with-freetype --with-jpeg; fi \
    && docker-php-ext-install pdo_pgsql pgsql soap zip xsl opcache pcntl gd bcmath pdo_mysql mysqli gmp exif intl fileinfo \
    && if [[ $PHP_VERSION =~ $php5pattern ]]; then docker-php-ext-install mysql; fi \
    && if [[ $PHP_VERSION =~ $php5pattern ]]; then pecl bundle -d /usr/src/php/ext memcache-3.0.8; fi \
    && if [[ $PHP_VERSION =~ $php7pattern ]]; then pecl bundle -d /usr/src/php/ext memcache-4.0.5.2; fi \
    && if [[ $PHP_VERSION =~ $php8pattern ]]; then pecl bundle -d /usr/src/php/ext memcache-8.0; fi \
    && docker-php-ext-install memcache \
    && docker-php-source delete \
    && strip --strip-debug $(php-config --extension-dir)/*.so