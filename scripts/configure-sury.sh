#!/bin/sh
set -eu

apt-get update
apt-get install -y --no-install-recommends ca-certificates curl
curl -fsSL https://packages.sury.org/debsuryorg-archive-keyring.deb -o /tmp/sury-keyring.deb
echo '7511384559c9ddf1d5ce5f60be429ae9d4e7d01d9480d6f1b7a30c0810cf8b60  /tmp/sury-keyring.deb' | sha256sum -c -
dpkg -i /tmp/sury-keyring.deb
rm /tmp/sury-keyring.deb
printf '%s\n' 'deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ trixie main' > /etc/apt/sources.list.d/php.list
apt-get update
