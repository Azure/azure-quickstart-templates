#!/bin/bash
# create-mdadm <lun array> <mdadm path e.g. /dev/md127> <mount path e.g. /dbdata>
function addto-fstab()
{
	partPath=$1
	local blkid=$(sudo /sbin/blkid $partPath)
	if [[ $blkid =~  UUID=\"(.{36})\" ]]
	then
		echo "Adding fstab entry" >> /var/log/sapconfigcreate
		local uuid=${BASH_REMATCH[1]};
		local vLinux=$(cat /etc/issue)
		if [[ $vLinux =~ 11 SP4 ]]
		then
			#SLES 11
			echo "UUID=$uuid $mountPath xfs  defaults  0  2" >> /etc/fstab
		fi
		if [[ $vLinux =~ 12 ]]
		then
			#SLES 12
			echo "/dev/disk/by-uuid/$uuid $mountPath xfs  defaults  0  2" >> /etc/fstab
		fi
	fi
}

function get-device-path()
{
	local getdevicepathresult=""
	local lun=$1
	local scsiOutput=$(lsscsi -i 5)
	local scsiOutputA=($scsiOutput)
	local numLines=${#scsiOutputA[@]}
	if [ `expr $numLines % 8` -eq 0 ]
	then
		for ((j=0; j<=$numLines; j=j+8))
		do
			local value=${scsiOutputA[$j]}		
			if [[ $value =~  \[5:0:0:$lun\] ]]; 
			then
				local getdevicepathresult=${scsiOutputA[$j+6]}
				break			
			fi
		done
	fi
	echo "$getdevicepathresult"
}

function create-mdadm()
{
	lunsA=$1
	mdadmPath=$2
	mountPath=$3
	
	arraynum=${#lunsA[@]}
	if [[ $arraynum -gt 1 ]]
	then
		numRaidDevices=0
		raidDevices=""
		num=${#lunsA[@]}
		echo "num luns $num" >> /var/log/sapconfigcreate
		for ((i=0; i<num; i++))
		do
			echo "trying to find device path" >> /var/log/sapconfigcreate
			lun=${lunsA[$i]}
			devicePath=$(get-device-path $lun)
			
			if [ -n "$devicePath" ];
			then
				echo " Device Path is $devicePath" >> /var/log/sapconfigcreate
				numRaidDevices=$(expr $numRaidDevices + 1);
				raidDevices="$raidDevices $devicePath""1 "
				# http://superuser.com/questions/332252/creating-and-formating-a-partition-using-a-bash-script
				$(echo -e "n\np\n1\n\n\nw" | fdisk $devicePath)
				echo "changing partition type" >> /var/log/sapconfigcreate
				$(echo -e "t\nfd\nw" | fdisk $devicePath)
			else
				echo "no device path for LUN $lun" >> /var/log/sapconfigcreate
			fi
		done
		echo "num: $numRaidDevices paths: '$raidDevices'" >> /var/log/sapconfigcreate
		$(mdadm --create $mdadmPath --level 0 --raid-devices $numRaidDevices $raidDevices)
		$(mkfs -t xfs $mdadmPath)
		#Test if SLES 11
		#$(chkconfig --add boot.md)
		#$(echo 'DEVICE /dev/sd*[0-9]' >> /etc/mdadm.conf)
		$(mkdir $mountPath)
		addto-fstab $mdadmPath		
	else		
		lun=${lunsA[0]}
		devicePath=$(get-device-path $lun)
		
		if [ -n "$devicePath" ];
		then
			echo " Device Path is $devicePath" >> /var/log/sapconfigcreate		
			# http://superuser.com/questions/332252/creating-and-formating-a-partition-using-a-bash-script
			$(echo -e "n\np\n1\n\n\nw" | fdisk $devicePath)
			partPath="$devicePath""1"
			$(mkfs -t xfs $partPath)
			$(mkdir $mountPath)	

			addto-fstab $partPath
		fi
	fi
}

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

create-mdadm dblunsA "/dev/md127" "/dbdata"
create-mdadm dblunsA "/dev/md128" "/dblog"
