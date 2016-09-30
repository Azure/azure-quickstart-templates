#!/bin/bash

(echo n; echo p; echo 1; echo; echo; echo w) | fdisk /dev/sdc > /dev/null 
mkfs -t ext4 /dev/sdc1 > /dev/null 
mkdir /datadisk 
mount /dev/sdc1 /datadisk

apt-get update > /dev/null 
apt-get -y install fio > /dev/null

echo [global] > t 
echo size=$1 >> t
echo direct=1 >> t
echo iodepth=256 >> t 
echo ioengine=libaio >> t 
echo bs=8k >> t

for i in `seq 1 4`; do
	echo [w$i] >> t
	echo rw=$2 >> t
	echo directory=/datadisk >> t
done 

fio --runtime $3 t | grep -E 'READ:|WRITE:' | tr '\n' ';' | tr -s [:space:] | sed 's/ :/:/g' | sed 's/= /=/g'
