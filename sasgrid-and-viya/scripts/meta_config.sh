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

##Local Variables
##Variables
app_name=`facter application_name`
artifact_loc=`facter artifact_loc`
depot_loc=`facter sasdepot_folder`
resource_dir="/opt/sas/resources"
res_dir="/opt/sas/resources/responsefiles"
inst_prop=${resource_dir}/meta_install.properties
conf_prop=${resource_dir}/meta_config.properties
cert_prop=${resource_dir}/ssl_cert.properties
sas_role=`facter sas_role`
domain_name=`facter domain_name` 

#Downloading SAS SSL properties file
cp -p ${res_dir}/ssl_cert.properties ${resource_dir}

##Altering the certificate in property file
sed -i "s|certname|${app_name}|g" ${resource_dir}/ssl_cert.properties


#Add certificate to trustedstore
su - sasinst -c "time /usr/local/sashome/SASDeploymentManager/9.4/sasdm.sh -deploy -responsefile ${cert_prop} -lang en -loglevel 2 -templocation /var/temp -quiet"
fail_if_error $? "ERROR: SAS certificate update failed. Please check logs"


##SAS Configuration
if [ -f ${conf_prop} ]; then
   if [ ! -f /usr/local/config/Lev1/sas.servers ]; then
      sudo /usr/local/sashome/SASFoundation/9.4/utilities/bin/setuid.sh
      su - sasinst -c "time /sasdepot/${depot_loc}/setup.sh -deploy -responsefile ${conf_prop} -lang en -loglevel 2 -templocation /var/temp -quiet"
      fail_if_error $? "ERROR: SAS Metadata Server Configuration has failed. Please check logs"
   else
      telnet -apln |grep 8561
      if [ $? -eq 0 ]; then
         echo "SAS Metadata Server is Up. Proceeding to Next Phase."
      else 
         echo "SAS Metadata Server has been configured. Starting Services now."
         su - sasinst -c "/usr/local/config/Lev1/sas.servers start"
		   su - sasinst -c "/usr/local/config/Lev1/sas.servers status|grep NOT"
         if [ $? -eq 0 ]; then
            echo "SAS services on Mid server did not start."
			exit 1
         else
            echo "SAS services on Mid server started succesfully."
         fi
      fi
   fi
else
    echo "SAS Config Properties file not found. Exiting Now."
    exit 1
fi

echo "*** Phase 3 - SAS Meta Config Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"