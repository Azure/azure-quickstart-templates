#!/bin/bash

# ./lustre_client.sh -n CLIENTCENTOS7.0 -i 0 -d 0 -m 10.1.0.4 -l 10.1.0.7 -f scratch

log()
{
	echo "$1"
	logger "$1"
}

# Initialize local variables
# Get today's date into YYYYMMDD format
NOW=$(date +"%Y%m%d")
FILESYSTEMSTRIPECOUNT=-1

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
		log $LINE
		echo -e "${line}" >> /etc/fstab
	fi
}

install_lustre_centos66()
{
	# Install wget and dstat
	yum install -y wget dstat

	# Update certificates to prevent wget download errors
	yum update -y ca-certificates

	# Install pdsh since it is convenient for managing multiple client hosts later
	# RHEL/CentOS 6 64-Bit ##
	wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	rpm -ivh epel-release-6-8.noarch.rpm
	yum install -y pdsh

	# Download stable Lustre client source targeting specific CentOS 6.6 kernel
	# This code will be used to create the RPM for the currently running kernel
	wget https://downloads.whamcloud.com/public/lustre/lustre-2.7.0/el6.6/client/SRPMS/lustre-client-2.7.0-2.6.32_504.8.1.el6.x86_64.src.rpm

	# Download current kernel-devel package from CentOS vault
	wget --tries 10 --retry-connrefused --waitretry 15 http://vault.centos.org/6.6/updates/x86_64/Packages/kernel-devel-$(uname -r).rpm
	if [ ! -f  kernel-devel-$(uname -r).rpm ]; then
		# Try /os/
		wget --tries 10 --retry-connrefused --waitretry 15  http://vault.centos.org/6.6/os/x86_64/Packages/kernel-devel-$(uname -r).rpm
	fi

	# Install the downloaded kernel-devel package that is needed to recompile the Lustre client modules
	yum --nogpgcheck localinstall -y kernel-devel-$(uname -r).rpm

	# Install the other packages necessary to recompile the Lustre client
	# Documentation is here https://wiki.hpdd.intel.com/display/PUB/Rebuilding+the+Lustre-client+rpms+for+a+new+kernel
	yum install -y rpm-build make libtool libselinux-devel

	# Rebuild the downloaded Lustre client RPM for the currently running kernel
	rpmbuild --define "_topdir /root/rpmbuild" --rebuild --without servers lustre-client-2.7.0-2.6.32_504.8.1.el6.x86_64.src.rpm

	# Install the compiled RPM whose file names are based on the currently running kernel but with - replaced by _ (e.g. lustre-client-2.7.0-2.6.32_504.30.3.el6.x86_64.x86_64.rpm)
	cd /root/rpmbuild/RPMS/x86_64/
	yum --nogpgcheck localinstall -y lustre-client-2.7.0-$(uname -r | sed 's/-/_/').x86_64.rpm lustre-client-modules-2.7.0-$(uname -r | sed 's/-/_/').x86_64.rpm

	modprobe lustre

	# To prevent the current kernel from being updated, add the following exclude line to [base] and [updates] in CentOS-Base.repo
	exclude="exclude = kernel kernel-headers kernel-devel kernel-debug-devel"
	sed "/\[base\]/a ${exclude}" -i /etc/yum.repos.d/CentOS-Base.repo
	sed "/\[updates\]/a ${exclude}" -i /etc/yum.repos.d/CentOS-Base.repo
	sed "/\[openlogic\]/a ${exclude}" -i /etc/yum.repos.d/OpenLogic.repo
}

