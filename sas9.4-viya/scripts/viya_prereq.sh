#!/bin/bash
set -x
echo "*** Phase 1 - Pre-Reqs Script Started at `date +'%Y-%m-%d_%H-%M-%S'` ***"


## Functions
fail_if_error() {
  [ $1 != 0 ] && {
    echo $2
    exit 10
  }
}

## Facter Installation
yum install ruby wget -y
wget http://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/f/facter-2.4.1-1.el7.x86_64.rpm
rpm  --reinstall -vh facter-2.*.rpm
fail_if_error $? "Error: Facter installation failed"

#Facter Variables and Declaration
environmentLocation="/etc/facter/facts.d/variables.txt"

if [ -f $environmentLocation ]; then
	rm -f $environmentLocation
fi


#Facter Variables and Declaration
cat << EOF > $environmentLocation
azure_storage_account=$1
azure_storage_files_share=$2
DIRECTORY_NFS_SHARE=$3
app_name=$4
domain_name=$5
ansible_vmname=$6
microservices_vmname=$7
cascontroller_vmname=$8
spre_vmname=${9}
casworker_vmname=${10}
sasintpwd=${11}
casintpwd=${12}
kv_vault_name=${13}
secret_pvt_keyname=${14}
secret_pub_keyname=${15}
cas_nodes=${16}
artifact_loc=${17}
stgacc_secr_name=${18}
cifs_server_fqdn=${19}
EOF


#Updating the Azure Cli Repo
rpm --import https://packages.microsoft.com/keys/microsoft.asc;sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
# Installing the azure CLI
yum install azure-cli -y
fail_if_error $? "Error: Azure cli installation failed"

if ! type -p ansible;  then
   # install Ansible
    curl --retry 10 --max-time 60 --fail --silent --show-error "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
    sudo python get-pip.py
    pip install 'ansible==2.8.3'
    fail_if_error $? "Error: Ansible client installation is failed"
fi

#Stop & Disable the firewalld(Iptables)
systemctl stop firewalld
systemctl disable firewalld


#Variable Declaration
azure_storage_account=`facter azure_storage_account`
azure_storage_files_password=`facter azure_storage_files_password`
azure_storage_files_share=`facter azure_storage_files_share`
DIRECTORY_NFS_SHARE="sasdepot"
app_name=`facter app_name`
domain_name=`facter domain_name`
ansible_vmname=`facter ansible_vmname`
microservices_vmname=`facter microservices_vmname`
cascontroller_vmname=`facter cascontroller_vmname`
spre_vmname=`facter spre_vmname`
machine_name=`curl -H Metadata:true "http://169.254.169.254/metadata/instance/compute/name?api-version=2017-08-01&format=text"`
current_host=${app_name}${machine_name}
sas_home="/opt/sas"
backupdir="/backup"
sasdatadir="/sasdata"


#RhelRequired packages
yum -y install java-1.8.0-openjdk yum-utils firefox xclock x11* xauth git python compat-glibc libpng12 lsof at numactl glibc libpng ntp apr ksh wget mlocate libXext.x86_64 libXp.x86_64 libXtst.x86_64 xorg-x11-xauth.x86_64 gcc libSM.i686 libXrender.i686 zlib.i686 nfs-utils cifs-utils telnet
fail_if_error $? "Error: PreRequisites installation failed"

##SSHD Configuration
if [ -f /etc/ssh/sshd_config ]
    then
        PA="PasswordAuthentication yes "
        PRT="PermitRootLogin yes"
        x=`grep -i PermitRootLogin /etc/ssh/sshd_config`
        a=`echo $?`
    if [ "$a" == "0" ]
        then
            sed -i '/PermitRootLogin/c\'"${PRT}"'' /etc/ssh/sshd_config
    fi
    x=`grep -i PasswordAuthentication /etc/ssh/sshd_config`
    a=`echo $?`
    if [ "$a" == "0" ]
        then
            sed -i.bak s/PasswordAuthentication' 'no/PasswordAuthentication' 'yes/g /etc/ssh/sshd_config
    fi
fi

#Modifying SSHD Config Setting 
sed -i '/ClientAliveInterval/c\ClientAliveInterval 3600' /etc/ssh/sshd_config
sed -i 's/#MaxStartups 10:30:100/MaxStartups 100/g' /etc/ssh/sshd_config

systemctl restart sshd
echo "SSHD Configuration updated successfully."


#System settings for ulimits
if [ -f /etc/security/limits.conf ]
then
	cat /etc/security/limits.conf| grep -w 500000
	a=`echo $?`
	echo $a
	if [ "$a" != "0" ]
	then
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
if [ -f /etc/security/limits.d/20-nproc.conf ]
then
	sed -i 's/4096/unlimited/g' /etc/security/limits.d/20-nproc.conf
fi

#Static Hostname Setup for Server
echo "setting up the new hostname on the server"
echo $current_host
hostnamectl set-hostname --static ${current_host}.${domain_name}
if [ $? -eq 0 ]; then
    echo "hostname update successful"
    if [ -f /etc/hostname ]; then
        chattr -i /etc/hostname
        rm -f /etc/hostname
        echo ${current_host}.${domain_name} > /etc/hostname
        chattr +i /etc/hostname
    fi
    if [ -f /etc/sysconfig/network ]; then
        echo "HOSTNAME=${current_host}.${domain_name}" >> /etc/sysconfig/network
    fi
    echo "Restart Network Service"
    /etc/init.d/network restart
