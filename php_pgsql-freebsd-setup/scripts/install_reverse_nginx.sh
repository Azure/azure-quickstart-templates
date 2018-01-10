#!/bin/sh

frontendvmip1=$1
backendvm1ip=$2
backendvm2ip=$3

echo 'ifconfig_hn1="DHCP"' >> /etc/rc.conf
ifconfig hn1 up
env ASSUME_ALWAYS_YES=YES pkg bootstrap
pkg update
pkg install -y nginx

echo 'nginx_enable="YES"' >> /etc/rc.conf
echo "$frontendvmip1"
echo "$backendvm1ip"
echo "$backendvm2ip"

mkdir -p /var/nginx/cache

cp /usr/local/etc/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf.bak
cp ./frontend_nginx.conf /usr/local/etc/nginx/nginx.conf
cp ./frontend_proxy.conf /usr/local/etc/nginx/proxy.conf

sed -i -e 's/backendvm1ip/'$backendvm1ip'/g' /usr/local/etc/nginx/nginx.conf
sed -i -e 's/backendvm2ip/'$backendvm2ip'/g' /usr/local/etc/nginx/nginx.conf
sed -i -e 's/frontendvmip1/'$frontendvmip1'/g' /usr/local/etc/nginx/nginx.conf

service nginx restart

sed -i -e '/^[^#]/d' /etc/sysctl.conf
echo 'kern.ipc.soacceptqueue=4096' >> /etc/sysctl.conf
echo 'net.inet.tcp.msl=1000' >> /etc/sysctl.conf

echo "/sbin/reboot" | at + 1 minute