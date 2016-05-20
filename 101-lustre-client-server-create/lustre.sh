#!/bin/bash

# ./lustre_configure.sh -n MDS -i 1 -d 4 -m 10.1.0.4 -l 10.1.0.4 -f scratch
# ./lustre_configure.sh -n OSS -i 1 -d 4 -m 10.1.0.4 -l 10.1.0.4 -f scratch

log()
{
	echo "$1"
	logger "$1"
}

# Initialize local variables
# Get today's date into YYYYMMDD format
NOW=$(date +"%Y%m%d")
DEVICES_BLACKLIST="/dev/sda|/dev/sdb"
DEVICES_LIST=($(ls -1 /dev/sd* | egrep -v "${DEVICES_BLACKLIST}" | egrep -v "[0-9]$"))

# Get command line parameters
while getopts "n:i:d:m:l:f:" opt; do
	log "Option $opt set with value ${OPTARG})"
	case "$opt" in
	n)	NODETYPE=$OPTARG
		;;
	i)	NODEINDEX=$OPTARG
		;;
	d)	NODETYPEDISKCOUNT=$OPTARG
		;;
	m)	MGSIP=$OPTARG
		;;
	l)	LOCALIP=$OPTARG
		;;
	f)	FILESYSTEMNAME=$OPTARG
		;;
	esac
done

fatal() {
    msg=${1:-"Unknown Error"}
    log "FATAL ERROR: $msg"
    exit 1
}

# Retries a command on failure.
# $1 - the max number of attempts
# $2... - the command to run
retry() {
    local -r -i max_attempts="$1"; shift
    local -r cmd="$@"
    local -i attempt_num=1
 
    until $cmd
    do
        if (( attempt_num == max_attempts ))
        then
            log "Command $cmd attempt $attempt_num failed and there are no more attempts left!"
			return 1
        else
            log "Command $cmd attempt $attempt_num failed. Trying again in 5 + $attempt_num seconds..."
            sleep $(( 5 + attempt_num++ ))
        fi
    done
}

# You must be root to run this script
if [ "${UID}" -ne 0 ]; then
    fatal "You must be root to run this script."
fi

if [[ -z ${NODETYPE} ]]; then
    fatal "No node type specified, can't proceed."
fi

if [[ -z ${NODEINDEX} ]]; then
    fatal "No node index specified, can't proceed."
fi

if [[ -z ${NODETYPEDISKCOUNT} ]]; then
    fatal "No node type disk count specified, can't proceed."
fi

if [[ -z ${MGSIP} ]]; then
    fatal "No MGS IP specified, can't proceed."
fi

if [[ -z ${LOCALIP} ]]; then
    fatal "No local IP specified, can't proceed."
fi

if [[ -z ${FILESYSTEMNAME} ]]; then
    fatal "No filesystem name specified, can't proceed."
fi

log "NOW=$NOW NODETYPE=$NODETYPE NODEINDEX=$NODEINDEX MGSIP=$MGSIP LOCALIP=$LOCALIP FILESYSTEMNAME=$FILESYSTEMNAME"

add_to_fstab() {
	device="${1}"
	mount_point="${2}"
	if grep -q "$device" /etc/fstab
	then
		log "Not adding $device to /etc/fstab (it's  already there)"
	else
		line="$device $mount_point lustre defaults,_netdev 0 0"
		log "${line}"
		echo -e "${line}" >> /etc/fstab
	fi
}

create_mgs() {
	log "Create MGS"
	
	# Make MGS filesystem which is always on /dev/sdc of the MGS node
	mkfs.lustre --fsname=$FILESYSTEMNAME --mgs --reformat /dev/sdc
	
	uuid=$(blkid -o value -s UUID /dev/sdc)
	log "MGS UUID=$uuid"
	
	label=$(blkid -c/dev/null -o value -s LABEL /dev/sdc)
	log "MGS LABEL=$label"
	
	# Log device info
	dumpe2fs -h /dev/sdc | logger
	
	# Create mount directory
	mount_point=/mnt/targets/$label
	mkdir -p $mount_point
	log "Created mount point directory $mount_point"
	
	# Add to /etc/fstab so that mount persists across reboots
	device_by_uuid="UUID=$uuid"
	add_to_fstab $device_by_uuid $mount_point
	
	retry 5 mount -a
	log "Mounted /dev/sdc as $mount_point"
}

create_mds() {
	log "Create MDS"
	
	((index=$NODEINDEX*$NODETYPEDISKCOUNT))
	
	for device in "${DEVICES_LIST[@]}";
	do
		log $device $index
		
		mkfs.lustre --fsname=$FILESYSTEMNAME --mdt --mgsnode=$MGSIP --index=$index --reformat $device
		
		# Disable MDS check of user being the same on the clients and MDS nodes
		tunefs.lustre --param mdt.identity_upcall=NONE $device
		
		uuid=$(blkid -o value -s UUID $device)
		log "MDS UUID=$uuid"	
		
		label=$(blkid -c/dev/null -o value -s LABEL $device)
		log "MDS LABEL=$label"
	
		dumpe2fs -h $device | logger
	
		# Create mount directory
		mount_point=/mnt/targets/$label
		mkdir -p $mount_point
		log "Created mount point directory $mount_point"
	
		# Mount the current device
		mount -t lustre $device $mount_point
		
		# Add to /etc/fstab so that mount persists across reboots
		device_by_uuid="UUID=$uuid"
		add_to_fstab $device_by_uuid $mount_point
	
		((index=index+1))
	done

	# Mount everything based on what is defined in the /etc/fstab
	retry 5 mount -a
}

create_oss() {
	log "Create OSS"
	
	((index=$NODEINDEX*$NODETYPEDISKCOUNT))
	
	for device in "${DEVICES_LIST[@]}";
	do
		log $device $index
		
		mkfs.lustre --fsname=$FILESYSTEMNAME --ost --mgsnode=$MGSIP --index=$index --reformat $device
		
		uuid=$(blkid -o value -s UUID $device)
		log "OSS UUID=$uuid"	
		
		label=$(blkid -c/dev/null -o value -s LABEL $device)
		log "OSS LABEL=$label"
	
		dumpe2fs -h $device | logger
	
		# Create mount directory
		mount_point=/mnt/targets/$label
		mkdir -p $mount_point
		log "Created mount point directory $mount_point"
	
		# Mount the current device
		mount -t lustre $device $mount_point
		
		# Add to /etc/fstab so that mount persists across reboots
		device_by_uuid="UUID=$uuid"
		add_to_fstab $device_by_uuid $mount_point
	
		((index=index+1))
	done
	
	# Random sleep to minimize chance of mount error
	sleep $[ ( $RANDOM % 20 ) + 1]s
	
	# Mount everything based on what is defined in the /etc/fstab
	retry 5 mount -a
}

if [ "$NODETYPE" == "MGS" ]; then
	create_mgs
fi

if [ "$NODETYPE" == "MDS" ]; then
	create_mds
fi

if [ "$NODETYPE" == "OSS" ]; then
	create_oss
fi