wget http://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key
CODENAME=$(grep "VERSION=" /etc/os-release |awk -F= {' print $2'}|sed s/\"//g |sed s/[0-9]//g | sed s/\)$//g |sed s/\(//g)
echo "deb http://nginx.org/packages/mainline/debian/ ${CODENAME} nginx" >> /etc/apt/sources.list
apt update
apt install -y nginx --allow-unauthenticated