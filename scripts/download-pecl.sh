#!/bin/sh
set -eu
package=$1
checksum=$(awk -v file="$package.tgz" '$2 == file { print $1 }' /pecl-sha256.txt)
[ -n "$checksum" ]
curl -fsSL "https://pecl.php.net/get/$package.tgz" -o /tmp/extension.tgz
echo "$checksum  /tmp/extension.tgz" | sha256sum -c -
