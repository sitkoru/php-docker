php8pattern="8.*.*"
php5pattern="5.6.*"
php7pattern="7.*.*"
php73pattern="7.3.*"
apt update \
    && apt install -y $PHPIZE_DEPS openssh-server git unzip rsync \
    && if [[ $PHP_VERSION =~ $php5pattern ]]; then pecl bundle -d /usr/src/php/ext xdebug-2.5.5; fi \
    && if [[ $PHP_VERSION =~ $php5pattern ]]; then docker-php-ext-install -j$(nproc) xdebug; fi \
    && if [[ ! $PHP_VERSION =~ $php5pattern ]]; then pecl bundle -d /usr/src/php/ext xdebug; fi \
    && if [[ ! $PHP_VERSION =~ $php5pattern ]]; then pecl bundle -d /usr/src/php/ext ast; fi \
    && if [[ ! $PHP_VERSION =~ $php5pattern ]]; then docker-php-ext-install -j$(nproc) xdebug ast; fi \
    && apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $PHPIZE_DEPS \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*