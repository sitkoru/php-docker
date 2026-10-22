#!/bin/bash
set -euxo pipefail
apt-get update
apt-get install -y --no-install-recommends $PHPIZE_DEPS openssh-server git unzip rsync
for extension in "$@"; do
    sh /download-pecl.sh "$extension"
    pecl install /tmp/extension.tgz
done
docker-php-ext-enable xdebug ast
apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $PHPIZE_DEPS
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
