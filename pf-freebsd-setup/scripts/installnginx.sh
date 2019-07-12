#!/bin/sh

invoke_bash()
{
	echo 'nginx_enable="YES"' >> /etc/rc.conf
	env ASSUME_ALWAYS_YES=YES pkg bootstrap
	pkg update 
	pkg install -y nginx
	service nginx start
}

invoke_bash








