#!/bin/sh
#Download the waagent from github
wget https://raw.githubusercontent.com/Azure/WALinuxAgent/WALinuxAgent-$1/waagent
#Upgrade file
chmod +x waagent
cp waagent /usr/sbin
#Restart service
service walinuxagent restart
service waagent restart
