FROM php:8.1.34-fpm-bookworm AS upstream

FROM upstream AS build
COPY scripts/rebuild-php.sh /rebuild-php.sh
RUN bash /rebuild-php.sh 1d7dec178a094e6e75b229ce22754045f8c6070a c85ad0fddcbff7f2318617eeaa54d271135463b5bf70a01228447e3ed78de96e

ENV LANG=C.UTF-8

RUN apt update && apt upgrade -y && apt install -y gnupg

COPY scripts/install-extensions.sh /install.sh
COPY scripts/download-pecl.sh scripts/pecl-sha256.txt /

RUN docker-php-source extract \
    && TEST_PHP_EXECUTABLE=/usr/local/bin/php REPORT_EXIT_STATUS=1 php /usr/src/php/run-tests.php -q /usr/src/php/tests/basic/001.phpt /usr/src/php/ext/session/tests/session_basic1.phpt

RUN bash /install.sh redis-6.0.2 mongodb-1.20.1 grpc-1.62.0 memcached-3.2.0 memcache-8.2

FROM upstream AS base
COPY --from=build /usr/local/ /usr/local/
COPY scripts/configure-runtime.sh /configure-runtime.sh
COPY php-fpm.conf /usr/local/etc/php-fpm.conf
COPY opcache.conf /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
COPY .bashrc /root/.bashrc
COPY .bashrc /var/www/.bashrc
COPY micro.json /root/.config/micro/settings.json
RUN bash /configure-runtime.sh php8.1.34
WORKDIR /var/www
CMD ["php-fpm"]

FROM base AS dev
COPY scripts/install-dev.sh /install_dev.sh
COPY scripts/download-pecl.sh scripts/pecl-sha256.txt /
RUN bash /install_dev.sh xdebug-3.3.2 ast-1.1.2
COPY xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin -- --filename=composer

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
