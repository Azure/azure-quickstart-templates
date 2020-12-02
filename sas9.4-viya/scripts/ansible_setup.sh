#!/bin/bash
set -x
echo "*** Phase 1 - Ansible Startup Script Started at `date +'%Y-%m-%d_%H-%M-%S'` ***"

##Error handling functions
fail_if_error() {
  [ $1 != 0 ] && {
    echo $2
    exit 10
  }
}

fail_if_error_phrase() {
  [ $1 != 0 ] && {
    unset PASSPHRASE
    exit 10
  }
}

## Facter Installation For Dynamic Values
yum install ruby wget -y
wget http://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/f/facter-2.4.1-1.el7.x86_64.rpm
rpm  --reinstall -vh facter-2.*.rpm
fail_if_error $? "Facter Installation failed"

#Facter Variables and Declaration
environmentLocation="/etc/facter/facts.d/variables.txt"

if [ -f $environmentLocation ]; then
	rm -f $environmentLocation
fi

cat << EOF > $environmentLocation
azure_storage_account=$1
azure_storage_files_share=$2
viyarepo_folder=$3
app_name=$4
domain_name=$5
ansible_vmname=$6
microservices_vmname=$7
cascontroller_vmname=$8
spre_vmname=${9}
casworker_vmname=${10}
saspwd=${11}
caspwd=${12}
kv_vault_name=${13}
secret_pvt_keyname=${14}
secret_pub_keyname=${15}
cas_nodes=${16}
mid_name=${17}
artifact_loc=${18}
compute_name=${19}
meta_name=${20}
stgacc_secr_name=${21}
cifs_server_fqdn=${22}
EOF

#Defining variables with facter values
azure_storage_account=`facter azure_storage_account`
cifs_server_fqdn=`facter cifs_server_fqdn`
azure_storage_files_share=`facter azure_storage_files_share`
DIRECTORY_NFS_SHARE="sasdepot"
sas_home="/sas/install"
key_vault_name=`facter kv_vault_name`
secret_pvt_keyname=`facter secret_pvt_keyname`
secret_pub_keyname=`facter secret_pub_keyname`
RootCAKey="RootCA.key"
RootCRT="RootCA.crt"
ServerKey="sasqs.key"
ServerCRT="sasqs.crt"
ServerCSR="sasqs.csr"
ssl_path="/opt/ssl"
cert_name="`facter app_name`sas94"



##Updating the Azure Cli Repo
rpm --import https://packages.microsoft.com/keys/microsoft.asc;sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
##Installing the azure CLI
yum install azure-cli -y
fail_if_error $? "Azure Cli Installation failed"

##Ansible Installation
if ! type -p ansible;  then
    # install Ansible
    curl --retry 10 --max-time 60 --fail --silent --show-error "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
    python get-pip.py
    pip install 'ansible==2.8.3'
	fail_if_error $? "Pip Installation failed"
fi

##Stop & Disable the firewalld(Iptables)
systemctl stop firewalld
systemctl disable firewalld

##Installing RedHat required packages
yum -y install java-1.8.0-openjdk yum-utils firefox xclock x11* xauth git python compat-glibc libpng12 lsof at numactl glibc libpng ntp apr ksh wget mlocate libXext.x86_64 libXp.x86_64 libXtst.x86_64 xorg-x11-xauth.x86_64 gcc libSM.i686 libXrender.i686 zlib.i686 nfs-utils cifs-utils telnet
fail_if_error $? "Error: Rhel packages install Failed"

##Volume Mount for opt-sas
if [ ! -d "$sas_home" ]; then
    sudo mkdir -p $sas_home
fi
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
    exit 1
fi

#Setting up hostname for Ansible Controller
ansible_host=`facter app_name``facter ansible_vmname`.`facter domain_name`
hostnamectl set-hostname --static ${ansible_host}
if [ $? -eq 0 ]; then
    echo "hostname update successful"
    if [ -f /etc/hostname ]; then
        chattr -i /etc/hostname
        rm -f /etc/hostname
        echo ${ansible_host} > /etc/hostname
        chattr +i /etc/hostname
    fi
    if [ -f /etc/sysconfig/network ]; then
        echo "HOSTNAME=${ansible_host}" >> /etc/sysconfig/network
    fi
    echo "Restart Network Service"
    /etc/init.d/network restart
else
    echo "Hostname Update failed"
fi
az login --identity
fail_if_error $? "Error: Az login Failed"
stgacc_secr_name=`facter stgacc_secr_name`
azure_storage_files_password=`az keyvault secret show -n $stgacc_secr_name --vault-name $key_vault_name | grep value | cut -d '"' -f4`
#Mounting File Share for SAS Viya Installation
echo "setup cifs"
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