install_lustre_centos70()
{
	# Install wget and dstat
	yum install -y wget dstat

	# Update certificates to prevent wget download errors
	yum update -y ca-certificates

	# Download stable Lustre client source targeting specific CentOS 7.0 kernel
	# This code will be used to create the RPM for the currently running kernel
	wget https://downloads.whamcloud.com/public/lustre/lustre-2.7.0/el7/client/SRPMS/lustre-client-2.7.0-3.10.0_123.20.1.el7.x86_64.src.rpm

	# Download current kernel-devel package from CentOS vault
	wget --tries 10 --retry-connrefused --waitretry 15 http://vault.centos.org/7.0.1406/updates/x86_64/Packages/kernel-devel-$(uname -r).rpm
	if [ ! -f  kernel-devel-$(uname -r).rpm ]; then
		# Try /os/
		wget --tries 10 --retry-connrefused --waitretry 15 http://vault.centos.org/7.0.1406/os/x86_64/Packages/kernel-devel-$(uname -r).rpm
	fi

	# Install the downloaded kernel-devel package that is needed to recompile the Lustre client modules
	yum --nogpgcheck localinstall -y kernel-devel-$(uname -r).rpm

	# Install the other packages necessary to recompile the Lustre client
	# Documentation is here https://wiki.hpdd.intel.com/display/PUB/Rebuilding+the+Lustre-client+rpms+for+a+new+kernel
	yum install -y rpm-build make libtool libselinux-devel

	# Rebuild the downloaded Lustre client RPM for the currently running kernel
	rpmbuild --define "_topdir /root/rpmbuild" --rebuild --without servers lustre-client-2.7.0-3.10.0_123.20.1.el7.x86_64.src.rpm

	# Install the compiled RPM whose file names are based on the currently running kernel but with - replaced by _ (e.g. )
	cd /root/rpmbuild/RPMS/x86_64/
	yum --nogpgcheck localinstall -y lustre-client-2.7.0-$(uname -r | sed 's/-/_/').x86_64.rpm lustre-client-modules-2.7.0-$(uname -r | sed 's/-/_/').x86_64.rpm

	modprobe lustre

	# To prevent the current kernel from being updated, add the following exclude line to [base] and [updates] in CentOS-Base.repo
	exclude="exclude = kernel kernel-headers kernel-devel kernel-debug-devel"
	sed "/\[base\]/a ${exclude}" -i /etc/yum.repos.d/CentOS-Base.repo
	sed "/\[updates\]/a ${exclude}" -i /etc/yum.repos.d/CentOS-Base.repo
	sed "/\[openlogic\]/a ${exclude}" -i /etc/yum.repos.d/OpenLogic.repo
}

install_lustre_centos_hpc_65()
{
	# Install wget and dstat
	yum install -y wget dstat

	# Update certificates to prevent wget download errors
	yum update -y ca-certificates

	# Install pdsh since it is convenient for managing multiple client hosts later
	# RHEL/CentOS 6 64-Bit ##
	wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	rpm -ivh epel-release-6-8.noarch.rpm
	yum install -y pdsh

	# Download stable Lustre client source targeting specific CentOS 6.5 kernel
	# This code will be used to create the RPM for the currently running kernel
	wget https://downloads.whamcloud.com/public/lustre/lustre-2.7.0/el6.6/client/SRPMS/lustre-client-2.7.0-2.6.32_504.8.1.el6.x86_64.src.rpm

	# Download current kernel-devel package from CentOS vault
	wget --tries 10 --retry-connrefused --waitretry 15 http://vault.centos.org/6.5/updates/x86_64/Packages/kernel-devel-$(uname -r).rpm
	if [ ! -f  kernel-devel-$(uname -r).rpm ]; then
		# Try /os/
		wget --tries 10 --retry-connrefused --waitretry 15 http://vault.centos.org/6.5/os/x86_64/Packages/kernel-devel-$(uname -r).rpm
	fi

	# Un-exclude kernel updates in /etc/yum.conf
	sed "s/exclude=/#exclude=/g" -i /etc/yum.conf

	# Install the downloaded kernel-devel package that is needed to recompile the Lustre client modules
	yum --nogpgcheck localinstall -y kernel-devel-$(uname -r).rpm

	# Install the other packages necessary to recompile the Lustre client
	# Documentation is here https://wiki.hpdd.intel.com/display/PUB/Rebuilding+the+Lustre-client+rpms+for+a+new+kernel
	yum install -y rpm-build make libtool libselinux-devel

	# Rebuild the downloaded Lustre client RPM for the currently running kernel
	rpmbuild --define "_topdir /root/rpmbuild" --rebuild --without servers lustre-client-2.7.0-2.6.32_504.8.1.el6.x86_64.src.rpm

	# Install the compiled RPM whose file names are based on the currently running kernel but with - replaced by _ (e.g. )
	cd /root/rpmbuild/RPMS/x86_64/
	yum --nogpgcheck localinstall -y lustre-client-2.7.0-$(uname -r | sed 's/-/_/').x86_64.rpm lustre-client-modules-2.7.0-$(uname -r | sed 's/-/_/').x86_64.rpm

	modprobe lustre

	# To prevent the current kernel from being updated, add the following exclude line to [base] and [updates] in CentOS-Base.repo
	exclude="exclude = kernel kernel-headers kernel-devel kernel-debug-devel"
	sed "/\[base\]/a ${exclude}" -i /etc/yum.repos.d/CentOS-Base.repo
	sed "/\[updates\]/a ${exclude}" -i /etc/yum.repos.d/CentOS-Base.repo
	sed "/\[openlogic\]/a ${exclude}" -i /etc/yum.repos.d/OpenLogic.repo

	# Again exclude kernel updates in /etc/yum.conf
	sed "s/#exclude=/exclude=/g" -i /etc/yum.conf
}

