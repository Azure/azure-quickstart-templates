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

    curl -k -s -O https://swarm.workshop.perforce.com/downloads/guest/perforce_software/helix-installer/main/src/reset_sdp.sh

    chmod +x reset_sdp.sh
    ./reset_sdp.sh -fast -no_sd > reset_sdp.log 2>&1

    cp /p4/common/bin/p4 /usr/local/bin/
    chmod +x /usr/local/bin/p4

    # Make sure p4d is enabled but broker and p4p are not
    systemctl enable p4d_1
    systemctl disable p4broker_1
    systemctl disable p4p_1

    # Change default port and then generate SSL cert
    sudo -u perforce perl -pi -e "s/P4PORTNUM=1999/P4PORTNUM=$P4PORT/" /p4/common/config/p4_1.vars 
    sudo -u perforce bash -c "source /p4/common/bin/p4_vars 1 && /p4/1/bin/p4d_1 -Gc"
    systemctl start p4d_1
    if [ ! -z "${PASSWORD}" ]; then
        echo "$PASSWORD" > /p4/common/config/.p4passwd.p4_1.admin
    fi

    init_script=/p4/init.sh
cat <<"EOF" >$init_script
#!/bin/bash

source /p4/common/bin/p4_vars 1
p4 trust -y
p4 -p ssl:`hostname`:$P4PORTNUM trust -y
p4 user -o | p4 user -i
p4 protect -o | p4 protect -i

PASSWORD=`cat /p4/common/config/.p4passwd.p4_1.admin`
echo -e "$PASSWORD\n$PASSWORD" | p4 passwd
/p4/common/bin/p4login -v 1
/p4/sdp/Server/setup/configure_new_server.sh 1
crontab /p4/p4.crontab
echo "source /p4/common/bin/p4_vars 1" >> ~/.bashrc
EOF

    chmod +x $init_script
    chown perforce:perforce $init_script
    chmod 666 $LOG
    sudo -u perforce $init_script >> $LOG 2>&1
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