#Passworless SSH Authentication and SSL Certificate Generation
export RANDFILE=$ssl_path/.rnd
echo "server_cn=`facter app_name``facter mid_name`.`facter domain_name`" > /etc/facter/facts.d/server_cn.txt
echo -e y | ssh-keygen -t rsa -q -f ~/.ssh/id_rsa -N ""
fail_if_error $? "ERROR: Key generation failed."

## Uploading the keys to key vault
az keyvault secret set -n ${secret_pub_keyname} --value "`cat ~/.ssh/id_rsa.pub`" --vault-name ${key_vault_name}
fail_if_error $? "ERROR:Key Vault, Public Key Upload Failed."


az keyvault secret set -n ${secret_pvt_keyname} --value "`cat ~/.ssh/id_rsa`" --vault-name ${key_vault_name}
fail_if_error $? "ERROR: Key Vault, Private Key Upload Failed."

##self-signed SSL Certificates
if [ ! -d "$ssl_path" ]; then
    sudo mkdir -p $ssl_path
fi
# Generate a passphrase
export PASSPHRASE=$(head -c 500 /dev/urandom | tr -dc a-z0-9A-Z | head -c 16; echo)
# Certificate details; replace items in angle brackets with your own info
subj="
C=UK
ST=Lon
O=IT
localityName=Marlow
commonName=RootCA
organizationalUnitName=QS
"
##CA
cat > $ssl_path/CA.cfg << EOF
[ v3_ca ]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = CA:true,pathlen:3
EOF

# Generate the server root key
openssl genrsa -des3 -passout env:PASSPHRASE -out $ssl_path/$RootCAKey 2048
fail_if_error_phrase $?

# Generate the CSR
openssl req \
    -new \
    -subj "$(echo -n "$subj" | tr "\n" "/")" \
    -key $ssl_path/$RootCAKey \
    -out $ssl_path/RootCA.csr \
    -passin env:PASSPHRASE
fail_if_error_phrase $?
cp $ssl_path/$RootCAKey $ssl_path/${RootCAKey}.org
fail_if_error_phrase $?
# Strip the password so we don't have to type it every time we restart Apache
openssl rsa -in $ssl_path/${RootCAKey}.org -out $ssl_path/${RootCAKey} -passin env:PASSPHRASE
fail_if_error_phrase $?
# Generate the cert (good for 10 years)
openssl x509 -req -days 3650 -in $ssl_path/RootCA.csr -extfile $ssl_path/CA.cfg -extensions v3_ca -signkey $ssl_path/$RootCAKey -out $ssl_path/$RootCRT
fail_if_error_phrase $?

server_cn=`facter server_cn`
# Generate the server sas key
openssl genrsa -des3 -passout env:PASSPHRASE -out $ssl_path/$ServerKey 2048
fail_if_error_phrase $?
# Certificate details; replace items in angle brackets with your own info
serversubj="
C=UK
ST=Lon
O=IT
localityName=Marlow
commonName=$server_cn
organizationalUnitName=QS
"

# Generate the server private key
openssl genrsa -des3 -out $ssl_path/$ServerKey -passout env:PASSPHRASE 2048
fail_if_error_phrase $?
# Generate the Server CSR
openssl req \
    -new \
    -batch \
    -subj "$(echo -n "$serversubj" | tr "\n" "/")" \
    -key $ssl_path/$ServerKey \
    -out $ssl_path/$ServerCSR \
    -passin env:PASSPHRASE
fail_if_error_phrase $?
cp $ssl_path/$ServerKey $ssl_path/${ServerKey}.org
fail_if_error_phrase $?
# Strip the password so we don't have to type it every time we restart Apache
openssl rsa -in $ssl_path/${ServerKey}.org -out $ssl_path/$ServerKey -passin env:PASSPHRASE
fail_if_error_phrase $?

# Generate the cert (good for 10 years)
openssl x509 -req -days 3650 -in $ssl_path/$ServerCSR -CA $ssl_path/RootCA.crt -CAkey $ssl_path/RootCA.key -set_serial 1 -out $ssl_path/$ServerCRT
fail_if_error_phrase $?
# Bundle
cat $ssl_path/$ServerCRT $ssl_path/RootCA.crt > $ssl_path/${cert_name}bundle.crt
fail_if_error_phrase $?

## Creating pfx file
openssl pkcs12 -export -out ${ssl_path}/${server_cn}.pfx -inkey ${ssl_path}/$ServerKey -in ${ssl_path}/${cert_name}bundle.crt -passout pass:
fail_if_error_phrase $?

# Uploading Self Signed certificate to Key Vault
az keyvault certificate import --file $ssl_path/${server_cn}.pfx --name $cert_name --vault-name $key_vault_name

echo "*** Phase 1 Completed - Ansible Startup Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"
