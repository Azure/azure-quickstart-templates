#!/usr/bin/env bash

adjustTCPKeepalive ()
{
# Azure public IPs have some odd keep alive behaviour
# A summary is available here https://docs.mongodb.org/ecosystem/platforms/windows-azure/

echo "Setting TCP keepalive..."
sysctl -w net.ipv4.tcp_keepalive_time=120

echo "Setting TCP keepalive permanently..."
echo "net.ipv4.tcp_keepalive_time = 120" >> /etc/sysctl.conf
echo "" >> /etc/sysctl.conf
}

formatDataDisk ()
{
# This script formats and mounts the drive on lun0 as /datadisk

DISK="/dev/disk/azure/scsi1/lun0"
PARTITION="/dev/disk/azure/scsi1/lun0-part1"
MOUNTPOINT="/datadisk"

echo "Partitioning the disk."
echo "n
p
1


t
83
w"| fdisk ${DISK}

echo "Waiting for the symbolic link to be created..."
udevadm settle --exit-if-exists=$PARTITION

echo "Creating the filesystem."
mkfs -j -t ext4 ${PARTITION}

echo "Updating fstab"
LINE="${PARTITION}\t${MOUNTPOINT}\text4\tnoatime,nodiratime,nodev,noexec,nosuid\t1\t2"
echo -e ${LINE} >> /etc/fstab

echo "Mounting the disk"
mkdir -p $MOUNTPOINT
mount -a

echo "Changing permissions"
chown couchbase $MOUNTPOINT
chgrp couchbase $MOUNTPOINT
}

turnOffTransparentHugepages ()
{
# Please look at http://bit.ly/1ZAcLjD as for how to PERMANENTLY alter this setting.

echo "#!/bin/bash
### BEGIN INIT INFO
# Provides:          disable-thp
# Required-Start:    $local_fs
# Required-Stop:
# X-Start-Before:    couchbase-server
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Disable THP
# Description:       disables Transparent Huge Pages (THP) on boot
### END INIT INFO

echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled
echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag
" > /etc/init.d/disable-thp
chmod 755 /etc/init.d/disable-thp
service disable-thp start
update-rc.d disable-thp defaults
}

setSwappinessToZero ()
{
# Please look at http://bit.ly/1k2CtNn as for how to PERMANENTLY alter this setting.

sysctl vm.swappiness=0
echo "
# Required for Couchbase
vm.swappiness = 0" >> /etc/sysctl.conf
}
