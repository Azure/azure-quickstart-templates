#!/bin/bash
set -x
echo "*** Phase 3 - SAS Grid Install Script Started at `date +'%Y-%m-%d_%H-%M-%S'` ***"

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
grid_sid=`facter grid_sid`
artifact_loc=`facter artifact_loc`
meta_host=`facter meta_hostname`
grid_host=`facter grid_hostname`
mid_host=`facter mid_hostname`
sasint_secret_name=`facter sasint_secret_name`
sasext_secret_name=`facter sasext_secret_name`
key_vault_name=`facter key_vault_name`
pub_keyname=`facter pub_keyname`
#plan_file_url=${artifact_loc}properties/plan.xml
#gridinstall_url=${artifact_loc}properties/grid_install.properties
#gridconfig_url=${artifact_loc}properties/grid_config.properties
resource_dir=/opt/sas/resources
res_dir="/opt/sas/resources/responsefiles"
sas_local_dir="/opt/sas/grid" 
inst_prop=$resource_dir/grid_install.properties
conf_prop=$resource_dir/grid_config.properties


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

# Installation of grid binaries is faster on local disk compared to lustre, so initially installing the binaries on local disk attatched to /opt/sas/grid then in next phase copying those binaries to lustre.
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
      if [ -d $sas_local_dir/sashome ]; then
         chown sasinst:sas $sas_local_dir/sashome
      else
         mkdir -p $sas_local_dir/sashome
         chown sasinst:sas $sas_local_dir/sashome
      fi
      chown sasinst:sas $sas_local_dir -R
	fi
else
	   echo "ERROR: $sas_local_dir disk(lun0) is not available."
	   exit 1
fi

cp -rv /sasdepot/${depot_loc}/sid_files/${grid_sid} /opt/sas/resources/

if [ ! -d $res_dir ]; then
    mkdir -p $res_dir
fi


#Extracting the plan file and property files required for SAS install
#tar -xzvf /tmp/response-properties.tar.gz -C ${res_dir}
cp -p ${res_dir}/plan.xml ${resource_dir}
cp -p ${res_dir}/grid_* ${resource_dir}
chown -R sasinst:sas ${resource_dir}

#Altering the property files
sed -i "s/domain_name/${domain_name}/g" $resource_dir/*.properties
sed -i "s/host_name/${grid_host}/g" $resource_dir/*.properties
sed -i "s/meta_host/${meta_host}/g" $resource_dir/*.properties
sed -i "s/mid_host/${mid_host}/g" $resource_dir/*.properties
sed -i "s|sas_plan_file_path|/opt/sas/resources/plan.xml|g" $resource_dir/*.properties
sed -i "s|sas_license_file_path|/opt/sas/resources/${grid_sid}|g" $resource_dir/*.properties

#SAS Installation
if [ -d /var/temp ]; then
   chown sasinst:sas /var/temp
else
   mkdir -p /var/temp
   chown sasinst:sas /var/temp
fi

if [ -f ${inst_prop} ]; then
   if [ ! -f /opt/sas/grid/sashome/SASFoundation/9.4/utilities/bin/setuid.sh ]; then
      su - sasinst -c "source /opt/sas/platform/lsf/conf/profile.lsf;time /sasdepot/${depot_loc}/setup.sh -deploy -responsefile ${inst_prop} -lang en -loglevel 2 -templocation /var/temp -quiet"
      if [ $? -eq 0 ]; then
         echo "SAS Grid Server installation has been completed succesfully."
         sudo /opt/sas/grid/sashome/SASFoundation/9.4/utilities/bin/setuid.sh
         echo "Setuid script has been run successfully."
      else
         echo "ERROR: SAS Grid Server installation has failed. Please check logs"
         exit 1
      fi
   else 
      echo "SAS Installation Completed. Proceeding to Configuration stage."
   fi
else
   echo "SAS Install Properties file not found. Exiting Now."
   exit 1
fi

# Unmounting the local disk and attaching it to temporary location
if [ -d /tmp/sashome_temp ]; then
   chown sasinst:sas /tmp/sashome_temp
else
   mkdir -p /tmp/sashome_temp
   chown sasinst:sas /tmp/sashome_temp
fi

pkill -f /opt/sas/grid/
check=`ps -ef | grep /opt/sas/grid| wc -l`
until [ $check -eq 1 ]; do
   sleep 10
   check=`ps -ef | grep /opt/sas/grid| wc -l`
done

umount /opt/sas/grid
mount /dev/disk/azure/scsi1/lun0 /tmp/sashome_temp

echo "*** Phase 3 - SAS Grid Install Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"
