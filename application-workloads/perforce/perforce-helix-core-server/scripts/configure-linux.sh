#!/bin/bash

# This script is only tested on CentOS 7.x (7.8+), RHEL 7.x (7.8+) and Ubuntu 18.04 LTS.
MOUNTPOINT="/hxdata"

# An set of disks to ignore from partitioning and formatting
BLACKLIST="/dev/sda|/dev/sdb"

LOG=/tmp/init.log

while getopts w:p:s: option
do
  case "${option}"
  in
    w) PASSWORD=${OPTARG};;
    p) P4PORT=${OPTARG};;
    s) SWARMPORT=${OPTARG};;
  esac
done

P4PORT="${P4PORT:-1666}"
SWARMPORT="${SWARMPORT:-80}"
echo "P4PORT: $P4PORT" >> $LOG
echo "SWARMPORT: $SWARMPORT" >> $LOG

check_os() {
    grep ubuntu /proc/version > /dev/null 2>&1
    isubuntu=${?}
    grep centos /proc/version > /dev/null 2>&1
    iscentos=${?}
    grep redhat /proc/version > /dev/null 2>&1
    isredhat=${?}
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

get_disk_count() {
    DISKCOUNT=0
    for DISK in "${DISKS[@]}";
    do
        DISKCOUNT+=1
    done;
    echo "$DISKCOUNT"
}

do_partition() {
# This function creates one (1) primary partition on the
# disk, using all available space
    DISK=${1}
    echo "Partitioning disk $DISK"
    echo "n
p
1


w
" | fdisk "${DISK}"
#> /dev/null 2>&1

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

add_to_fstab() {
    UUID=${1}
    MOUNTPOINT=${2}
    grep "${UUID}" /etc/fstab >/dev/null 2>&1
    if [ ${?} -eq 0 ];
    then
        echo "Not adding ${UUID} to fstab again (it's already there!)"
    else
        LINE="UUID=${UUID} ${MOUNTPOINT} xfs     defaults       0 0"
        echo -e "${LINE}" >> /etc/fstab
    fi
}

configure_disks() {
	ls "${MOUNTPOINT}"
	if [ ${?} -eq 0 ]
	then
		return
	fi
    DISKS=($(scan_for_new_disks))
    echo "Disks are ${DISKS[@]}"
    declare -i DISKCOUNT
    DISKCOUNT=$(get_disk_count)
    echo "Disk count is $DISKCOUNT"
    DISK="${DISKS[0]}"
    do_partition ${DISK}
    PARTITION=$(fdisk -l ${DISK}|grep -A 1 Device|tail -n 1|awk '{print $1}')

    echo "Creating filesystem on ${PARTITION}."
    mkfs -t xfs ${PARTITION}
    mkdir "${MOUNTPOINT}"
    read UUID FS_TYPE < <(blkid -u filesystem ${PARTITION}|awk -F "[= ]" '{print $3" "$5}'|tr -d "\"")
    add_to_fstab "${UUID}" "${MOUNTPOINT}"
    echo "Mounting disk ${PARTITION} on ${MOUNTPOINT}"
    mount "${MOUNTPOINT}"
}

disable_apparmor_ubuntu() {
    /etc/init.d/apparmor teardown
    update-rc.d -f apparmor remove
}

disable_selinux_centos() {
    sed -i 's/^SELINUX=.*/SELINUX=permissive/I' /etc/selinux/config
    setenforce 0
}

configure_network() {
    # open_ports
    if [ $iscentos -eq 0 ];
    then
        disable_selinux_centos
    elif [ $isredhat -eq 0 ];
    then
        disable_selinux_centos
        firewall-cmd --zone=public --add-port="$SWARMPORT/tcp" --permanent
        firewall-cmd --zone=public --add-port="$P4PORT/tcp" --permanent
        firewall-cmd --reload
    elif [ $isubuntu -eq 0 ];
    then
        disable_apparmor_ubuntu
    fi
}


configure_helix() {
    useradd --shell /bin/bash --home-dir /p4 --create-home perforce
    cd "$MOUNTPOINT"
    mkdir hxlogs hxmetadata hxdepots
    chown -R perforce:perforce "$MOUNTPOINT"
    cd /
    ln -s $MOUNTPOINT/hx* .
    chown -h perforce:perforce hx*

    mkdir -p /hxdepots/reset
    cd /hxdepots/reset

    curl -k -s -O https://swarm.workshop.perforce.com/downloads/guest/perforce_software/helix-installer/azure-quickstart/src/arm_install_sdp.sh

    chmod +x arm_install_sdp.sh
    ./arm_install_sdp.sh -p4port "${P4PORT}" -p4adminpass "${PASSWORD}" -swarmport "${SWARMPORT}" > arm_install_sdp.log 2>&1
}

check_os
if [ $iscentos -ne 0 ] && [ $isubuntu -ne 0 ] && [ $isredhat -ne 0 ];
then
    echo "unsupported operating system"
    exit 1
else
    configure_network
    configure_disks
    configure_helix
fi
