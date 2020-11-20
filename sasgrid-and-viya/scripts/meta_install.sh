#!/bin/bash
set -x
echo "*** Phase 2 - SAS Meta Install Script Started at `date +'%Y-%m-%d_%H-%M-%S'` ***"

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
sas_sid=`facter sas_sid`
artifact_loc=`facter artifact_loc`
meta_host=`facter meta_hostname`
grid_hostname=`facter grid_hostname`
mid_host=`facter mid_hostname`
sasint_secret_name=`facter sasint_secret_name`
sasext_secret_name=`facter sasext_secret_name`
key_vault_name=`facter key_vault_name`
pub_keyname=`facter pub_keyname`
res_dir="/opt/sas/resources/responsefiles"
resource_dir="/opt/sas/resources"
inst_prop=${resource_dir}/meta_install.properties
conf_prop=${resource_dir}/meta_config.properties
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

#copyign SID file to local directories from SASDepot
cp -rv /sasdepot/${depot_loc}/sid_files/${sas_sid} /opt/sas/resources/ 
#Downloading Meta Install Property files
if [ ! -d $res_dir ]; then
    mkdir -p $res_dir
fi

#Extracting the property files
tar -xzvf /tmp/response-properties.tar.gz -C ${res_dir}
cp -p ${res_dir}/plan.xml ${resource_dir}
cp -p ${res_dir}/meta_* ${resource_dir}
chown -R sasinst:sas ${resource_dir}

##Set Property Files
sed -i "s/domain_name/${domain_name}/g" $resource_dir/*.properties
sed -i "s/host_name/${meta_host}/g" $resource_dir/*.properties
sed -i "s/mid_host/${mid_host}/g" $resource_dir/*.properties
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
   if [ ! -f /usr/local/sashome/SASFoundation/9.4/utilities/bin/setuid.sh ]; then
      su - sasinst -c "time /sasdepot/${depot_loc}/setup.sh -deploy -responsefile ${inst_prop} -lang en -loglevel 2 -templocation /var/temp -quiet"
      if [ $? -eq 0 ]; then
         echo "SAS Metadata Server installation has been completed succesfully."
         sudo /usr/local/sashome/SASFoundation/9.4/utilities/bin/setuid.sh
         echo "Setuid script has been run successfully."
      else
         echo "ERROR: SAS Metadata Server installation has failed. Please check logs"
         exit 1
      fi
   else
      echo "SAS Installation Completed. Proceeding to Configuration stage."
   fi
else
   echo "SAS Install Properties file not found. Exiting Now."
   exit 1
fi

sasextpw=`echo "\""${sasextpw}"\""`
sasintpw=`echo "\""${sasintpw}"\""`
##Encrypting sasextpw password
echo  "filename pwfile '/root/encext.txt'; proc pwencode in=${sasextpw} out=pwfile; run;" > /root/encext.sas
/usr/local/sashome/SASFoundation/9.4/bin/sas_u8 -sysin /root/encext.sas -log /root/sasencext.log
fail_if_error $? "ERROR: SAS External Password encryption failed."
encsasextpw=$(</root/encext.txt)
sed -i "s/changeextpass/${encsasextpw}/g" $resource_dir/*.properties
echo "Encrypted password has been updated successfully."
##Encrypting sasintpw password
echo  "filename pwfile '/root/encint.txt'; proc pwencode in=${sasintpw} out=pwfile; run;" > /root/encint.sas
/usr/local/sashome/SASFoundation/9.4/bin/sas_u8 -sysin /root/encint.sas -log /root/sasencint.log
fail_if_error $? "ERROR: SAS Internal Password encryption failed."
encsasintpw=$(</root/encint.txt)
sed -i "s/changeintpass/${encsasintpw}/g" $resource_dir/*.properties
echo "Encrypted password has been updated succesfully."

echo "*** Phase 2 - SAS Meta Install Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"
