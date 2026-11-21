FROM debian:trixie-slim AS base

ENV PHP_INI_DIR=/usr/local/etc/php \
    PHPRC=/usr/local/etc/php \
    PHP_INI_SCAN_DIR=:/usr/local/etc/php/conf.d

ARG PHP_BRANCH=7.2
ARG PHP_VERSION=7.2.34
ARG PHP_PACKAGE_VERSION=7.2.34-71+debsuryorg13.1+1

COPY scripts/configure-sury.sh /configure-sury.sh
RUN export DEBIAN_FRONTEND=noninteractive \
    && sh /configure-sury.sh \
    && set -- php${PHP_BRANCH}-fpm=${PHP_PACKAGE_VERSION} php${PHP_BRANCH}-cli=${PHP_PACKAGE_VERSION} \
        php${PHP_BRANCH}-bcmath php${PHP_BRANCH}-curl php${PHP_BRANCH}-gd php${PHP_BRANCH}-gmp \
        php${PHP_BRANCH}-intl php${PHP_BRANCH}-mbstring php${PHP_BRANCH}-memcache php${PHP_BRANCH}-memcached \
        php${PHP_BRANCH}-mysql php${PHP_BRANCH}-pgsql php${PHP_BRANCH}-readline php${PHP_BRANCH}-redis \
        php${PHP_BRANCH}-soap php${PHP_BRANCH}-sqlite3 php${PHP_BRANCH}-xml php${PHP_BRANCH}-zip \
        bash-completion locales micro msmtp wget zip \
    && if [ "$PHP_BRANCH" != 7.2 ]; then set -- "$@" "php$PHP_BRANCH-grpc" "php$PHP_BRANCH-mongodb"; fi \
    && apt-get install -y --no-install-recommends "$@" \
    && rm -rf /var/lib/apt/lists/* /configure-sury.sh \
    && ln -s "/usr/bin/php$PHP_BRANCH" /usr/local/bin/php \
    && ln -s "/usr/sbin/php-fpm$PHP_BRANCH" /usr/local/sbin/php-fpm \
    && ln -sf /usr/local/etc/php-fpm.conf "/etc/php/$PHP_BRANCH/fpm/php-fpm.conf" \
    && printf '%s\n' 'en_US.UTF-8 UTF-8' 'ru_RU.UTF-8 UTF-8' > /etc/locale.gen \
    && locale-gen ru_RU.UTF-8 \
    && ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime \
    && printf '%s\n' Europe/Moscow > /etc/timezone

COPY php-fpm.conf /usr/local/etc/php-fpm.conf
COPY opcache.conf /usr/local/etc/php/conf.d/99-opcache.ini
COPY .bashrc /root/.bashrc
COPY .bashrc /var/www/.bashrc
COPY micro.json /root/.config/micro/settings.json
RUN sed -i "s/php_version/php$PHP_VERSION/g" /usr/local/etc/php-fpm.conf \
    && sed -i '/^zend_extension=/d' /usr/local/etc/php/conf.d/99-opcache.ini
COPY --chmod=755 scripts/php-entrypoint.sh /usr/local/bin/docker-php-entrypoint
ENV PHP_VERSION=$PHP_VERSION
WORKDIR /var/www
EXPOSE 9000
STOPSIGNAL SIGQUIT
ENTRYPOINT ["docker-php-entrypoint"]
CMD ["php-fpm"]

FROM base AS regression
COPY versions/5.6/tests/upload-progress.phpt /checks/upload-progress.phpt
COPY versions/5.6/tests/phpt.sh /checks/phpt.sh
# Архив нужен только для run-tests.php и тестовых данных.
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && test "$PHP_BRANCH" = 7.2 \
    && apt-get install -y --no-install-recommends "php7.2-cgi=$PHP_PACKAGE_VERSION" xz-utils \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL https://www.php.net/distributions/php-7.2.34.tar.xz -o /tmp/php-test-source.tar.xz \
    && echo '409e11bc6a2c18707dfc44bc61c820ddfd81e17481470f3405ee7822d8379903  /tmp/php-test-source.tar.xz' | sha256sum -c - \
    && mkdir -p /usr/src/php \
    && tar -xJf /tmp/php-test-source.tar.xz -C /usr/src/php --strip-components=1 \
        php-7.2.34/run-tests.php php-7.2.34/tests/basic php-7.2.34/ext/session/tests \
    && rm /tmp/php-test-source.tar.xz \
    && TEST_PHP_CGI_EXECUTABLE=/usr/bin/php-cgi7.2 sh /checks/phpt.sh

FROM base AS dev
COPY xdebug.ini /usr/local/etc/php/conf.d/99-xdebug.ini
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends openssh-server git unzip rsync "php$PHP_BRANCH-xdebug" "php$PHP_BRANCH-ast" \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i '/^zend_extension=/d' /usr/local/etc/php/conf.d/99-xdebug.ini \
    && rm -f "/etc/php/$PHP_BRANCH/cli/php.ini" "/etc/php/$PHP_BRANCH/fpm/php.ini" \
    && curl -fsSL https://getcomposer.org/download/2.11.2/composer.phar -o /usr/bin/composer \
    && echo 'dd158c0afd41d15fac89e1b4e47b5d42911fe316c3687cd5edac98319b25d028  /usr/bin/composer' | sha256sum -c - \
    && chmod +x /usr/bin/composer

FROM base AS fpm
COPY php.ini /usr/local/etc/php/

FROM fpm AS ssh
COPY ssh-entrypoint.sh /docker-entrypoint.sh
COPY scripts/install-ssh.sh /install-ssh.sh
RUN bash /install-ssh.sh
CMD ["/docker-entrypoint.sh"]

FROM fpm AS with-nginx
COPY nginx/ /tmp/nginx/
RUN bash /tmp/nginx/install.sh
EXPOSE 80
CMD ["/usr/bin/docker-entrypoint.sh"]

FROM ssh AS with-nginx-ssh
COPY nginx/ /tmp/nginx/
RUN bash /tmp/nginx/install.sh
EXPOSE 80
CMD ["/usr/bin/docker-entrypoint.sh"]
