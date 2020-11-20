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

##Global Variables
app_name=`facter application_name`
artifact_loc=`facter artifact_loc`
depot_loc=`facter sasdepot_folder`
res_dir="/opt/sas/resources/responsefiles"
resource_dir="/opt/sas/resources"
#ssl_prop_url=${artifact_loc}properties/ssl_cert.properties
conf_prop=${resource_dir}/mid_config.properties
cert_prop=${resource_dir}/ssl_cert.properties

##Create VMWare Directories
mkdir -p /etc/opt/vmware/vfabric/
chown sasinst:sas /etc/opt/vmware -R

##Downloading the ssl properties files

cp -p ${res_dir}/ssl_cert.properties ${resource_dir}

##changing the ssl setting in properties file
sed -i "s|certname|${app_name}|g" $cert_prop
sed -i "s|certname|${app_name}|g" $conf_prop

## Password Update
encsasextpw=$(</root/encext.txt)
sed -i "s/changeextpass/${encsasextpw}/g" $resource_dir/*.properties
echo "Encrypted password has been updated successfully."
encsasintpw=$(</root/encint.txt)
sed -i "s/changeintpass/${encsasintpw}/g" $resource_dir/*.properties
echo "Encrypted password has been updated succesfully."
rm -f /root/enc*.txt

#Add certificate to trustedstore
su - sasinst -c "time /usr/local/sashome/SASDeploymentManager/9.4/sasdm.sh -deploy -responsefile ${cert_prop} -lang en -loglevel 2 -templocation /var/temp -quiet"
fail_if_error $? "ERROR: SAS certificate update failed. Please check logs"

##SAS Configuration
if [ -f ${conf_prop} ]; then
   if [ ! -f /usr/local/config/Lev1/sas.servers ]; then
      su - sasinst -c "time /sasdepot/${depot_loc}/setup.sh -deploy -responsefile ${conf_prop} -lang en -loglevel 2 -templocation /var/temp -quiet"
      fail_if_error $? "ERROR: SAS Mid Server Configuration has failed. Please check logs"
   else
      telnet -apln |grep 8343
      if [ $? -eq 0 ]; then
         echo "SAS Mid-Tier Server is Up. Proceeding to Next Phase."
      else 
         echo "SAS Mid-Tier Server has been configured. Starting Services now."
         su - sasinst -c "/usr/local/config/Lev1/sas.servers start"
         echo "SAS Mid-Tier Services have been started."
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

#Updating the setenv.sh of SASServer14_1
sed -i 's|LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$GUI_LIBDIR/common/linux-x86_64/"|LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$GUI_LIBDIR/common/linux-x86_64/:$GUI_LIBDIR/lsf10.1/linux-x86_64/"|g' /usr/local/config/Lev1/Web/WebAppServer/SASServer14_1/bin/setenv.sh
su - sasinst -c "/usr/local/config/Lev1/Web/WebAppServer/SASServer14_1/bin/tcruntime-ctl.sh restart"


echo "*** Phase 3 - SAS Mid-Tier Config Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"