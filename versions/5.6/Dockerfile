FROM debian:trixie-slim AS base

ENV LANG=C.UTF-8 \
    PHP_INI_DIR=/usr/local/etc/php \
    PHPRC=/usr/local/etc/php \
    PHP_INI_SCAN_DIR=:/usr/local/etc/php/conf.d

ARG PHP_PACKAGE_VERSION=5.6.40-110+debsuryorg13.1+1
COPY scripts/configure-sury.sh /configure-sury.sh
RUN export DEBIAN_FRONTEND=noninteractive \
    && sh /configure-sury.sh \
    && apt-get install -y --no-install-recommends \
        php5.6-fpm="$PHP_PACKAGE_VERSION" php5.6-cli="$PHP_PACKAGE_VERSION" \
        php5.6-bcmath php5.6-curl php5.6-gd php5.6-intl php5.6-mbstring \
        php5.6-memcache php5.6-memcached php5.6-mysql php5.6-pgsql php5.6-readline \
        php5.6-redis php5.6-soap php5.6-sqlite3 php5.6-xml php5.6-zip \
        bash-completion default-mysql-client locales locales-all tzdata wget zip \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/bin/php5.6 /usr/local/bin/php \
    && ln -s /usr/sbin/php-fpm5.6 /usr/local/sbin/php-fpm \
    && ln -sf /usr/local/etc/php-fpm.conf /etc/php/5.6/fpm/php-fpm.conf \
    && rm /etc/php/5.6/cli/php.ini /etc/php/5.6/fpm/php.ini \
    && phpdismod -v 5.6 exif \
    && locale-gen ru_RU.UTF-8 \
    && update-locale LANG=ru_RU.UTF-8 LANGUAGE=ru_RU.UTF-8 LC_ALL=ru_RU.UTF-8 \
    && ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime \
    && printf '%s\n' Europe/Moscow > /etc/timezone

ENV PHP_VERSION=5.6.40
COPY --chmod=755 scripts/php-entrypoint.sh /usr/local/bin/docker-php-entrypoint
COPY versions/5.6/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY opcache.conf /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
COPY versions/5.6/.bashrc /root/.bashrc
COPY versions/5.6/.bashrc /var/www/.bashrc
RUN sed -i '/^zend_extension=/d' /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && mkdir -p /var/www/html \
    && chown -R www-data:www-data /var/www
WORKDIR /var/www
EXPOSE 9000
ENTRYPOINT ["docker-php-entrypoint"]
CMD ["php-fpm"]

FROM base AS dev
COPY versions/5.6/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends openssh-client git unzip rsync php5.6-xdebug \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i '/^zend_extension=/d' /usr/local/etc/php/conf.d/xdebug.ini \
    && curl -fsSL https://getcomposer.org/download/2.2.32/composer.phar -o /usr/bin/composer \
    && echo '241a3d13b7c6d35d970b1f69a000298b66943541302148a438a932f5dd44a9fc  /usr/bin/composer' | sha256sum -c - \
    && chmod +x /usr/bin/composer

FROM base AS fpm-runtime
COPY versions/5.6/php.ini /usr/local/etc/php/

FROM base AS regression
COPY versions/5.6/tests/ /checks/
# Архив нужен только для run-tests.php и тестовых данных.
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends php5.6-cgi="$PHP_PACKAGE_VERSION" xz-utils \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL https://www.php.net/distributions/php-5.6.40.tar.xz -o /tmp/php-test-source.tar.xz \
    && echo '1369a51eee3995d7fbd1c5342e5cc917760e276d561595b6052b21ace2656d1c  /tmp/php-test-source.tar.xz' | sha256sum -c - \
    && mkdir -p /usr/src/php \
    && tar -xJf /tmp/php-test-source.tar.xz -C /usr/src/php --strip-components=1 \
        php-5.6.40/run-tests.php php-5.6.40/tests/basic php-5.6.40/ext/session/tests \
    && rm /tmp/php-test-source.tar.xz \
    && TEST_PHP_CGI_EXECUTABLE=/usr/bin/php-cgi5.6 sh /checks/phpt.sh

FROM fpm-runtime AS verify
COPY versions/5.6/tests/ /checks/
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends libfcgi-bin \
    && rm -rf /var/lib/apt/lists/* \
    && sh /checks/smoke.sh && sh /checks/fpm.sh

FROM fpm-runtime AS with-nginx
RUN export DEBIAN_FRONTEND=noninteractive \
    && curl -fsSL https://nginx.org/keys/nginx_signing.key -o /usr/share/keyrings/nginx-signing.asc \
    && echo '55385da31d198fa6a5012d40ae98ecb272a6c4e8fffffba94719ffd3e87de37a  /usr/share/keyrings/nginx-signing.asc' | sha256sum -c - \
    && printf '%s\n' 'deb [signed-by=/usr/share/keyrings/nginx-signing.asc] https://nginx.org/packages/debian trixie nginx' > /etc/apt/sources.list.d/nginx.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nginx=1.30.7-1~trixie msmtp php5.6-gmp \
    && rm -rf /var/lib/apt/lists/* /etc/nginx/conf.d/default.conf \
    && phpenmod -v 5.6 exif
COPY nginx/nginx.conf nginx/php.conf nginx/php_fastcgi.conf /etc/nginx/
COPY versions/5.6/nginx/php.ini /usr/local/etc/php/conf.d/zz-nginx-compat.ini
COPY versions/5.6/nginx/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN sed -i 's/\[php5\]/[php5.6]/' /usr/local/etc/php-fpm.conf \
    && printf '\npm.status_path = /fpm-status-page\n' >> /usr/local/etc/php-fpm.conf \
    && chmod +x /usr/bin/docker-entrypoint.sh \
    && mkdir -p /etc/nginx/conf.d /etc/nginx/sites-enabled /etc/nginx/modules-enabled /var/cache/nginx /var/log/nginx \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && nginx -t
EXPOSE 80
CMD ["/usr/bin/docker-entrypoint.sh"]

FROM fpm-runtime AS fpm
