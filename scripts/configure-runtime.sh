#!/bin/bash
set -euxo pipefail
apt-get update
apt-get upgrade -y
apt-get install -y bash-completion wget zip msmtp libpng16-16 libjpeg62-turbo libfreetype6 libpq5 libzip4 libxslt1.1 libgmp10 libicu-dev locales libmemcached11 libmemcachedutil2
apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $PHPIZE_DEPS
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
printf 'en_US.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8\n' > /etc/locale.gen
locale-gen ru_RU.UTF-8
printf 'LANGUAGE=ru_RU.UTF-8\nLC_ALL=ru_RU.UTF-8\n' >> /etc/default/locale
echo Europe/Moscow > /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata
rm -f /usr/local/etc/php-fpm.d/www.conf.default /usr/local/etc/php-fpm.d/www.conf
sed -i "s/php_version/$1/g" /usr/local/etc/php-fpm.conf
curl -fsSL https://getmic.ro | bash
mv micro /usr/local/bin/micro