else
    echo "Hostname Update failed"
fi


###Configure SELINUX
setenforce 0
sed -i.bak -e 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
echo "SELINUX set to permissive."


##Create Mount Points
if [ ! -d "$sas_home" ]; then
    sudo mkdir -p $sas_home
fi

##Create Mount Points
if [ ! -d "$backupdir" ]; then
    sudo mkdir -p $backupdir
fi

##Create Mount Points
if [ ! -d "$sasdatadir" ]; then
    sudo mkdir -p $sasdatadir
fi

##Volume Mount for opt-sas
lsblk /dev/disk/azure/scsi1/lun0
if [ $? -eq 0 ]; then 
    df -h | grep $sas_home
	if [ $? -eq 0 ]; then
		echo "Disk for $sas_home already mounted."
    else
        mkfs.xfs /dev/disk/azure/scsi1/lun0
		mount /dev/disk/azure/scsi1/lun0 $sas_home
		fail_if_error $? "Error:Failed to mount $sas_home"
		## Adding Fstab Entries
		echo "/dev/disk/azure/scsi1/lun0   $sas_home   xfs       defaults        0 0"  >> /etc/fstab
        echo "Disk for $sas_home located and mounted."
    fi
else
    echo "ERROR: $sas_home disk(lun0) disk failed to mount or disk not available."
    #exit 1
fi

##Volume Mount for sasbackup
lsblk /dev/disk/azure/scsi1/lun1
    if [ $? -eq 0 ]; then
        df -h | grep $backup
        if [ $? -eq 0 ] 
	    then
                echo "Disk for "$backupdir" already mounted"
        else
            mkfs.xfs /dev/disk/azure/scsi1/lun1
            mount /dev/disk/azure/scsi1/lun1 $backupdir
            fail_if_error $? "Error:Failed to mount $backupdir"
            ## Adding Fstab Entries
            echo "/dev/disk/azure/scsi1/lun1     $backupdir         xfs       defaults        0 0"  >> /etc/fstab
            echo "Disk for $backupdir located and mounted."
        fi
    else
        echo "ERROR: $backupdir disk(lun1) disk failed to mount or disk not available"
        #exit 1
    fi

##Volume Mount for sasdata
if [ $machine_name == $cascontroller_vmname ]; then
    lsblk /dev/disk/azure/scsi1/lun2
    if [ $? -eq 0 ]; then
        df -h | grep $backup
        if [ $? -eq 0 ] 
	    then
                echo "Disk for "$sasdatadir" already mounted"
        else
            mkfs.xfs /dev/disk/azure/scsi1/lun2
            mount /dev/disk/azure/scsi1/lun2 $sasdatadir
            fail_if_error $? "Error:Failed to mount $sasdatadir"
            ## Adding Fstab Entries
            echo "/dev/disk/azure/scsi1/lun2    "$sasdatadir"           xfs       defaults        0 0"  >> /etc/fstab
            echo "Disk for $sasdatadir located and mounted."
        fi
    else
        echo "ERROR: "$sasdatadir" disk(lun2) disk failed to mount or disk not available "
        #exit 1
    fi
fi

#Mounting Azure File Share for SAS Viya Play book
stgacc_secr_name=`facter stgacc_secr_name`
key_vault_name=`facter kv_vault_name`
az login --identity
fail_if_error $? "Error: Az login Failed"
azure_storage_files_password=`az keyvault secret show -n $stgacc_secr_name --vault-name $key_vault_name | grep value | cut -d '"' -f4`
echo "setup cifs"
cifs_server_fqdn=`facter cifs_server_fqdn`

if [ ! -d "/etc/smbcredentials" ]; then
    sudo mkdir /etc/smbcredentials
fi
chmod 700 /etc/smbcredentials
if [ ! -f "/etc/smbcredentials/"${azure_storage_account}".cred" ]; then
    echo "username=${azure_storage_account}" >> /etc/smbcredentials/${azure_storage_account}.cred
    echo "password=${azure_storage_files_password}" >> /etc/smbcredentials/${azure_storage_account}.cred
fi
chmod 600 "/etc/smbcredentials/${azure_storage_account}.cred"

mkdir -p "/${DIRECTORY_NFS_SHARE}"
mount -t cifs //${cifs_server_fqdn}/${azure_storage_files_share} /${DIRECTORY_NFS_SHARE}  -o vers=3.0,credentials=/etc/smbcredentials/${azure_storage_account}.cred,dir_mode=0777,file_mode=0777,serverino
fail_if_error $? "Error: SAS Depot Mount Failed"
#echo "//${cifs_server_fqdn}/${azure_storage_files_share} /${DIRECTORY_NFS_SHARE}  cifs defaults,vers=3.0,credentials=/etc/smbcredentials/${azure_storage_account}.cred,dir_mode=0777,file_mode=0777,sec=ntlmssp 0 0" >> /etc/fstab
#mount -a

echo "*** Phase 1 - Pre-Reqs Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"
