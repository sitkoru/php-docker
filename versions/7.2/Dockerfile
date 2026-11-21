FROM debian:trixie-slim AS base

ENV PHP_INI_DIR=/usr/local/etc/php \
    PHPRC=/usr/local/etc/php \
    PHP_INI_SCAN_DIR=:/usr/local/etc/php/conf.d

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && curl -fsSL https://packages.sury.org/debsuryorg-archive-keyring.deb -o /tmp/sury-keyring.deb \
    && echo '7511384559c9ddf1d5ce5f60be429ae9d4e7d01d9480d6f1b7a30c0810cf8b60  /tmp/sury-keyring.deb' | sha256sum -c - \
    && dpkg -i /tmp/sury-keyring.deb \
    && rm /tmp/sury-keyring.deb \
    && printf '%s\n' 'deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ trixie main' > /etc/apt/sources.list.d/php.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        php7.2-fpm=7.2.34-71+debsuryorg13.1+1 php7.2-cli=7.2.34-71+debsuryorg13.1+1 \
        php7.2-bcmath php7.2-curl php7.2-gd php7.2-gmp php7.2-intl php7.2-mbstring \
        php7.2-memcache php7.2-memcached php7.2-mysql php7.2-pgsql php7.2-readline \
        php7.2-redis php7.2-soap php7.2-sqlite3 php7.2-xml php7.2-zip \
        bash-completion locales micro msmtp wget zip \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/bin/php7.2 /usr/local/bin/php \
    && ln -s /usr/sbin/php-fpm7.2 /usr/local/sbin/php-fpm \
    && ln -sf /usr/local/etc/php-fpm.conf /etc/php/7.2/fpm/php-fpm.conf \
    && printf '%s\n' 'en_US.UTF-8 UTF-8' 'ru_RU.UTF-8 UTF-8' > /etc/locale.gen \
    && locale-gen ru_RU.UTF-8 \
    && ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime \
    && printf '%s\n' Europe/Moscow > /etc/timezone

COPY php-fpm.conf /usr/local/etc/php-fpm.conf
COPY opcache.conf /usr/local/etc/php/conf.d/99-opcache.ini
COPY .bashrc /root/.bashrc
COPY .bashrc /var/www/.bashrc
COPY micro.json /root/.config/micro/settings.json
RUN sed -i 's/php_version/php7.2.34/g' /usr/local/etc/php-fpm.conf \
    && sed -i '/^zend_extension=/d' /usr/local/etc/php/conf.d/99-opcache.ini
WORKDIR /var/www
CMD ["php-fpm"]

FROM base AS dev
COPY xdebug.ini /usr/local/etc/php/conf.d/99-xdebug.ini
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends openssh-server git unzip rsync php7.2-xdebug php7.2-ast \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i '/^zend_extension=/d' /usr/local/etc/php/conf.d/99-xdebug.ini \
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
CMD "/usr/bin/docker-entrypoint.sh"

FROM ssh AS with-nginx-ssh
COPY nginx/ /tmp/nginx/
RUN bash /tmp/nginx/install.sh
EXPOSE 80
CMD "/usr/bin/docker-entrypoint.sh"

FROM base AS regression
COPY versions/5.6/tests/upload-progress.phpt /checks/upload-progress.phpt
COPY versions/5.6/tests/phpt.sh /checks/phpt.sh
# Архив нужен только для run-tests.php и тестовых данных.
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends php7.2-cgi=7.2.34-71+debsuryorg13.1+1 xz-utils \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL https://www.php.net/distributions/php-7.2.34.tar.xz -o /tmp/php-test-source.tar.xz \
    && echo '409e11bc6a2c18707dfc44bc61c820ddfd81e17481470f3405ee7822d8379903  /tmp/php-test-source.tar.xz' | sha256sum -c - \
    && mkdir -p /usr/src/php \
    && tar -xJf /tmp/php-test-source.tar.xz -C /usr/src/php --strip-components=1 \
        php-7.2.34/run-tests.php php-7.2.34/tests/basic php-7.2.34/ext/session/tests \
    && rm /tmp/php-test-source.tar.xz \
    && TEST_PHP_CGI_EXECUTABLE=/usr/bin/php-cgi7.2 sh /checks/phpt.sh