install_lustre_centos_hpc_71()
{
	# Install wget and dstat
	yum install -y wget dstat

	# Update certificates to prevent wget download errors
	yum update -y ca-certificates

	# Download stable Lustre client source targeting specific CentOS 7.0 kernel
	# This code will be used to create the RPM for the currently running kernel
	wget https://downloads.whamcloud.com/public/lustre/lustre-2.7.0/el7/client/SRPMS/lustre-client-2.7.0-3.10.0_123.20.1.el7.x86_64.src.rpm

	# Download current kernel-devel package from CentOS vault
	wget --tries 10 --retry-connrefused --waitretry 15 http://vault.centos.org/7.1.1503/updates/x86_64/Packages/kernel-devel-$(uname -r).rpm
	if [ ! -f  kernel-devel-$(uname -r).rpm ]; then
		# Try /os/
		wget --tries 10 --retry-connrefused --waitretry 15 http://vault.centos.org/7.1.1503/os/x86_64/Packages/kernel-devel-$(uname -r).rpm
	fi

	# Un-exclude kernel updates in /etc/yum.conf
	sed "s/exclude=/#exclude=/g" -i /etc/yum.conf

	# Install the downloaded kernel-devel package that is needed to recompile the Lustre client modules
	yum --nogpgcheck localinstall -y kernel-devel-$(uname -r).rpm

	# Install the other packages necessary to recompile the Lustre client
	# Documentation is here https://wiki.hpdd.intel.com/display/PUB/Rebuilding+the+Lustre-client+rpms+for+a+new+kernel
	yum install -y rpm-build make libtool libselinux-devel

	# Rebuild the downloaded Lustre client RPM for the currently running kernel
	rpmbuild --define "_topdir /root/rpmbuild" --rebuild --without servers lustre-client-2.7.0-3.10.0_123.20.1.el7.x86_64.src.rpm

	# Install the compiled RPM whose file names are based on the currently running kernel but with - replaced by _ (e.g. )
	cd /root/rpmbuild/RPMS/x86_64/
	yum --nogpgcheck localinstall -y lustre-client-2.7.0-$(uname -r | sed 's/-/_/').x86_64.rpm lustre-client-modules-2.7.0-$(uname -r | sed 's/-/_/').x86_64.rpm

	modprobe lustre

	# To prevent the current kernel from being updated, add the following exclude line to [base] and [updates] in CentOS-Base.repo
	exclude="exclude = kernel kernel-headers kernel-devel kernel-debug-devel"
	sed "/\[base\]/a ${exclude}" -i /etc/yum.repos.d/CentOS-Base.repo
	sed "/\[updates\]/a ${exclude}" -i /etc/yum.repos.d/CentOS-Base.repo
	sed "/\[openlogic\]/a ${exclude}" -i /etc/yum.repos.d/OpenLogic.repo

	# Again exclude kernel updates in /etc/yum.conf
	sed "s/#exclude=/exclude=/g" -i /etc/yum.conf
}

create_client() {
	log "Create Lustre CLIENT"

	device=$MGSIP@tcp:/$FILESYSTEMNAME
	log "DEVICE $device"

	mount_point=/mnt/$FILESYSTEMNAME
	log "MOUNT_POINT $mount_point"

	mkdir -p $mount_point
	add_to_fstab $device $mount_point
	retry 5 mount -a

	# Create test file
	dd if=/dev/zero of=$mount_point/test_$(hostname).dat bs=1M count=200

	cd $mount_point
	ls -lsah

	# Display stripe configuration
	lfs getstripe $mount_point

	# Display free space
	lfs df -h
}

if [ "$NODETYPE" == "OpenLogic:CentOS:6.6" ]; then
	install_lustre_centos66
	create_client
fi

if [ "$NODETYPE" == "OpenLogic:CentOS:7.0" ]; then
	install_lustre_centos70
	create_client
fi

if [ "$NODETYPE" == "OpenLogic:CentOS-HPC:6.5" ]; then
	install_lustre_centos_hpc_65
	create_client
fi

if [ "$NODETYPE" == "OpenLogic:CentOS-HPC:7.1" ]; then
	install_lustre_centos_hpc_71
	create_client
fi
