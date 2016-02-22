#!/bin/bash

dbluns=""
logluns=""

if [[ "$#" -eq 4 ]]
then
	if [[ "$1" == "-DBDataLUNS" ]]
	then
		dbluns="$2"
	fi
	if [[ "$3" == "-DBDataLUNS" ]]
	then
		dbluns="$4"
	fi
	if [[ "$1" == "-DBLogLUNS" ]]
	then
		logluns="$2"
	fi
	if [[ "$3" == "-DBLogLUNS" ]]
	then
		logluns="$4"
	fi
fi
dblunsA=(${dbluns//,/ })
loglunsA=(${logluns//,/ })

dbNumRaidDevices=0
dbRaidDevices=""
dbnum=${#dblunsA[@]}
for ((dblun=0; dblun<dbnum; dblun++))
do
	devicePath=""

	scsiOutput=$(lsscsi -i 5)
	scsiOutputA=($scsiOutput)
	num=${#scsiOutputA[@]}
	if [ `expr $num % 8` -eq 0 ]
	then
		for ((i=0; i<=$num; i=i+8))
		do
			value=${scsiOutputA[$i]}		
			if [[ $value =~  \[5:0:0:$dblun\] ]]; 
			then
				devicePath=${scsiOutputA[$i+6]}
				break
			fi
		done
	fi
		
	if [ -n "$devicePath" ];
	then
		echo " Device Path is $devicePath" >> /var/log/sapconfigcreate
		dbNumRaidDevices=$(expr $dbNumRaidDevices + 1);
		dbRaidDevices="$dbRaidDevices $devicePath""1 "
		# http://superuser.com/questions/332252/creating-and-formating-a-partition-using-a-bash-script
		$(echo -e "n\np\n1\n\n\nw" | fdisk $devicePath)
		echo "changing partition type" >> /var/log/sapconfigcreate
		$(echo -e "t\nfd\nw" | fdisk $devicePath)		
	fi
done
echo "num: $dbNumRaidDevices paths: '$dbRaidDevices'" >> /var/log/sapconfigcreate
$(mdadm --create /dev/md127 --level 0 --raid-devices $dbNumRaidDevices $dbRaidDevices)
$(mkfs -t xfs /dev/md127)
#Test if SLES 11
#$(chkconfig --add boot.md)
#$(echo 'DEVICE /dev/sd*[0-9]' >> /etc/mdadm.conf)
$(mkdir /dbdata)
blkid=$(sudo /sbin/blkid /dev/md127)
if [[ $blkid =~  UUID=\"(.*?)\" ]]
then
	echo "Adding fstab entry" >> /var/log/sapconfigcreate
	uuid=${BASH_REMATCH[1]};
	echo "/dev/disk/by-uuid/$uuid  /dbdata  xfs  defaults  0  2" >> /etc/fstab
	#SLES 11
	#echo "UUID=$uuid  /dbdata  xfs  defaults  0  2" >> /etc/fstab
fi



logNumRaidDevices=0
logRaidDevices=""
lognum=${#loglunsA[@]}
for ((loglun=0; loglun<lognum; loglun++))
do
	devicePath=""

	scsiOutput=$(lsscsi -i 5)
	scsiOutputA=($scsiOutput)
	num=${#scsiOutputA[@]}
	if [ `expr $num % 8` -eq 0 ]
	then
		for ((i=0; i<=$num; i=i+8))
		do
			value=${scsiOutputA[$i]}		
			if [[ $value =~  \[5:0:0:$loglun\] ]]; 
			then
				devicePath=${scsiOutputA[$i+6]}
				break
			fi
		done
	fi
		
	if [ -n "$devicePath" ];
	then
		echo " Device Path is $devicePath" >> /var/log/sapconfigcreate
		logNumRaidDevices=$(expr $dbNumRaidDevices + 1);
		logRaidDevices="$dbRaidDevices $devicePath""1 "
		# http://superuser.com/questions/332252/creating-and-formating-a-partition-using-a-bash-script
		$(echo -e "n\np\n1\n\n\nw" | fdisk $devicePath)
		echo "changing partition type" >> /var/log/sapconfigcreate
		$(echo -e "t\nfd\nw" | fdisk $devicePath)		
	fi
done
echo "num: $logNumRaidDevices paths: '$logaidDevices'" >> /var/log/sapconfigcreate
$(mdadm --create /dev/md128 --level 0 --raid-devices $dbNumRaidDevices $dbRaidDevices)
$(mkfs -t xfs /dev/md128)
#Test if SLES 11
#$(chkconfig --add boot.md)
#$(echo 'DEVICE /dev/sd*[0-9]' >> /etc/mdadm.conf)
$(mkdir /dblog)
blkid=$(sudo /sbin/blkid /dev/md128)
if [[ $blkid =~  UUID=\"(.*?)\" ]]
then
	echo "Adding fstab entry" >> /var/log/sapconfigcreate
	uuid=${BASH_REMATCH[1]};
	echo "/dev/disk/by-uuid/$uuid  /dblog  xfs  defaults  0  2" >> /etc/fstab
	#SLES 11
	#echo "UUID=$uuid  /dbdata  xfs  defaults  0  2" >> /etc/fstab
fi