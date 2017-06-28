#!/bin/sh

set -e

DATADISKS=$(lsblk | grep 100G | cut -d' ' -f1 | tr '\n' ' ')
DATADISKSFULLNAMES=""

for DISK in $DATADISKS; do
	DATADISKSFULLNAMES="$DATADISKSFULLNAMES /dev/$DISK"
done

yum install -y mdadm
mdadm --create --verbose /dev/md0 --level=0 --raid-devices=2 $DATADISKSFULLNAMES
mkdir -p /etc/mdadm
mdadm --detail --scan > /etc/mdadm/mdadm.conf
