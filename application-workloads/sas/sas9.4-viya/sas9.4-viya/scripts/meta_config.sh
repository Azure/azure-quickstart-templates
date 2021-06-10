#!/bin/bash
set -x
echo "*** Phase 3 SAS Meta Config Script Started at `date +'%Y-%m-%d_%H-%M-%S'` ***"

## Function for error handling
fail_if_error() {
  [ $1 != 0 ] && {
    echo $2
    exit 10
  }
}

##Variables
app_name=`facter application_name`
artifact_loc=`facter artifact_loc`
depot_loc=`facter sasdepot_folder`
res_dir="/opt/sas/resources/responsefiles"
resource_dir="/opt/sas/resources"
inst_prop=${resource_dir}/meta_install.properties
conf_prop=${resource_dir}/meta_config.properties
cert_prop=${resource_dir}/ssl_cert.properties

cp -p ${res_dir}/ssl_cert.properties ${resource_dir}

##Altering the certificate in property file
sed -i "s|certname|${app_name}|g" ${resource_dir}/ssl_cert.properties
#Add certificate to trustedstore
su - sasinst -c "time /opt/sas/home/SASDeploymentManager/9.4/sasdm.sh -deploy -responsefile ${cert_prop} -lang en -loglevel 2 -templocation /opt/sas/temp -quiet"
fail_if_error $? "ERROR: SAS certificate update failed. Please check logs"

##SAS Meta Configuration
if [ -f ${conf_prop} ]; then
    if [ ! -f /opt/sas/config/Lev1/sas.servers ]; then
        sudo /opt/sas/home/SASFoundation/9.4/utilities/bin/setuid.sh
        su - sasinst -c "time /sasdepot/${depot_loc}/setup.sh -deploy -responsefile ${conf_prop} -lang en -loglevel 2 -templocation /opt/sas/temp -quiet"
        fail_if_error $? "ERROR: SAS Metadata Server Configuration has failed. Please check logs"
    else
        telnet -apln |grep 8561
        if [ $? -eq 0 ]; then
            echo "SAS Metadata Server is Up. Proceeding to Next Phase."
        else 
            echo "SAS Metadata Server has been configured. Starting Services now."
            su - sasinst -c "/opt/sas/config/Lev1/sas.servers start"
            echo "SAS Metadata Services have been started."
        fi
    fi
else
    fail_if_error 1 "ERROR: SAS Config Properties file not found. Exiting Now."
fi

echo "*** Phase 3 - SAS Meta Config Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"