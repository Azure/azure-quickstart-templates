#!/bin/bash
set -x
echo "*** Phase 3 - SAS Mid-Tier Config Script Started at `date +'%Y-%m-%d_%H-%M-%S'` ***"

## Function for error handling
fail_if_error() {
  [ $1 != 0 ] && {
    echo $2
    exit 10
  }
}

##Local Variables
app_name=`facter application_name`
artifact_loc=`facter artifact_loc`
depot_loc=`facter sasdepot_folder`
res_dir="/opt/sas/resources/responsefiles"
resource_dir="/opt/sas/resources"
conf_prop=${resource_dir}/mid_config.properties
cert_prop=${resource_dir}/ssl_cert.properties

##Create VMWare Directories
mkdir -p /etc/opt/vmware/vfabric/
chown sasinst:sas /etc/opt/vmware -R

cp -p ${res_dir}/ssl_cert.properties ${resource_dir}

##changing the ssl setting in properties file
sed -i "s|certname|${app_name}|g" ${resource_dir}/ssl_cert.properties
sed -i "s|certname|${app_name}|g" ${resource_dir}/mid_config.properties

## Password Update
encsasextpw=$(</root/encext.txt)
sed -i "s/changeextpass/${encsasextpw}/g" $resource_dir/*.properties
echo "Encrypted password has been updated successfully."
encsasintpw=$(</root/encint.txt)
sed -i "s/changeintpass/${encsasintpw}/g" $resource_dir/*.properties
echo "Encrypted password has been updated succesfully."

#Add certificate to trustedstore
su - sasinst -c "time /opt/sas/home/SASDeploymentManager/9.4/sasdm.sh -deploy -responsefile ${cert_prop} -lang en -loglevel 2 -templocation /opt/sas/temp -quiet"
fail_if_error $? "ERROR: SAS certificate update failed. Please check logs"

##SAS Configuration
if [ -f ${conf_prop} ]; then
    if [ ! -f /opt/sas/config/Lev1/sas.servers ]; then
        sudo /opt/sas/home/SASFoundation/9.4/utilities/bin/setuid.sh
        su - sasinst -c "time /sasdepot/${depot_loc}/setup.sh -deploy -responsefile ${conf_prop} -lang en -loglevel 2 -templocation /opt/sas/temp -quiet"
        fail_if_error $? "ERROR: SAS Compute Server Configuration has failed. Please check logs"
    else
        telnet -apln |grep 7980
        if [ $? -eq 0 ]; then
            echo "SAS Mid-Tier Server is Up. Proceeding to Next Phase."
        else 
            echo "SAS Mid-Tier Server has been configured. Starting Services now."
            su - sasinst -c "/opt/sas/config/Lev1/sas.servers start"
            echo "SAS Mid-Tier Services have been started."
        fi
    fi
else
    echo "SAS Config Properties file not found. Exiting Now."
    exit 1
fi

echo "*** Phase 3 - SAS Mid-Tier Config Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"