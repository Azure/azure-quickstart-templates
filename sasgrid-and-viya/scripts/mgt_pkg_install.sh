#!/bin/bash
set -x
echo "*** Phase 2 - Luster configuration on MGS server, Script Started at `date +'%Y-%m-%d_%H-%M-%S'` ***"
## Functions
fail_if_error() {
  [ $1 != 0 ] && {
    echo $2
    exit 10
  }
}

#Variable Declaration
artifact_loc=`facter artifact_loc`

##Installing dependency packages
echo "Installing dependency packages"
yum install asciidoc audit-libs-devel automake bc binutils-devel bison device-mapper-devel elfutils-devel elfutils-libelf-devel expect flex gcc gcc-c++ git glib2 glib2-devel hmaccalc keyutils-libs-devel krb5-devel ksh libattr-devel libblkid-devel libselinux-devel libtool libuuid-devel libyaml-devel lsscsi make ncurses-devel net-snmp-devel net-tools newt-devel numactl-devel parted patchutils pciutils-devel perl-ExtUtils-Embed pesign python-devel redhat-rpm-config rpm-build systemd-devel tcl tcl-devel tk tk-devel wget xmlto yum-utils zlib-devel -y
fail_if_error $? "ERROR: Dependency packages installation failed."

##Downloading the RPM's and installing
cd /opt/lustre-temp/
cp -p /tmp/lustre_server_pkg.zip /opt/lustre-temp/
unzip lustre_server_pkg.zip
cd package
yum localinstall e2fsprogs-1.45.6.wc1-0.el7.x86_64.rpm e2fsprogs-debuginfo-1.45.6.wc1-0.el7.x86_64.rpm e2fsprogs-devel-1.45.6.wc1-0.el7.x86_64.rpm e2fsprogs-libs-1.45.6.wc1-0.el7.x86_64.rpm e2fsprogs-static-1.45.6.wc1-0.el7.x86_64.rpm libcom_err-1.45.6.wc1-0.el7.x86_64.rpm libcom_err-devel-1.45.6.wc1-0.el7.x86_64.rpm libss-1.45.6.wc1-0.el7.x86_64.rpm libss-devel-1.45.6.wc1-0.el7.x86_64.rpm -y
fail_if_error $? "ERROR: Lustre dependency packages installation failed."

yum remove kernel-tools kernel-tools-libs -y
yum localinstall kernel-devel-3.10.0-1062.9.1.el7_lustre.x86_64.rpm kernel-headers-3.10.0-1062.9.1.el7_lustre.x86_64.rpm -y
fail_if_error $? "ERROR: Kernel packages installation failed."
yum install kernel-tools -y
fail_if_error $?  "ERROR: Kernel packages installation failed."


echo "Installing Lustre packages"
yum localinstall kmod-lustre-2.12.4-1.el7.x86_64.rpm kmod-lustre-osd-ldiskfs-2.12.4-1.el7.x86_64.rpm lustre-osd-ldiskfs-mount-2.12.4-1.el7.x86_64.rpm lustre-2.12.4-1.el7.x86_64.rpm lustre-resource-agents-2.12.4-1.el7.x86_64.rpm -y
fail_if_error $? "ERROR: Lustre packages installation failed."

## To verify the Lustre 
modprobe -v lustre
echo "Lustre installation completed"

## MGT Configuration##
## Disable Iptables
crontab -r
iptables -F
ip6tables -F
systemctl disable firewalld
echo "Formating file system and mounting "
modprobe lnet
lctl network configure
lun0=`ls -l /dev/disk/azure/scsi1/lun0 | awk '{print $NF}' | cut -d '/' -f4`
mkfs.lustre --fsname lustre --mgs /dev/$lun0
mkdir -p /opt/mgs
mount.lustre /dev/$lun0 /opt/mgs/
fail_if_error $? "ERROR: failed to mount lustre file system."

echo "*** Phase 2 - Luster configuration on MGS server, Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"
