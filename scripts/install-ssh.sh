#!/bin/bash
set -euxo pipefail
apt-get update
apt-get install -y openssh-server rsync
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
mkdir -p /run/sshd
sed -i 's/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g; s/UsePAM.*/UsePAM no/g; s/#PermitRootLogin.*/PermitRootLogin yes/g; s/#AuthorizedKeysFile/AuthorizedKeysFile/g' /etc/ssh/sshd_config
chmod +x /docker-entrypoint.sh
