#!/bin/bash
if [ -e "$HOME/.profile" ]; then
        . $HOME/.profile
fi
if [ -e "$HOME/.bash_profile" ]; then
        . $HOME/.bash_profile
fi

SAS_USER="sas"
SAS_GROUP="sas"
#mount -a
while ! mountpoint -q /mnt/resource; do sleep 1; echo "Waiting on /mnt/resource to mount..."; done
echo "creating saswork"
mkdir -p /mnt/resource/sastmp/saswork
echo "creating cascache"
mkdir -p /mnt/resource/sastmp/cascache
echo "granting rights to created temp dir"
chown -R ${SAS_USER}:${SAS_GROUP} /mnt/resource/sastmp
echo "opening group permissions so the cas can write as well"
chmod -R 777 /mnt/resource/sastmp

# Session defined export for saswork env variable
echo 'export COMPUTESERVER_TMP_PATH=/mnt/resource/sastmp/saswork' >> /etc/sysconfig/sas/sas-viya-compsrv-default
