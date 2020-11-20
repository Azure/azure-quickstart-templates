#!/bin/bash
set -x
echo "*** Phase 2 - SAS Mid-Tier Install Script Started at `date +'%Y-%m-%d_%H-%M-%S'` ***"

## Function for error handling
fail_if_error() {
  [ $1 != 0 ] && {
    echo $2
    exit 10
  }
}

##Global Variables
depot_loc=`facter sasdepot_folder` 
store_name=`facter storage_account_name`
store_loc=`facter file_share_name`   
store_key=`facter store_key`   
app_name=`facter application_name`  
sas_role=`facter sas_role`   
domain_name=`facter domain_name`  
depot_loc=`facter sasdepot_folder` 
sas_sid=`facter sas_sid`
meta_host=`facter meta_hostname`
grid_host=`facter grid_hostname`
mid_host=`facter mid_hostname`
sasint_secret_name=`facter sasint_secret_name`
sasext_secret_name=`facter sasext_secret_name`
key_vault_name=`facter key_vault_name`
pub_keyname=`facter pub_keyname`
artifact_loc=`facter artifact_loc`
res_dir="/opt/sas/resources/responsefiles"
resource_dir="/opt/sas/resources"
#plan_file_url="${artifact_loc}properties/plan.xml"
#midinstall_url="${artifact_loc}properties/mid_install.properties"
#midconfig_url="${artifact_loc}properties/mid_config.properties"
inst_prop=${resource_dir}/mid_install.properties
conf_prop=${resource_dir}/mid_config.properties
sas_local_dir="/usr/local"

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
cp -p /tmp/lustre_packages.zip /tmp/lustre_package
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

## Creating the directory structure
if [ -d $resource_dir ]; then
   chown sasinst:sas $resource_dir
else
   mkdir -p $resource_dir
   chown sasinst:sas $resource_dir
fi

if [ ! -d $sas_local_dir ]; then
	sudo mkdir -p $sas_local_dir
fi

lsblk /dev/disk/azure/scsi1/lun0
if [ $? -eq 0 ]; then
	df -h | grep $sas_local_dir
	if [ $? -eq 0 ]; then
		echo "Disk for $sas_local_dir already mounted."
	else
		mkfs.xfs /dev/disk/azure/scsi1/lun0
		mount /dev/disk/azure/scsi1/lun0 $sas_local_dir
		fail_if_error $? "Error:Failed to mount $sas_local_dir"
		echo "Disk for $sas_local_dir located and mounted."
		## Adding Fstab Entries
		echo "/dev/disk/azure/scsi1/lun0  $sas_local_dir   xfs       defaults        0 0"  >> /etc/fstab
        if [ -d $sas_local_dir/sashome ]; then
            chown sasinst:sas $sas_local_dir/sashome
        else
            mkdir -p $sas_local_dir/sashome
            chown sasinst:sas $sas_local_dir/sashome
        fi
        if [ -d $sas_local_dir/config ]; then
            chown sasinst:sas $sas_local_dir/config
        else
            mkdir -p $sas_local_dir/config
            chown sasinst:sas $sas_local_dir/config
        fi
        chown sasinst:sas $sas_local_dir -R
	   fi
else
	   echo "ERROR: $sas_local_dir disk(lun0) is not available."
	   exit 1
fi

cp -rv /sasdepot/${depot_loc}/sid_files/${sas_sid} /opt/sas/resources/
if [ ! -d $res_dir ]; then
    mkdir -p $res_dir
fi

#Extracting the plan file and property files required for SAS install
tar -xzvf /tmp/response-properties.tar.gz -C ${res_dir}
cp -p ${res_dir}/plan.xml ${resource_dir}
cp -p ${res_dir}/mid_* ${resource_dir}
chown -R sasinst:sas ${resource_dir}


#Changing the settings in property files
sed -i "s/domain_name/${domain_name}/g" $resource_dir/*.properties
sed -i "s/host_name/${mid_host}/g" $resource_dir/*.properties
sed -i "s/meta_host/${meta_host}/g" $resource_dir/*.properties
sed -i "s|sas_plan_file_path|/opt/sas/resources/plan.xml|g" $resource_dir/*.properties
sed -i "s|sas_license_file_path|/opt/sas/resources/${sas_sid}|g" $resource_dir/*.properties

#SAS Installation
if [ -d /var/temp ]; then
   chown sasinst /var/temp
else
   mkdir -p /var/temp
   chown sasinst /var/temp
fi

if [ -f ${inst_prop} ]; then
   if [ ! -d /usr/local/sashome/SASDeploymentManager ]; then
      su - sasinst -c "source /opt/sas/platform/lsf/conf/profile.lsf;time /sasdepot/${depot_loc}/setup.sh -deploy -responsefile ${inst_prop} -lang en -loglevel 2 -templocation /var/temp -quiet"
      fail_if_error $? "Error:SAS Mid-Tier Server installation has failed. Please check logs"
   else 
      echo "SAS Installation Completed. Proceeding to Configuration stage."
   fi
else
   echo "SAS Install Properties file not found. Exiting Now."
   exit 1
fi


echo "*** Phase 6 - SAS Mid-Tier Install Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"
