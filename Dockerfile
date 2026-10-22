ARG PHP_VERSION=8.2.35
ARG DEBIAN_VERSION=bookworm
FROM php:${PHP_VERSION}-fpm-${DEBIAN_VERSION} AS upstream
ARG PHP_VERSION
# Bullseye security перенесён в архив после окончания LTS; подписи APT проверяются.
RUN if [ -f /etc/apt/sources.list ]; then sed -i 's|http://deb.debian.org/debian-security|https://archive.debian.org/debian-security|g' /etc/apt/sources.list; fi

FROM upstream AS build
COPY rebuild-php.sh /rebuild-php.sh
RUN bash /rebuild-php.sh

ENV LANG=C.UTF-8

RUN apt update && apt upgrade -y && apt install -y gnupg

COPY install.sh /install.sh

RUN docker-php-source extract \
    && TEST_PHP_EXECUTABLE=/usr/local/bin/php REPORT_EXIT_STATUS=1 php /usr/src/php/run-tests.php -q /usr/src/php/tests/basic/001.phpt /usr/src/php/ext/session/tests/session_basic1.phpt

RUN PHP_VERSION=${PHP_VERSION} bash /install.sh

FROM upstream AS base

RUN apt update \
    && apt upgrade -y \
    && apt install -y bash-completion wget zip msmtp libpng16-16 libjpeg62-turbo libfreetype6 libpq5 libzip4 libxslt1.1 libgmp10 libicu-dev locales libmemcached11 libmemcachedutil2 \
    && apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $PHPIZE_DEPS \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
RUN echo ru_RU.UTF-8 UTF-8 >> /etc/locale.gen
RUN echo en_US.UTF-8 UTF-8 > /etc/locale.gen \
    && echo ru_RU.UTF-8 UTF-8 >> /etc/locale.gen \
    && locale-gen ru_RU.UTF-8 \
    && echo "LANGUAGE=ru_RU.UTF-8" >> /etc/default/locale \
    && echo "LC_ALL=ru_RU.UTF-8" >> /etc/default/locale

COPY --from=build /usr/local/ /usr/local/

COPY opcache.conf /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

COPY .bashrc /root/.bashrc
COPY .bashrc /var/www/.bashrc

RUN echo Europe/Moscow | tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

RUN rm -f /usr/local/etc/php-fpm.d/www.conf.default && rm -f /usr/local/etc/php-fpm.d/www.conf
COPY php-fpm.conf /usr/local/etc/php-fpm.conf
RUN sed -i "s/php_version/php${PHP_VERSION}/g" /usr/local/etc/php-fpm.conf

RUN curl https://getmic.ro | bash && mv micro /usr/local/bin/micro
COPY micro.json /root/.config/micro/settings.json

WORKDIR /var/www

CMD ["php-fpm"]

FROM base AS dev
ARG PHP_VERSION

COPY install_dev.sh /install_dev.sh

RUN PHP_VERSION=${PHP_VERSION} bash /install_dev.sh

COPY xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin -- --filename=composer

FROM base as fpm 

COPY php.ini /usr/local/etc/php/

FROM fpm as ssh

COPY ssh-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

RUN apt update \
    && apt install -y openssh-server rsync \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /run/sshd
RUN sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config \
    && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config \
    && sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config \
    && sed -i "s/#AuthorizedKeysFile/AuthorizedKeysFile/g" /etc/ssh/sshd_config

CMD ["/docker-entrypoint.sh"]

# NGINX IMAGE

FROM fpm as with-nginx

ADD ./nginx/install.sh install.sh

RUN chmod a+x ./install.sh && ./install.sh

ADD nginx/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/docker-entrypoint.sh

RUN rm -f /etc/nginx/conf.d/*
RUN rm -f /etc/nginx/sites-available/*
RUN rm -f /etc/nginx/sites-enabled/*
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/php.conf /etc/nginx/php.conf
COPY nginx/php_fastcgi.conf /etc/nginx/php_fastcgi.conf

EXPOSE 80

CMD "/usr/bin/docker-entrypoint.sh"

FROM ssh as with-nginx-ssh

ADD ./nginx/install.sh install.sh

RUN chmod a+x ./install.sh && ./install.sh

ADD nginx/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/docker-entrypoint.sh

RUN rm -f /etc/nginx/conf.d/*
RUN rm -f /etc/nginx/sites-available/*
RUN rm -f /etc/nginx/sites-enabled/*
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/php.conf /etc/nginx/php.conf
COPY nginx/php_fastcgi.conf /etc/nginx/php_fastcgi.conf

EXPOSE 80

CMD "/usr/bin/docker-entrypoint.sh"

