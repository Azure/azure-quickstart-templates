#!/bin/bash

set -x
#set -xeuo pipefail

if [[ $(id -u) -ne 0 ]] ; then
    echo "Must be run as root"
    exit 1
fi

if [ $# != 8 ]; then
    echo "Usage: $0 <MasterHostname> <mountFolder> <numDataDisks> <dockerVer> <dockerComposeVer> <adminUsername> <imageSku> <dockerMachineVer>"
    exit 1
fi

# Set user args
MASTER_HOSTNAME=$1

# Shares
MNT_POINT="$2"
SHARE_HOME=$MNT_POINT/home
SHARE_DATA=$MNT_POINT/data

numberofDisks="$3"
dockerVer="$4"
dockerComposeVer="$5"
userName="$6"
skuName="$7"
dockMVer="$8"



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
# Creates and exports two shares on the node:
#
# /share/home
# /share/data
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

	if [ "$skuName" == "16.04.0-LTS" ] ; then
	         DEBIAN_FRONTEND=noninteractive apt-get -y \
		  -o DPkg::Options::=--force-confdef \
		 -o DPkg::Options::=--force-confold \
    		install nfs-kernel-server
		/etc/init.d/apparmor stop
		/etc/init.d/apparmor teardown
		update-rc.d -f apparmor remove
		apt-get -y remove apparmor
                systemctl start rpcbind || echo "Already enabled"
                systemctl start nfs-server || echo "Already enabled"
                systemctl start nfs-kernel-server.service
                systemctl enable rpcbind || echo "Already enabled"
                systemctl enable nfs-server || echo "Already enabled"
                systemctl enable nfs-kernel-server.service
        else
                systemctl start rpcbind || echo "Already enabled"
                systemctl start nfs-server || echo "Already enabled"
                systemctl enable rpcbind || echo "Already enabled"
                systemctl enable nfs-server || echo "Already enabled"
         fi


    #else
    #    echo "master:$SHARE_HOME $SHARE_HOME    nfs4    rw,auto,_netdev 0 0" >> /etc/fstab
    #    echo "master:$SHARE_DATA $SHARE_DATA    nfs4    rw,auto,_netdev 0 0" >> /etc/fstab
    #    mount -a
    #    mount | grep "^master:$SHARE_HOME"
    #    mount | grep "^master:$SHARE_DATA"
    #fi
}


set_time()
{
    mv /etc/localtime /etc/localtime.bak
    ln -s /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
}


# System Update.
#
system_update()
{
    rpm --rebuilddb
    updatedb
    yum clean all
    yum -y install epel-release
    yum  -y update --exclude=WALinuxAgent
    #yum  -y update

    set_time
}

install_docker()
{

    wget -qO- "https://pgp.mit.edu/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e"
    rpm --import "https://pgp.mit.edu/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e"
    yum install -y yum-utils
    yum-config-manager --add-repo https://packages.docker.com/$dockerVer/yum/repo/main/centos/7
    yum install -y docker-engine
    systemctl stop firewalld
    systemctl disable firewalld
    #service docker start
    gpasswd -a $userName docker
    systemctl start docker
    systemctl enable docker
    #curl -L https://github.com/docker/compose/releases/download/$dockerComposeVer/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
     curl -L "https://github.com/docker/compose/releases/download/$dockerComposeVer/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose
    curl -L https://github.com/docker/machine/releases/download/v$dockMVer/docker-machine-`uname -s`-`uname -m` >/usr/local/bin/docker-machine
    chmod +x /usr/local/bin/docker-machine
    chmod +x /usr/local/bin/docker-compose
    export PATH=$PATH:/usr/local/bin/
    systemctl restart docker
}

install_azure_cli()
{
    yum install -y nodejs
    yum install -y npm
    npm install -g azure-cli
}

install_docker_apps()
{

    # Setting tomcat
    #docker run -it -dp 80:8080 -p 8009:8009  rossbachp/apache-tomcat8
    docker run -dti --restart=always --name=azure-cli microsoft/azure-cli
    docker run -it -d --restart=always -p 8080:8080 rancher/server
}


