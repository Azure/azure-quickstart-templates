#!/bin/sh

set -e

yum install -y mdadm
mdadm --create --verbose /dev/md0 --level=0 --raid-devices=2 /dev/sdc /dev/sdd
mkdir -p /etc/mdadm
mdadm --detail --scan > /etc/mdadm/mdadm.conf
