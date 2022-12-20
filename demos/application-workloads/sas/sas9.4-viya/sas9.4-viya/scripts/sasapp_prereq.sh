#/bin/bash
set -x
echo "*** Phase 1 - Pre-Reqs Script Started at `date +'%Y-%m-%d_%H-%M-%S'` ***"

## Functions
fail_if_error() {
  [ $1 != 0 ] && {
    echo $2
    exit 10
  }
}

##Installing facter tool
yum install ruby wget -y
wget http://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/f/facter-2.4.1-1.el7.x86_64.rpm
rpm  --reinstall -vh facter-2.*.rpm
fail_if_error $? "Error: Facter installation failed"

#Facter Variables and Declaration
environmentLocation="/etc/facter/facts.d/variables.txt"

if [ -f $environmentLocation ]; then
	rm -f $environmentLocation
fi

cat << EOF > $environmentLocation
application_name=$1
sasdepot_folder=$2
file_share_name=$3
storage_account_name=$4
domain_name=$5
location=$6
sasint_secret_name=$7
sasext_secret_name=$8
key_vault_name=$9
pvt_keyname=${10}
pub_keyname=${11}
mid_name=${12}
meta_name=${13}
compute_name=${14}
sas_sid=${15}
sas_role=${16}
artifact_loc=${17}
stgacc_secr_name=${18}
cifs_server_fqdn=${19}
mid_hostname=${1}${12}
meta_hostname=${1}${13}
compute_hostname=${1}${14}
EOF


#Updating the Azure Cli Repo
rpm --import https://packages.microsoft.com/keys/microsoft.asc;sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
# Installing the azure CLI
yum install azure-cli -y
fail_if_error $? "Error: Azure cli installation failed"

#Stop & Disable the firewalld(Iptables)
systemctl stop firewalld
systemctl disable firewalld

meta_hostname=`facter meta_hostname`
mid_hostname=`facter mid_hostname`
compute_hostname=`facter compute_hostname`
domain_name=`facter domain_name`
sas_role=`facter sas_role`
sas_home="/opt/sas"


hostname_setup() {
	hostnamectl set-hostname --static ${1}.${domain_name}
	if [ $? -eq 0 ]; then
    	echo "hostname update successful"
    	if [ -f /etc/hostname ]; then
        	chattr -i /etc/hostname
        	rm -f /etc/hostname
        	echo ${1}.${domain_name} > /etc/hostname
        	chattr +i /etc/hostname
    	fi
    	if [ -f /etc/sysconfig/network ]; then
    	    echo "HOSTNAME=${1}.${domain_name}" >> /etc/sysconfig/network
    	fi
   		echo "Restart Network Service"
   		/etc/init.d/network restart
	else
 	   echo "Hostname Update failed"
fi
}

if [ $sas_role == meta ]; then
	hostname_setup $meta_hostname
elif [ $sas_role == mid ]; then
	hostname_setup $mid_hostname
elif [ $sas_role == compute ]; then
	hostname_setup $compute_hostname
else
	echo "ERROR: SAS ROLE is not defined"
	exit 1
fi


yum -y install java firefox xclock x11* xauth python git compat-glibc libpng12 lsof at numactl glibc libpng ntp apr ksh wget mlocate libXext.x86_64 libXp.x86_64 libXtst.x86_64 xorg-x11-xauth.x86_64 gcc libSM.i686 libXrender.i686 zlib.i686 nfs-utils cifs-utils telnet
fail_if_error $? "ERROR: PreRequisites installation failed"

#System settings 
if [ -f /etc/security/limits.conf ]; then
	cat /etc/security/limits.conf| grep -w 500000
	a=`echo $?`
	echo $a
	if [ "$a" != "0" ]; then
		echo $a
		sed -i '$d' /etc/security/limits.conf
		echo "*               hard    nofile  500000" >> /etc/security/limits.conf
		echo "*               soft    nofile  500000" >> /etc/security/limits.conf
		echo "*               soft    nproc   650000" >> /etc/security/limits.conf
		echo "*               hard    nproc   500000" >> /etc/security/limits.conf
		echo "*               hard    stack   10240" >> /etc/security/limits.conf
		echo "*               soft    stack   10240" >> /etc/security/limits.conf
		echo "*               soft    stack   10240" >> /etc/security/limits.conf

		echo "# End of file" >> /etc/security/limits.conf
	fi
