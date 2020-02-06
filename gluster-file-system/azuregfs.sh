#!/bin/bash

# This script is only tested on CentOS 6.5
# You can customize variables such as MOUNTPOINT, RAIDCHUNKSIZE and so on to your needs.
# You can also customize it to work with other Linux flavours and versions.
# If you customize it, copy it to either Azure blob storage or Github so that Azure
# custom script Linux VM extension can access it, and specify its location in the
# parameters of powershell script or runbook or Azure Resource Manager CRP template.

NODENAME=$(hostname)
PEERNODEPREFIX=${1}
PEERNODEIPPREFIX=${2}
VOLUMENAME=${3}
NODEINDEX=${4}
NODECOUNT=${5}

MOUNTPOINT="/datadrive"
RAIDCHUNKSIZE=128

RAIDDISK="/dev/md127"
RAIDPARTITION="/dev/md127p1"
# An set of disks to ignore from partitioning and formatting
BLACKLIST="/dev/sda|/dev/sdb"

check_os() {
    grep ubuntu /proc/version > /dev/null 2>&1
    isubuntu=${?}
    grep centos /proc/version > /dev/null 2>&1
    iscentos=${?}
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

create_raid0_ubuntu() {
    dpkg -s mdadm
    if [ ${?} -eq 1 ];
    then
        echo "installing mdadm"
        wget --no-cache http://mirrors.cat.pdx.edu/ubuntu/pool/main/m/mdadm/mdadm_3.2.5-5ubuntu4_amd64.deb
        dpkg -i mdadm_3.2.5-5ubuntu4_amd64.deb
    fi
    echo "Creating raid0"
    udevadm control --stop-exec-queue
    echo "yes" | mdadm --create "$RAIDDISK" --name=data --level=0 --chunk="$RAIDCHUNKSIZE" --raid-devices="$DISKCOUNT" "${DISKS[@]}"
    udevadm control --start-exec-queue
    mdadm --detail --verbose --scan > /etc/mdadm.conf
}

create_raid0_centos() {
    echo "Creating raid0"
    yes | mdadm --create "$RAIDDISK" --name=data --level=0 --chunk="$RAIDCHUNKSIZE" --raid-devices="$DISKCOUNT" "${DISKS[@]}"
    mdadm --detail --verbose --scan > /etc/mdadm.conf
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
        LINE="UUID=${UUID} ${MOUNTPOINT} ext4 defaults,noatime 0 0"
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
    if [ $DISKCOUNT -gt 1 ];
    then
        if [ $iscentos -eq 0 ];
        then
            create_raid0_centos
        elif [ $isubuntu -eq 0 ];
        then
            create_raid0_ubuntu
        fi
        do_partition ${RAIDDISK}
        PARTITION="${RAIDPARTITION}"
    else
        DISK="${DISKS[0]}"
        do_partition ${DISK}
        PARTITION=$(fdisk -l ${DISK}|grep -A 1 Device|tail -n 1|awk '{print $1}')
    fi

    echo "Creating filesystem on ${PARTITION}."
    mkfs -t ext4 ${PARTITION}
    mkdir "${MOUNTPOINT}"
    read UUID FS_TYPE < <(blkid -u filesystem ${PARTITION}|awk -F "[= ]" '{print $3" "$5}'|tr -d "\"")
    add_to_fstab "${UUID}" "${MOUNTPOINT}"
    echo "Mounting disk ${PARTITION} on ${MOUNTPOINT}"
    mount "${MOUNTPOINT}"
}

open_ports() {
    index=0
    while [ $index -lt $NODECOUNT ]; do
        if [ $index -ne $NODEINDEX ]; then
            iptables -I INPUT -p all -s "${PEERNODEIPPREFIX}${index}" -j ACCEPT
            echo "${PEERNODEIPPREFIX}${index}    ${PEERNODEPREFIX}${index}" >> /etc/hosts
        else
            echo "127.0.0.1    ${PEERNODEPREFIX}${index}" >> /etc/hosts
        fi
        let index++
    done
    iptables-save
}

disable_apparmor_ubuntu() {
    /etc/init.d/apparmor teardown
    update-rc.d -f apparmor remove
}

disable_selinux_centos() {
    sed -i 's/^SELINUX=.*/SELINUX=disabled/I' /etc/selinux/config
    setenforce 0
}

activate_secondnic_centos() {
    if [ -n "$SECONDNIC" ];
    then
        cp /etc/sysconfig/network-scripts/ifcfg-eth0 "/etc/sysconfig/network-scripts/ifcfg-${SECONDNIC}"
        sed -i "s/^DEVICE=.*/DEVICE=${SECONDNIC}/I" "/etc/sysconfig/network-scripts/ifcfg-${SECONDNIC}"
        defaultgw=$(ip route show |sed -n "s/^default via //p")
        declare -a gateway=(${defaultgw// / })
        sed -i "\$aGATEWAY=${gateway[0]}" /etc/sysconfig/network
        service network restart
    fi
}

activate_secondnic_ubuntu() {
    if [ -n "$SECONDNIC" ];
    then
        echo "" >> /etc/network/interfaces
        echo "auto $SECONDNIC" >> /etc/network/interfaces
        echo "iface $SECONDNIC inet dhcp" >> /etc/network/interfaces
        defaultgw=$(ip route show |sed -n "s/^default via //p")
        declare -a gateway=(${defaultgw// / })
        echo "" >> /etc/network/interfaces
        echo "post-up ip route add default via $gateway" >> /etc/network/interfaces
        /etc/init.d/networking restart
    fi
}

configure_network() {
    open_ports
    if [ $iscentos -eq 0 ];
    then
        activate_secondnic_centos
        disable_selinux_centos
    elif [ $isubuntu -eq 0 ];
    then
        activate_secondnic_ubuntu
        disable_apparmor_ubuntu
    fi
}

install_glusterfs_ubuntu() {
    dpkg -l | grep glusterfs
    if [ ${?} -eq 0 ];
    then
        return
    fi

    if [ ! -e /etc/apt/sources.list.d/gluster* ];
    then
        echo "adding gluster ppa"
        apt-get  -y install python-software-properties
        apt-add-repository -y ppa:gluster/glusterfs-3.7
        apt-get -y update
    fi

    echo "installing gluster"
    apt-get -y install glusterfs-server

    return
}

install_glusterfs_centos() {
    yum list installed glusterfs-server
    if [ ${?} -eq 0 ];
    then
        return
    fi

    if [ ! -e /etc/yum.repos.d/epel.repo ];
    then
        echo "Installing extra packages for enterprise linux"
        wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
        rpm -Uvh ./epel-release-latest-6*.rpm
        rm ./epel-release-latest-6*.rpm
        yum -y update
    fi

    echo "installing gluster"
    wget --no-cache http://download.gluster.org/pub/gluster/glusterfs/LATEST/EPEL.repo/glusterfs-epel.repo
    mv glusterfs-epel.repo  /etc/yum.repos.d/
    yum -y update
    yum -y install glusterfs-cli glusterfs-geo-replication glusterfs-fuse glusterfs-server glusterfs
}

configure_gluster() {
    if [ $iscentos -eq 0 ];
    then
        /etc/init.d/glusterd status
        if [ ${?} -ne 0 ];
        then
            install_glusterfs_centos
        fi
        /etc/init.d/glusterd start
    elif [ $isubuntu -eq 0 ];
    then
        /etc/init.d/glusterfs-server status
        if [ ${?} -ne 0 ];
        then
            install_glusterfs_ubuntu
        fi
        /etc/init.d/glusterfs-server start
    fi

    GLUSTERDIR="${MOUNTPOINT}/brick"
    ls "${GLUSTERDIR}"
    if [ ${?} -ne 0 ];
    then
        mkdir "${GLUSTERDIR}"
    fi

    if [ $NODEINDEX -lt $(($NODECOUNT-1)) ];
    then
        return
    fi

    allNodes="${NODENAME}:${GLUSTERDIR}"
    retry=10
    failed=1
    while [ $retry -gt 0 ] && [ $failed -gt 0 ]; do
        failed=0
        index=0
        echo retrying $retry >> /tmp/error
        while [ $index -lt $(($NODECOUNT-1)) ]; do
            ping -c 3 "${PEERNODEPREFIX}${index}" > /tmp/error
            gluster peer probe "${PEERNODEPREFIX}${index}" >> /tmp/error
            if [ ${?} -ne 0 ];
            then
                failed=1
                echo "gluster peer probe ${PEERNODEPREFIX}${index} failed"
            fi
            gluster peer status >> /tmp/error
            gluster peer status | grep "${PEERNODEPREFIX}${index}" >> /tmp/error
            if [ ${?} -ne 0 ];
            then
                failed=1
                echo "gluster peer status ${PEERNODEPREFIX}${index} failed"
            fi
            if [ $retry -eq 10 ]; then
                allNodes="${allNodes} ${PEERNODEPREFIX}${index}:${GLUSTERDIR}"
            fi
            let index++
        done
        sleep 30
        let retry--
    done

    sleep 60
    gluster volume create ${VOLUMENAME} rep 2 transport tcp ${allNodes} 2>> /tmp/error
    gluster volume info 2>> /tmp/error
    gluster volume start ${VOLUMENAME} 2>> /tmp/error
}

allow_passwordssh() {
    grep -q '^PasswordAuthentication yes' /etc/ssh/sshd_config
    if [ ${?} -eq 0 ];
    then
        return
    fi
    sed -i "s/^#PasswordAuthentication.*/PasswordAuthentication yes/I" /etc/ssh/sshd_config
    sed -i "s/^PasswordAuthentication no.*/PasswordAuthentication yes/I" /etc/ssh/sshd_config
    if [ $iscentos -eq 0 ];
    then
        /etc/init.d/sshd reload
    elif [ $isubuntu -eq 0 ];
    then
        /etc/init.d/ssh reload
    fi
}

check_os

# temporary workaround form CRP
allow_passwordssh

if [ $iscentos -ne 0 ] && [ $isubuntu -ne 0];
then
    echo "unsupported operating system"
    exit 1
else
    configure_network
    configure_disks
    configure_gluster
fi

