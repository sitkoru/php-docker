FROM php:5.6.40-fpm AS compiled

RUN curl -fsSL https://deb.debian.org/debian/pool/main/d/debian-archive-keyring/debian-archive-keyring_2023.3+deb12u2_all.deb -o /tmp/keyring.deb \
    && echo 'f699e2f88dca05212f2a452b58475f2993cb6993dfbafb1d0205a3291eb8b4b8  /tmp/keyring.deb' | sha256sum -c - \
    && dpkg -i /tmp/keyring.deb && rm /tmp/keyring.deb \
    && curl -fsSL https://ftp-master.debian.org/keys/archive-key-10-security.asc -o /etc/apt/trusted.gpg.d/debian-security-10.asc \
    && echo '4cf886d6df0fc1c185ce9fb085d1cd8d678bc460e6267d80a833d7ea507a0fbd  /etc/apt/trusted.gpg.d/debian-security-10.asc' | sha256sum -c -

RUN printf '%s\n' \
    'deb http://archive.debian.org/debian stretch main' \
    'deb http://archive.debian.org/debian-security stretch/updates main' \
    > /etc/apt/sources.list \
    && printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99archive

COPY versions/5.6/patches/ /patches/
COPY versions/5.6/build-php.sh /usr/local/bin/build-php
RUN apt-get update && apt-get install -y --no-install-recommends \
    $PHPIZE_DEPS patch libcurl4-openssl-dev libedit-dev libsqlite3-dev libssl1.0-dev \
    libxml2-dev zlib1g-dev \
    && sh /usr/local/bin/build-php

ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y \
    libxml2-dev \
    zlib1g-dev \
    libfreetype6 \
    libfreetype6-dev \
    libjpeg62-turbo \
    libjpeg-dev \
    libpng16-16 \
    libpng-dev \
    libxslt1.1 \
    libxslt-dev \
    libpq5 \
    libpq-dev \
    libmemcached-dev \
    libicu-dev \
    bash-completion \
    wget \
    locales \
    locales-all \
    mysql-client \
    zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install pdo_pgsql pgsql soap zip xsl opcache pcntl gd bcmath pdo_mysql mysqli mysql intl \
    && curl -fsSL https://pecl.php.net/get/redis-4.0.0.tgz -o /tmp/redis.tgz \
    && echo 'c8a969cca131efa9e583c11e6522953a9165b804dbc5d2cba8875323ab22cfc1  /tmp/redis.tgz' | sha256sum -c - \
    && pecl install /tmp/redis.tgz \
    && docker-php-ext-enable redis \
    && curl -fsSL https://pecl.php.net/get/memcached-2.2.0.tgz -o /tmp/memcached.tgz \
    && echo '17b9600f6d4c807f23a3f5c45fcd8775ca2e61d6eda70370af2bef4c6e159f58  /tmp/memcached.tgz' | sha256sum -c - \
    && pecl install /tmp/memcached.tgz \
    && docker-php-ext-enable memcached \
    && curl -fsSL https://pecl.php.net/get/memcache-3.0.8.tgz -o /tmp/memcache.tgz \
    && echo '2cae5b423ffbfd33a259829849f6000d4db018debe3e29ecf3056f06642e8311  /tmp/memcache.tgz' | sha256sum -c - \
    && yes|CFLAGS="-fgnu89-inline" pecl install /tmp/memcache.tgz \
    && docker-php-ext-enable memcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM compiled AS base
