#!/bin/bash
set -euxo pipefail
apt-get update
apt-get install -y --no-install-recommends nginx
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -f /etc/nginx/conf.d/* /etc/nginx/sites-available/* /etc/nginx/sites-enabled/*
cp /tmp/nginx/nginx.conf /tmp/nginx/php.conf /tmp/nginx/php_fastcgi.conf /etc/nginx/
install -m 755 /tmp/nginx/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
rm -rf /tmp/nginx
