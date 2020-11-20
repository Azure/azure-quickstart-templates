#!/bin/bash
set -x
echo "*** Phase 2-PSS installation Script Started at `date +'%Y-%m-%d_%H-%M-%S'` ***"

## Function for error handling
fail_if_error() {
  [ $1 != 0 ] && {
    echo $2
    exit 10
  }
}

#Variable Declaration
sasint_secret_name=`facter sasint_secret_name`
sasext_secret_name=`facter sasext_secret_name`
key_vault_name=`facter key_vault_name`
pub_keyname=`facter pub_keyname`
artifact_loc=`facter artifact_loc`

# Getting the password
az login --identity
fail_if_error $? "Error: AZ login failed"
sasintpw=`az keyvault secret show -n $sasint_secret_name --vault-name $key_vault_name | grep value | cut -d '"' -f4`
fail_if_error $? "Error: Key vault access failed"
sasextpw=`az keyvault secret show -n $sasext_secret_name --vault-name $key_vault_name | grep value | cut -d '"' -f4`
fail_if_error $? "Error: Key vault access failed"
echo `az keyvault secret show -n ${pub_keyname}  --vault-name ${key_vault_name} | grep value | cut -d '"' -f4` >> ~/.ssh/authorized_keys
fail_if_error $? "Error: Key vault access failed"


## Creating sas group
cat /etc/group |grep -wiq sas
if [ $? -eq 0 ]; then
   echo "SAS Group exists"
else
   groupadd -g 5001 sas
   fail_if_error $? "ERROR: Failed to create sas group"
fi

## Creating SAS internal Users
username=("sasinst" "sassrv" "sasdemo" "lsfadmin")
userid=("1002" "1003" "1005" "1006")
for ((i=0;i<${#username[@]};++i));
do
    if [ ! -f /home/${username[$i]} ]; then
        useradd -u ${userid[$i]} -g sas ${username[$i]}
        fail_if_error $? "ERROR: failed to create ${username[$i]} User"
        echo ${sasextpw} | passwd ${username[$i]} --stdin
    else 
        echo "User ${username[$i]} exists"
    fi
done

### Lustre client installation 
echo "Installing kernel package"
VER="3.10.0-1062.9.1.el7"
yum install kernel-$VER kernel-devel-$VER kernel-headers-$VER kernel-abi-whitelists-$VER kernel-tools-$VER kernel-tools-libs-$VER kernel-tools-libs-devel-$VER -y --skip-broken
fail_if_error $? "ERROR: kernel package installation failed."

echo "Downloading and installing lustre packages "
mkdir -p /tmp/lustre_package
cd /tmp/lustre_package
cp -p /tmp/lustre_packages.zip /tmp/lustre_package/
unzip lustre_packages.zip
yum localinstall lustre-client-2.12.4-1.el7.x86_64.rpm kmod-lustre-client-2.12.4-1.el7.x86_64.rpm -y
fail_if_error $? "ERROR: Client installation failed."

yum install xorg-x11-xauth.x86_64 xorg-x11-server-utils.x86_64 dbus-x11.x86_64 -y
modprobe -v lustre
echo "Lustre client installed successfully, Now mouning the file system"

mkdir -p /opt/sas
mount -t lustre -o flock mgt@tcp:/lustre /opt/sas/
fail_if_error $? "ERROR: failed to mount lustre file system."

#/ect/fstab entry
echo "mgt@tcp:/lustre /opt/sas/ lustre flock,_netdev 0 0" >> /etc/fstab
lfs setstripe -S 64K -i -1 -c -1 /opt/sas
lctl set_param osc.\*.max_dirty_mb=256
lctl set_param osc.\*.max_rpcs_in_flight=16
chmod 777 /opt/sas

### Lustre client installation completed

SASInstallLoc="/opt/sas"
LSFInstallLoc="$SASInstallLoc/platform/lsf"
LSFBinDir=`ls -l $LSFInstallLoc | sed '2q;d' |  awk '{print $NF}'`

cd $LSFInstallLoc/$LSFBinDir/install ; ./hostsetup --top="$LSFInstallLoc" --boot="y" --profile="y"  --start="y"
fail_if_error $? "Error: LSF hostsetup utility failed"

if [ ! -f /etc/lsf.sudoers ]; then
   echo "LSF_STARTUP_PATH=$LSFInstallLoc/$LSFBinDir/linux2.6-glibc2.3-x86_64/etc" >> /etc/lsf.sudoers
   echo 'LSF_STARTUP_USERS="sasinst lsfadmin"' >> /etc/lsf.sudoers
fi

echo "*** Phase 2 - PSS installation Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"
