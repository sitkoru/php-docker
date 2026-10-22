#!/bin/bash
set -euxo pipefail
apt-get update
apt-get install -y --no-install-recommends $PHPIZE_DEPS openssh-server git unzip rsync
case "$PHP_VERSION" in
  7.4.*|8.0.*) xdebug=3.1.6 ;;
  *) xdebug=3.3.2 ;;
esac
pecl install "xdebug-$xdebug" ast-1.1.2
docker-php-ext-enable xdebug ast
apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $PHPIZE_DEPS
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
