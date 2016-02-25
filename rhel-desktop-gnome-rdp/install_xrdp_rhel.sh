#!/bin/bash

#install gnome desktop
yum groupinstall -y "X Window System" "GNOME"

#install xrdp
rpm -Uvh https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-1.el7.nux.noarch.rpm
yum install xrdp -y

#disable selinux and firewalld
setenforce 0
sed -i 's/^SELINUX.*/SELINUX=disabled/' /etc/sysconfig/selinux
service firewalld stop
chkconfig firewalld off

#start xrdp
service xrdp start
chkconfig xrdp on

#change runlevel to 5
systemctl enable graphical.target --force



