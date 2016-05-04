#!/bin/bash

set -x
#set -xeuo pipefail

if [[ $(id -u) -ne 0 ]] ; then
    echo "Must be run as root"
    exit 1
fi

if [ $# != 4 ]; then
    echo "Usage: $0 <MasterHostname> <TemplateBaseUrl> <mountFolder> <numDataDisks>"
    exit 1
fi

# Set user args
MASTER_HOSTNAME=$1
TEMPLATE_BASE_URL="$2"

# Shares
MNT_POINT="$3"
SHARE_HOME=$MNT_POINT/home
SHARE_DATA=$MNT_POINT/data

numberofDisks="$4"


# Installs all required packages.
#
install_pkgs()
{
    rpm --rebuilddb
    updatedb
    yum clean all
    yum -y install epel-release
    yum  -y update --exclude=WALinuxAgent
    yum -y install zlib zlib-devel bzip2 bzip2-devel bzip2-libs openssl openssl-devel openssl-libs gcc gcc-c++ nfs-utils rpcbind git libicu libicu-devel make wget zip unzip mdadm wget
    wget -qO- "https://pgp.mit.edu/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e" 
    rpm --import "https://pgp.mit.edu/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e"
    yum install -y yum-utils
    yum-config-manager --add-repo https://packages.docker.com/1.10/yum/repo/main/centos/7
    yum install -y docker-engine 
    systemctl stop firewalld
    systemctl disable firewalld
    service docker start
    wget https://storage.googleapis.com/golang/go1.6.2.linux-amd64.tar.gz
    tar -C /usr/local -xzf go1.6.2.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    yum install -y binutils.x86_64 compat-libcap1.x86_64 gcc.x86_64 gcc-c++.x86_64 glibc.i686 glibc.x86_64 \
    glibc-devel.i686 glibc-devel.x86_64 ksh compat-libstdc++-33 libaio.i686 libaio.x86_64 libaio-devel.i686 libaio-devel.x86_64 \
    libgcc.i686 libgcc.x86_64 libstdc++.i686 libstdc++.x86_64 libstdc++-devel.i686 libstdc++-devel.x86_64 libXi.i686 libXi.x86_64 \
    libXtst.i686 libXtst.x86_64 make.x86_64 sysstat.x86_64
    curl -L https://github.com/docker/compose/releases/download/1.6.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    curl -L https://github.com/docker/machine/releases/download/v0.7.0-rc1/docker-machine-`uname -s`-`uname -m` >/usr/local/bin/docker-machine && \
    chmod +x /usr/local/bin/docker-machine
    chmod +x /usr/local/bin/docker-compose
    export PATH=$PATH:/usr/local/bin/
    mv /etc/localtime /etc/localtime.bak
    ln -s /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
    #yum -y install icu patch ruby ruby-devel rubygems python-pip
    #yum install -y nodejs
    #yum install -y npm
    #npm install -g azure-cli
    # Setting tomcat
    #docker run -it -dp 80:8080 -p 8009:8009  rossbachp/apache-tomcat8
    docker run -dti --name=azure-cli microsoft/azure-cli 
    docker run -it -d --restart=always -p 8080:8080 rancher/server
    systemctl enable docker
    #yum groupinstall -y "Infiniband Support"
    #yum install -y infiniband-diags perftest qperf opensm
    #chkconfig opensm on
    #chkconfig rdma on
    #reboot
}


setup_dynamicdata_disks()
{
    mountPoint="$1"
    createdPartitions=""

    # Loop through and partition disks until not found

if [ "$numberofDisks" == "1" ]
then
   disking=( sdc )
elif [ "$numberofDisks" == "2" ]; then
   disking=( sdc sdd )
elif [ "$numberofDisks" == "3" ]; then
   disking=( sdc sdd sde )
elif [ "$numberofDisks" == "4" ]; then
   disking=( sdc sdd sde sdf )
elif [ "$numberofDisks" == "5" ]; then
   disking=( sdc sdd sde sdf sdg )
elif [ "$numberofDisks" == "6" ]; then
   disking=( sdc sdd sde sdf sdg sdh )
elif [ "$numberofDisks" == "7" ]; then
   disking=( sdc sdd sde sdf sdg sdh sdi )
elif [ "$numberofDisks" == "8" ]; then
   disking=( sdc sdd sde sdf sdg sdh sdi sdj )
elif [ "$numberofDisks" == "9" ]; then
   disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk )
elif [ "$numberofDisks" == "10" ]; then
   disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl )
elif [ "$numberofDisks" == "11" ]; then
   disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm )
elif [ "$numberofDisks" == "12" ]; then
   disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn )
elif [ "$numberofDisks" == "13" ]; then
   disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo )
elif [ "$numberofDisks" == "14" ]; then
   disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp )
elif [ "$numberofDisks" == "15" ]; then
   disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq )
elif [ "$numberofDisks" == "16" ]; then
   disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr )
fi

printf "%s\n" "${disking[@]}"

for disk in "${disking[@]}"
do
        fdisk -l /dev/$disk || break
        fdisk /dev/$disk << EOF
n
p
1


t
fd
w
EOF
        createdPartitions="$createdPartitions /dev/${disk}1"
done

    # Create RAID-0 volume
    if [ -n "$createdPartitions" ]; then
        devices=`echo $createdPartitions | wc -w`
        mdadm --create /dev/md10 --level 0 --raid-devices $devices $createdPartitions
        mkfs -t ext4 /dev/md10
        echo "/dev/md10 $mountPoint ext4 defaults,nofail 0 2" >> /etc/fstab
        mount /dev/md10
    fi
}
# Creates and exports two shares on the master nodes:
#
# /share/home (for HPC user)
# /share/data
#
# These shares are mounted on all worker nodes.
#
setup_shares()
{
    mkdir -p $SHARE_HOME
    mkdir -p $SHARE_DATA

   # if is_master; then
        #setup_data_disks $SHARE_DATA
	setup_dynamicdata_disks $SHARE_DATA
        echo "$SHARE_HOME    *(rw,async)" >> /etc/exports
        echo "$SHARE_DATA    *(rw,async)" >> /etc/exports

        systemctl enable rpcbind || echo "Already enabled"
        systemctl enable nfs-server || echo "Already enabled"
        systemctl start rpcbind || echo "Already enabled"
        systemctl start nfs-server || echo "Already enabled"
    #else
    #    echo "master:$SHARE_HOME $SHARE_HOME    nfs4    rw,auto,_netdev 0 0" >> /etc/fstab
    #    echo "master:$SHARE_DATA $SHARE_DATA    nfs4    rw,auto,_netdev 0 0" >> /etc/fstab
    #    mount -a
    #    mount | grep "^master:$SHARE_HOME"
    #    mount | grep "^master:$SHARE_DATA"
    #fi
}


setup_shares
install_pkgs

