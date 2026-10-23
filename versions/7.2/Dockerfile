FROM php:7.2.34-fpm-buster AS upstream
# Архив Buster сохраняет проверку подписей APT.
RUN sed -i -e 's|http://deb.debian.org/debian|https://archive.debian.org/debian|g' -e 's|http://security.debian.org/debian-security|https://archive.debian.org/debian-security|g' /etc/apt/sources.list

FROM upstream AS build
COPY versions/7.2/patches/ /patches/
COPY versions/7.2/rebuild-php.sh /rebuild-php.sh
RUN bash /rebuild-php.sh

ENV LANG=C.UTF-8

RUN apt update && apt upgrade -y && apt install -y gnupg

COPY versions/7.2/install-extensions.sh /install.sh
COPY scripts/download-pecl.sh scripts/pecl-sha256.txt /

RUN docker-php-source extract \
    && TEST_PHP_EXECUTABLE=/usr/local/bin/php REPORT_EXIT_STATUS=1 php /usr/src/php/run-tests.php -q /usr/src/php/tests/basic/001.phpt /usr/src/php/ext/session/tests/session_basic1.phpt

RUN bash /install.sh redis-6.0.2 memcached-3.2.0 memcache-4.0.5.2

FROM upstream AS base
COPY --from=build /usr/local/ /usr/local/
COPY scripts/configure-runtime.sh /configure-runtime.sh
COPY php-fpm.conf /usr/local/etc/php-fpm.conf
COPY opcache.conf /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
COPY .bashrc /root/.bashrc
COPY .bashrc /var/www/.bashrc
COPY micro.json /root/.config/micro/settings.json
RUN bash /configure-runtime.sh php7.2.34
WORKDIR /var/www
CMD ["php-fpm"]

FROM base AS dev
COPY scripts/install-dev.sh /install_dev.sh
COPY scripts/download-pecl.sh scripts/pecl-sha256.txt /
RUN bash /install_dev.sh xdebug-3.1.6 ast-1.1.2
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

FROM build AS regression
COPY versions/5.6/tests/upload-progress.phpt /checks/upload-progress.phpt
COPY versions/5.6/tests/phpt.sh /checks/phpt.sh
RUN cd /usr/src/php \
    && sed -i 's/--disable-cgi/--enable-cgi/' config.nice \
    && ./config.nice \
    && make -j2 sapi/cgi/php-cgi \
    && sh /checks/phpt.sh
