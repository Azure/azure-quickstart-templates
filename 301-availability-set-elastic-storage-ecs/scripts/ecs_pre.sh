#!/bin/bash
# yum update -y &>> /root/install.log 
myreboot () {
   sleep 60 
   shutdown -r now
} 
yum install firewalld libselinux-python docker ntp pigz python-docker-py -y
# for openlogic
sed -i -e 's/#GatewayPorts no/GatewayPorts yes/g' /etc/ssh/sshd_config 
yum remove *nfs* -y 
systemctl disable rpcbind 
myreboot &  
echo $?
