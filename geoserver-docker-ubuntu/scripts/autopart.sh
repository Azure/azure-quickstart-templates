# Custom Script for Linux

#!/bin/bash

# An set of disks to ignore from partitioning and formatting
BLACKLIST="/dev/sda|/dev/sdb"
# Base directory to hold the data* files
DATA_BASE="/media"

usage() {
    echo "Usage: $(basename $0) <new disk>"
}

scan_for_new_disks() {
    # Looks for unpartitioned disks
    declare -a RET
    DEVS=($(ls -1 /dev/sd*|egrep -v "${BLACKLIST}"|egrep -v "[0-9]$"))
    for DEV in "${DEVS[@]}";
    do
        # Check each device if there is a "1" partition.  If not,
        # "assume" it is not partitioned.
        if [ ! -b ${DEV}1 ];
        then
            RET+="${DEV} "
        fi
    done
    echo "${RET}"
}

get_next_mountpoint() {
    DIRS=($(ls -1d ${DATA_BASE}/data* 2>&1| sort --version-sort))
    if [ -z "${DIRS[0]}" ];
    then
        echo "${DATA_BASE}/data1"
        return
    else
        IDX=$(echo "${DIRS[${#DIRS[@]}-1]}"|tr -d "[a-zA-Z/]" )
        IDX=$(( ${IDX} + 1 ))
        echo "${DATA_BASE}/data${IDX}"
    fi
}

add_to_fstab() {
    UUID=${1}
    MOUNTPOINT=${2}
    grep "${UUID}" /etc/fstab >/dev/null 2>&1
    if [ ${?} -eq 0 ];
    then
        echo "Not adding ${UUID} to fstab again (it's already there!)"
    else
        LINE="UUID=\"${UUID}\"\t${MOUNTPOINT}\text4\tnoatime,nodiratime,nodev,noexec,nosuid\t1 2"
        echo -e "${LINE}" >> /etc/fstab
    fi
}

is_partitioned() {
# Checks if there is a valid partition table on the
# specified disk
    OUTPUT=$(sfdisk -l ${1} 2>&1)
    grep "No partitions found" "${OUTPUT}" >/dev/null 2>&1
    return "${?}"       
}

has_filesystem() {
    DEVICE=${1}
    OUTPUT=$(file -L -s ${DEVICE})
    grep filesystem <<< "${OUTPUT}" > /dev/null 2>&1
    return ${?}
}

do_partition() {
# This function creates one (1) primary partition on the
# disk, using all available space
    DISK=${1}
    echo "n
p
1


w"| fdisk "${DISK}" > /dev/null 2>&1

#
# Use the bash-specific $PIPESTATUS to ensure we get the correct exit code
# from fdisk and not from echo
if [ ${PIPESTATUS[1]} -ne 0 ];
then
    echo "An error occurred partitioning ${DISK}" >&2
    echo "I cannot continue" >&2
    exit 2
fi
}

if [ -z "${1}" ];
then
    DISKS=($(scan_for_new_disks))
else
    DISKS=("${@}")
fi
echo "Disks are ${DISKS[@]}"
for DISK in "${DISKS[@]}";
do
    echo "Working on ${DISK}"
    is_partitioned ${DISK}
    if [ ${?} -ne 0 ];
    then
        echo "${DISK} is not partitioned, partitioning"
        do_partition ${DISK}
    fi
    PARTITION=$(fdisk -l ${DISK}|grep -A 1 Device|tail -n 1|awk '{print $1}')
    has_filesystem ${PARTITION}
    if [ ${?} -ne 0 ];
    then
        echo "Creating filesystem on ${PARTITION}."
        #echo "Press Ctrl-C if you don't want to destroy all data on ${PARTITION}"
        #sleep 5
        mkfs -j -t ext4 ${PARTITION}
    fi
    MOUNTPOINT=$(get_next_mountpoint)
    echo "Next mount point appears to be ${MOUNTPOINT}"
    [ -d "${MOUNTPOINT}" ] || mkdir "${MOUNTPOINT}"
    read UUID FS_TYPE < <(blkid -u filesystem ${PARTITION}|awk -F "[= ]" '{print $3" "$5}'|tr -d "\"")
    add_to_fstab "${UUID}" "${MOUNTPOINT}"
    echo "Mounting disk ${PARTITION} on ${MOUNTPOINT}"
    mount "${MOUNTPOINT}"
done