# Installs individual packages of interest.
#
install_packages()
{
    yum -y install zlib zlib-devel bzip2 bzip2-devel bzip2-libs openssl openssl-devel openssl-libs  nfs-utils rpcbind git libicu libicu-devel make zip unzip mdadm wget gsl bc rpm-build  readline-devel pam-devel libXtst.i686 libXtst.x86_64 make.x86_64 sysstat.x86_64 python-pip automake autoconf\
    binutils.x86_64 compat-libcap1.x86_64 glibc.i686 glibc.x86_64 \
    ksh compat-libstdc++-33 libaio.i686 libaio.x86_64 libaio-devel.i686 libaio-devel.x86_64 \
    libgcc.i686 libgcc.x86_64 libstdc++.i686 libstdc++.x86_64 libstdc++-devel.i686 libstdc++-devel.x86_64 libXi.i686 libXi.x86_64
    #yum -y install icu patch ruby ruby-devel rubygems  gcc gcc-c++ gcc.x86_64 gcc-c++.x86_64 glibc-devel.i686 glibc-devel.x86_64
}
# Installs all required packages.
#
install_pkgs_all()
{
    system_update

    install_packages

	if [ "$skuName" == "6.5" ] || [ "$skuName" == "6.6" ] ; then
    		install_azure_cli
	elif [ "$skuName" == "7.2" ] || [ "$skuName" == "7.1" ] ; then

    		install_docker

    		install_docker_apps
	fi
}
install_packages_ubuntu()
{

DEBIAN_FRONTEND=noninteractive apt-get install -y zlib1g zlib1g-dev  bzip2 libbz2-dev libssl1.0.0  libssl-doc libssl1.0.0-dbg libsslcommon2 libsslcommon2-dev libssl-dev  nfs-common rpcbind git zip libicu55 libicu-dev icu-devtools unzip mdadm wget gsl-bin libgsl2  bc ruby-dev gcc make autoconf bison build-essential libyaml-dev libreadline6-dev libncurses5 libncurses5-dev libffi-dev libgdbm3 libgdbm-dev libpam0g-dev libxtst6 libxtst6-* libxtst-* libxext6 libxext6-* libxext-* git-core libelf-dev asciidoc binutils-dev fakeroot crash kexec-tools makedumpfile kernel-wedge portmap

DEBIAN_FRONTEND=noninteractive apt-get -y build-dep linux

DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

DEBIAN_FRONTEND=noninteractive update-initramfs -u
}
install_docker_ubuntu()
{

        # System Update and docker version update
         DEBIAN_FRONTEND=noninteractive apt-get -y update
         apt-get install -y apt-transport-https ca-certificates
        #curl -s 'https://sks-keyservers.net/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e' | apt-key add --import
        #echo "deb https://packages.docker.com/$dockerVer/apt/repo ubuntu-trusty main" >> /etc/apt/sources.list.d/docker.list
         apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
	 echo "deb https://packages.docker.com/${dockerVer}/apt/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list
         #echo 'deb https://packages.docker.com/$dockerVer/apt/repo ubuntu-xenial main' > /etc/apt/sources.list.d/docker.list
	 DEBIAN_FRONTEND=noninteractive apt-get -y update
         DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
         apt-cache policy docker-engine
	 groupadd docker
	 usermod -aG docker $userName
         #apt-get install -y docker-engine
	 apt-get install -y --allow-unauthenticated docker-engine
	 /etc/init.d/apparmor stop
	 /etc/init.d/apparmor teardown
	 update-rc.d -f apparmor remove
	 apt-get -y remove apparmor
         #DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated docker-engine
    curl -L https://github.com/docker/compose/releases/download/$dockerComposeVer/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    curl -L https://github.com/docker/machine/releases/download/v$dockMVer/docker-machine-`uname -s`-`uname -m` >/usr/local/bin/docker-machine
    chmod +x /usr/local/bin/docker-machine
    chmod +x /usr/local/bin/docker-compose
    export PATH=$PATH:/usr/local/bin/
    systemctl restart docker
}



	if [ "$skuName" == "16.04.0-LTS" ] ; then
		install_packages_ubuntu
		setup_shares
                install_docker_ubuntu
                install_docker_apps
	elif [ "$skuName" == "6.5" ] || [ "$skuName" == "6.6" ] || [ "$skuName" == "7.2" ] || [ "$skuName" == "7.1" ] ; then
		install_pkgs_all
		setup_shares
	fi
