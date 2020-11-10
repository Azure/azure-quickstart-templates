#!/bin/bash
set -x
echo "*** Phase 3 - SAS Compute Config Script Started at `date +'%Y-%m-%d_%H-%M-%S'` ***"

##Error handling function
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
conf_prop=${resource_dir}/compute_config.properties
cert_prop=${resource_dir}/ssl_cert.properties

##Replace crt in certupdatemid.properties
cp -p ${res_dir}/ssl_cert.properties ${resource_dir}
sed -i "s|certname|${app_name}|g" ${resource_dir}/ssl_cert.properties

## Password Update
encsasextpw=$(</root/encext.txt)
sed -i "s/changeextpass/${encsasextpw}/g" $resource_dir/*.properties
echo "Encrypted password has been updated successfully."
encsasintpw=$(</root/encint.txt)
sed -i "s/changeintpass/${encsasintpw}/g" $resource_dir/*.properties
echo "Encrypted password has been updated succesfully."
rm -f /root/enc*.txt


#Add certificate to trustedstore
su - sasinst -c "time /opt/sas/home/SASDeploymentManager/9.4/sasdm.sh -deploy -responsefile ${cert_prop} -lang en -loglevel 2 -templocation /opt/sas/temp -quiet"
fail_if_error $? "ERROR: SAS certificate update failed. Please check logs"

##SAS Configuration
if [ -f ${conf_prop} ]; then
    if [ ! -f /opt/sas/config/Lev1/sas.servers ]; then
        sudo /opt/sas/home/SASFoundation/9.4/utilities/bin/setuid.sh
        su - sasinst -c "time /sasdepot/${depot_loc}/setup.sh -deploy -responsefile ${conf_prop} -lang en -loglevel 2 -templocation /opt/sas/temp -quiet"
        if [ $? -eq 0 ]; then
            echo "SAS Compute Server Configuration has been completed succesfully."
            sed -i "s|-WORK /tmp|-WORK /saswork|g" /opt/sas/home/SASFoundation/9.4/sasv9.cfg
            su - sasinst -c "/opt/sas/config/Lev1/ObjectSpawner/ObjectSpawner.sh stop > /var/logs/ObjectSpawnerstop.txt"
            sleep 10
            su - sasinst -c "/opt/sas/config/Lev1/ObjectSpawner/ObjectSpawner.sh start > /var/logs/ObjectSpawnerstart.txt"
        else
            fail_if_error 1 "ERROR: SAS Compute Server Configuration has failed. Please check logs"
            
        fi
    else
        telnet -apln |grep 8581
        if [ $? -eq 0 ]; then
            echo "SAS Compute Server is Up. Proceeding to Next Phase."
        else 
            echo "SAS Compute Server has been configured. Starting Services now."
            su - sasinst -c "/opt/sas/config/Lev1/sas.servers start"
            echo "SAS Compute Services have been started."
        fi
    fi
else
    fail_if_error 1 "ERROR: SAS Config Properties file not found. Exiting Now."
    
fi
echo "*** Phase 3 - SAS Compute Config Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"