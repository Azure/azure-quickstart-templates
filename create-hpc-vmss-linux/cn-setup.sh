#!/bin/bash

# fail on any error
set -e

HEADNODE=$1
USER=$2

sed -i 's/^ResourceDisk.MountPoint=\/mnt\/resource$/ResourceDisk.MountPoint=\/mnt\/local_resource/g' /etc/waagent.conf
umount /mnt/resource

mkdir -p /mnt/resource/scratch

cat << EOF >> /etc/fstab
$HEADNODE:/home    /home   nfs defaults 0 0
$HEADNODE:/mnt/resource/scratch    /mnt/resource/scratch   nfs defaults 0 0
EOF

until yum install -y -q nfs-utils
do
    sleep 10
done
setsebool -P use_nfs_home_dirs 1

mount -a

# Don't require password for HPC user sudo
echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
