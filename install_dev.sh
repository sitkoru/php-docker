php8pattern="8.*.*"
php5pattern="5.6.*"
php7pattern="7.*.*"
php71pattern="7.1.*"
php73pattern="7.3.*"
php74pattern="7.4.*"
apt update \
    && apt install -y $PHPIZE_DEPS openssh-server git unzip rsync \
    && if [[ $PHP_VERSION =~ $php5pattern ]]; then pecl bundle -d /usr/src/php/ext xdebug-2.5.5; fi \
    && if [[ $PHP_VERSION =~ $php5pattern ]]; then docker-php-ext-install -j$(nproc) xdebug; fi \
    && if [[ $PHP_VERSION =~ $php71pattern ]]; then pecl bundle -d /usr/src/php/ext xdebug-2.9.8; fi \
    && if [[ $PHP_VERSION =~ $php71pattern ]]; then docker-php-ext-install -j$(nproc) xdebug; fi \
    && if [[ $PHP_VERSION =~ $php74pattern ]]; then pecl bundle -d /usr/src/php/ext xdebug-3.1.6; fi \
    && if [[ ! $PHP_VERSION =~ $php5pattern ]] && [[ ! $PHP_VERSION =~ $php71pattern ]] && [[ ! $PHP_VERSION =~ $php74pattern ]]; then pecl bundle -d /usr/src/php/ext xdebug; fi \
    && if [[ ! $PHP_VERSION =~ $php5pattern ]] && [[ ! $PHP_VERSION =~ $php71pattern ]]; then pecl bundle -d /usr/src/php/ext ast; fi \
    && if [[ ! $PHP_VERSION =~ $php5pattern ]] && [[ ! $PHP_VERSION =~ $php71pattern ]]; then docker-php-ext-install -j$(nproc) xdebug ast; fi \
    && apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $PHPIZE_DEPS \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*