RUN docker-php-source delete \
    && rm -rf /patches /usr/local/bin/build-php \
    && apt-mark auto $PHPIZE_DEPS patch libcurl4-openssl-dev libedit-dev libsqlite3-dev libssl1.0-dev \
        libxml2-dev zlib1g-dev libfreetype6-dev libjpeg-dev libpng-dev libxslt-dev libpq-dev libicu-dev libmemcached-dev \
    && find /usr/local -type f -executable -exec ldd '{}' ';' 2>/dev/null \
        | awk '/=>/ { print $(NF-1) }' | sort -u | xargs -r dpkg-query --search \
        | cut -d: -f1 | sort -u | xargs -r apt-mark manual \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen ru_RU.UTF-8 && \
    update-locale LANG=ru_RU.UTF-8 && \
    echo "LANGUAGE=ru_RU.UTF-8" >> /etc/default/locale && \
    echo "LC_ALL=ru_RU.UTF-8" >> /etc/default/locale

COPY opcache.conf /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

COPY versions/5.6/.bashrc /root/.bashrc
COPY versions/5.6/.bashrc /var/www/.bashrc

RUN chown -R www-data:www-data /var/www

RUN echo Europe/Moscow | tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

RUN rm /usr/local/etc/php-fpm.d/www.conf
COPY versions/5.6/php-fpm.conf /usr/local/etc/php-fpm.conf

WORKDIR /var/www

CMD ["php-fpm"]

FROM base AS dev

RUN apt-get update \
    && apt-get install -y $PHPIZE_DEPS openssh-client git unzip rsync git \
    && curl -fsSL https://pecl.php.net/get/xdebug-2.5.5.tgz -o /tmp/xdebug.tgz \
    && echo '72108bf2bc514ee7198e10466a0fedcac3df9bbc5bd26ce2ec2dafab990bf1a4  /tmp/xdebug.tgz' | sha256sum -c - \
    && pecl install /tmp/xdebug.tgz \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $PHPIZE_DEPS \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY versions/5.6/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

RUN curl -fsSL https://getcomposer.org/installer -o /tmp/composer-setup.php \
    && curl -fsSL https://composer.github.io/installer.sig -o /tmp/composer-setup.sig \
    && php -r 'if (hash_file("sha384", "/tmp/composer-setup.php") !== trim(file_get_contents("/tmp/composer-setup.sig"))) { exit(1); }' \
    && php /tmp/composer-setup.php --2.2 --install-dir=/usr/bin --filename=composer \
    && rm /tmp/composer-setup.php /tmp/composer-setup.sig

FROM base AS fpm-runtime

COPY versions/5.6/php.ini /usr/local/etc/php/

FROM compiled AS regression
COPY versions/5.6/tests/ /checks/
RUN cd /usr/src/php \
    && sed -i 's/--disable-cgi/--enable-cgi/' config.nice \
    && ./config.nice \
    && make -j2 sapi/cgi/php-cgi \
    && sh /checks/phpt.sh

FROM fpm-runtime AS verify
COPY versions/5.6/tests/ /checks/
RUN apt-get update && apt-get install -y --no-install-recommends libfcgi-bin \
    && sh /checks/smoke.sh && sh /checks/fpm.sh

FROM compiled AS nginx-build
RUN apt-get update && apt-get install -y --no-install-recommends libpcre3-dev libgmp-dev \
    && ln -s /usr/include/$(dpkg-architecture --query DEB_BUILD_MULTIARCH)/gmp.h /usr/include/gmp.h \
    && docker-php-ext-install -j2 exif gmp
COPY versions/5.6/nginx/build.sh /tmp/build-nginx.sh
RUN sh /tmp/build-nginx.sh

FROM fpm-runtime AS with-nginx
RUN apt-get update && apt-get install -y --no-install-recommends libpcre3 libgmp10 msmtp \
    && rm -rf /var/lib/apt/lists/*
COPY --from=nginx-build /usr/local/lib/php/extensions/no-debug-non-zts-20131226/exif.so /usr/local/lib/php/extensions/no-debug-non-zts-20131226/
COPY --from=nginx-build /usr/local/lib/php/extensions/no-debug-non-zts-20131226/gmp.so /usr/local/lib/php/extensions/no-debug-non-zts-20131226/
RUN docker-php-ext-enable exif gmp
COPY --from=nginx-build /nginx-root/ /
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