fi
if [ -f /etc/security/limits.d/20-nproc.conf ]; then
	sed -i 's/4096/unlimited/g' /etc/security/limits.d/20-nproc.conf
fi
echo "Security Limit values updated successfully."

##SSHD Configuration
if [ -f /etc/ssh/sshd_config ]; then
	PA="PasswordAuthentication yes "
	PRT="PermitRootLogin yes"
	x=`grep -i PermitRootLogin /etc/ssh/sshd_config`
	a=`echo $?`
	if [ "$a" == "0" ]; then
		sed -i '/PermitRootLogin/c\'"${PRT}"'' /etc/ssh/sshd_config
	fi
	x=`grep -i PasswordAuthentication /etc/ssh/sshd_config`
	a=`echo $?`
	if [ "$a" == "0" ]; then
		sed -i.bak s/PasswordAuthentication' 'no/PasswordAuthentication' 'yes/g /etc/ssh/sshd_config
	fi
fi
systemctl restart sshd
echo "SSHD Configuration updated successfully."


##Set Semaphore values
echo "kernel.sem=512 32000 256 1024" >> /etc/sysctl.conf
echo "net.core.somaxconn=2048" >> /etc/sysctl.conf
echo "Semaphore values updated successfully."

#Set default timeout values
sed -i.bak -e 's/#DefaultTimeoutStartSec=90s/DefaultTimeoutStartSec=1800s/g' /etc/systemd/system.conf
sed -i.bak -e 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStartSec=1800s/g' /etc/systemd/system.conf
echo "Timeout values updated successfully."

#Enable yum cache
sed -i.bak -e 's/keepcache=0/keepcache=1/g' /etc/yum.conf
echo "Yum Cache value updated successfully."

#Set MaxStartups
sed -i.bak -e 's/#MaxStartups 10:30:100/MaxStartups 100/g' /etc/ssh/sshd_config
echo "Max Startups value updated successfully."

###Configure SELINUX
setenforce 0
sed -i.bak -e 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
echo "SELINUX set to permissive."

##Create Mount Points
if [ ! -d $sas_home ]; then
	sudo mkdir -p $sas_home
fi
if [ ! -d "/sasdepot" ]; then
	sudo mkdir /sasdepot
fi

echo "SAS Directories created successfully."

##Volume Mount for opt-sas and sasdata
lsblk /dev/disk/azure/scsi1/lun0
if [ $? -eq 0 ] 
then
	df -h | grep $sas_home
	if [ $? -eq 0 ] 
	then
		echo "Disk for $sas_home already mounted."
	else
		mkfs.xfs /dev/disk/azure/scsi1/lun0
		mount /dev/disk/azure/scsi1/lun0 $sas_home
		fail_if_error $? "Error:Failed to mount $sas_home"
		echo "Disk for $sas_home located and mounted."
		## Adding Fstab Entries
		echo "/dev/disk/azure/scsi1/lun0  $sas_home   xfs       defaults        0 0"  >> /etc/fstab
	fi
else
	echo "ERROR: $sas_home disk(lun0) is not available."
	exit 1
fi

# SAS Data Volume
lsblk /dev/disk/azure/scsi1/lun1
if [ $? -eq 0 ] 
then
	mkdir /sasdata
	mkfs.xfs /dev/disk/azure/scsi1/lun1
	mount /dev/disk/azure/scsi1/lun1 /sasdata
	fail_if_error $? "Error:Failed to mount /sasdata"
	echo "Disk for SASData located and mounted."
	## Adding Fstab Entries
	echo "/dev/disk/azure/scsi1/lun1  /sasdata   xfs       defaults        0 0"  >> /etc/fstab
else
	echo "SASData disk not avilable on this machine."
fi

#PAM.D configuration for Host Authentication
if [ ! -f /etc/pam.d/sasauth ]
then
	cp /etc/pam.d/system-auth /etc/pam.d/sasauth
	sed -i '/^-session/d' /etc/pam.d/sasauth
	sed -i '/^session/d' /etc/pam.d/sasauth
	sed -i '/^password/d' /etc/pam.d/sasauth
	if [ $? -eq 0 ] 
	then
		echo "PAMD configuration updated successfully."
	else
		echo "ERROR: PAMD configuration update failed."
		exit 1
	fi
else 
	echo "PAMD configuration exists."
fi

echo "*** Phase 1 - Pre-Reqs Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"
