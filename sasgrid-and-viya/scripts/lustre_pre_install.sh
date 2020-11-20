#!/bin/bash
set -x

## Functions
fail_if_error() {
  [ $1 != 0 ] && {
    echo $2
    exit 10
  }
}

## Basic Pre Reqs for the SAS
yum install ruby wget -y
wget http://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/f/facter-2.4.1-1.el7.x86_64.rpm
rpm  --reinstall -vh facter-2.*.rpm
fail_if_error $? "ERROR: Facter packages installation failed."

##Facter Variables and Declaration
environmentLocation="/etc/facter/facts.d/variables.txt"
if [ -f $environmentLocation ]; then
	rm -f $environmentLocation
fi

cat << EOF > $environmentLocation
artifact_loc=$1
mgt_vm_name=$2
index_value=$3
EOF

#Varibales
artifact_loc=`facter artifact_loc`

#ADD Users
cat /etc/group |grep -wiq sas
if [ $? -eq 0 ]; then
   echo "SAS Group exists"
else
   groupadd -g 5001 sas
fi
 
username=("sasinst" "sassrv" "sasdemo" "lsfadmin")
userid=("1002" "1003" "1005" "1006")
for ((i=0;i<${#username[@]};++i));
do
    if [ ! -f /home/${username[$i]} ]; then
        useradd -u ${userid[$i]} -g sas ${username[$i]}
        fail_if_error $? "ERROR: failed to create ${username[$i]} User"
        #echo ${sasextpw} | passwd ${username[$i]} --stdin
    else 
        echo "User ${username[$i]} exists"
    fi
done
echo "**************SAS Admin Users created successfully.***************"



## Creating the repo configuration for dowloading all the rpm packages based on the server version
cat >/tmp/lustre-repo.conf <<\__EOF
[lustre-server]
name=lustre-server
baseurl=https://downloads.whamcloud.com/public/lustre/lustre-2.12.4/el7.7.1908/server
gpgcheck=0
[lustre-client]
name=lustre-client
baseurl=https://downloads.whamcloud.com/public/lustre/lustre-2.12.4/el7.7.1908/client
gpgcheck=0
[e2fsprogs-wc]
name=e2fsprogs-wc
baseurl=https://downloads.whamcloud.com/public/e2fsprogs/latest/el7
gpgcheck=0
__EOF
echo "Repo configured"

sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/sysconfig/selinux
## Installing dependency packages
yum install createrepo yum-utils cifs-utils  nfs-utils -y
fail_if_error $? "ERROR: Dependency packages installation failed."


# Downloading all the rpm packegs required for the lustre
mkdir -p  /opt/lustre-temp/
cd /opt/lustre-temp/
cp -p /tmp/lustre_packages.zip /opt/lustre-temp/
unzip lustre_packages.zip

echo "Downloading and installing kernel dependency packages"
yum localinstall resource-agents-4.1.1-46.el7.x86_64.rpm psmisc-22.20-16.el7.x86_64.rpm -y
fail_if_error $? "ERROR: failed to install kernel dependency packages."

## Please check the kernel only rpm package kernel-3.* In My case it is 3.
yum localinstall kernel-3.10.0-1062.9.1.el7_lustre.x86_64.rpm  -y
fail_if_error $? "ERROR: Kernel installation failed."


yum install xorg-x11-xauth.x86_64 xorg-x11-server-utils.x86_64 dbus-x11.x86_64 -y
fail_if_error $? "ERROR: RHEL Package installation failed."

echo  "options lnet networks=tcp" >> /etc/modprobe.d/lustre.conf
echo "Rebooting the system."
echo  "* * * * * sleep 10;/sbin/shutdown -r now" >> /var/spool/cron/root
echo "@reboot crontab -r" >> /var/spool/cron/root

echo "*** Phase 1 - Luster pre-req Install Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"
