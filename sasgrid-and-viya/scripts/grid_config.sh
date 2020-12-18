#!/bin/bash
set -x
echo "*** Phase 5 - SAS Grid Config Script Started at `date +'%Y-%m-%d_%H-%M-%S'` ***"

## Function for error handling
fail_if_error() {
  [ $1 != 0 ] && {
    echo $2
    exit 10
  }
}

## Variables
depot_loc=`facter sasdepot_folder` 
app_name=`facter application_name` 
sas_role=`facter sas_role`   
domain_name=`facter domain_name`
res_dir="/opt/sas/resources/responsefiles"
resource_dir="/opt/sas/resources"
artifact_loc=`facter artifact_loc`
conf_prop=$resource_dir/grid_config.properties
cert_prop=${resource_dir}/ssl_cert.properties

#Downloading SAS SSL properties file
cp -p ${res_dir}/ssl_cert.properties ${resource_dir}
chown -R sasinst:sas ${resource_dir}

##Altering the certificate in property file
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
su - sasinst -c "time /opt/sas/grid/sashome/SASDeploymentManager/9.4/sasdm.sh -deploy -responsefile ${cert_prop} -lang en -loglevel 2 -templocation /var/temp -quiet"
fail_if_error $? "ERROR: SAS certificate update failed. Please check logs"

##SAS Configuration
if [ -f ${conf_prop} ]; then
   if [ ! -f /opt/sas/grid/config/Lev1/sas.servers ]; then
      sudo /opt/sas/grid/sashome/SASFoundation/9.4/utilities/bin/setuid.sh
      su - sasinst -c "source /opt/sas/platform/lsf/conf/profile.lsf;time /sasdepot/${depot_loc}/setup.sh -deploy -responsefile ${conf_prop} -lang en -loglevel 2 -templocation /var/temp -quiet"
      if [ $? -eq 0 ]; then
         echo "SAS Grid Server Configuration has been completed succesfully."
         sed -i "s|-WORK /tmp|-WORK /saswork|g" /opt/sas/grid/sashome/SASFoundation/9.4/sasv9.cfg
         chmod 777 /saswork -R
      else
         echo "ERROR: SAS Grid Server Configuration has failed. Please check logs"
         exit 1
      fi
   else
      telnet -apln |grep 8581
      if [ $? -eq 0 ]; then
         echo "SAS Grid Server is Up. Proceeding to Next Phase."
      else 
         echo "SAS Grid Server has been configured. Starting Services now."
         su - sasinst -c "/opt/sas/grid/config/Lev1/sas.servers start"
         su - sasinst -c "/opt/sas/grid/config/Lev1/sas.servers status|grep NOT"
         fail_if_error $? "SAS services on Grid server did not start."
      fi
   fi
else
   echo "SAS Config Properties file not found. Exiting Now."
   exit 1
fi

echo "*** Phase 5 - SAS Grid Config Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"
