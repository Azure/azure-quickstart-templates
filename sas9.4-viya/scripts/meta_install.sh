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
key_vault_name=`facter key_vault_name`
stgacc_secr_name=`facter stgacc_secr_name`
app_name=`facter application_name` 
sas_role=`facter sas_role` 
domain_name=`facter domain_name` 
depot_loc=`facter sasdepot_folder`
sas_sid=`facter sas_sid`
artifact_loc=`facter artifact_loc`
meta_host=`facter meta_hostname`
mid_host=`facter mid_hostname`
sasint_secret_name=`facter sasint_secret_name`
sasext_secret_name=`facter sasext_secret_name`
pub_keyname=`facter pub_keyname`
res_dir="/opt/sas/resources/responsefiles"
resource_dir="/opt/sas/resources"
cifs_server_fqdn=`facter cifs_server_fqdn`
inst_prop=${resource_dir}/meta_install.properties
conf_prop=${resource_dir}/meta_config.properties


# Getting the password
az login --identity
fail_if_error $? "Error: AZ login failed"
sasintpw=`az keyvault secret show -n $sasint_secret_name --vault-name $key_vault_name | grep value | cut -d '"' -f4`
sasextpw=`az keyvault secret show -n $sasext_secret_name --vault-name $key_vault_name | grep value | cut -d '"' -f4`
store_key=`az keyvault secret show -n $stgacc_secr_name --vault-name $key_vault_name | grep value | cut -d '"' -f4` 
echo `az keyvault secret show -n ${pub_keyname}  --vault-name ${key_vault_name} | grep value | cut -d '"' -f4` >> ~/.ssh/authorized_keys
fail_if_error $? "Error: Key vault access failed"


#Creating sas group
cat /etc/group |grep -w sas
if [ $? -eq 0 ]; then
    echo "SAS Group exists"
else
    groupadd -g 5001 sas
    fail_if_error $? "ERROR: Failed to create sas group"
fi

##Creating SAS internal Users
username=("sasinst" "sassrv" "sasdemo")
userid=("1002" "1003" "1005")
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


##Set permissions for opt-sas and sasdepot directories
if [ ! -d /opt/sas/home ]; then
    mkdir -p /opt/sas/resources /opt/sas/home /opt/sas/config
    fail_if_error $? "ERROR: SAS Software directories creation failed"
fi
chmod 775 /opt/sas -R
chown -R sasinst:sas /opt/sas
chown -R sasinst:sas /sasdata
echo "Permissions for opt-sas and sasdepot have been set."

##Mount Azure File Share for SASDepot
df -h | grep -w /sasdepot
if [ $? -eq 0 ]; then
    echo "SASDepot already mounted."
else
    if [ ! -d "/etc/smbcredentials" ]; then
        sudo mkdir /etc/smbcredentials
    fi
    if [ ! -f "/etc/smbcredentials/store.cred" ]; then
        echo "username=${store_name}" >> /etc/smbcredentials/store.cred
        echo "password=${store_key}" >> /etc/smbcredentials/store.cred
    fi
    sudo chmod 600 /etc/smbcredentials/store.cred
    sudo mount -t cifs //${cifs_server_fqdn}/${store_loc} /sasdepot -o vers=3.0,credentials=/etc/smbcredentials/store.cred,dir_mode=0777,file_mode=0777,serverino
    fail_if_error $? "ERROR: Failed to mount Azure file share"
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

##Chaning the settings in property files
sed -i "s/domain_name/${domain_name}/g" $resource_dir/*.properties
sed -i "s/host_name/${meta_host}/g" $resource_dir/*.properties
sed -i "s/mid_host/${mid_host}/g" $resource_dir/*.properties
sed -i "s|sas_plan_file_path|/opt/sas/resources/plan.xml|g" $resource_dir/*.properties
sed -i "s|sas_license_file_path|/opt/sas/resources/${sas_sid}|g" $resource_dir/*.properties

#SAS Installation
if [ -d /opt/sas/temp ]; then
    chown sasinst /opt/sas/temp
else
    mkdir -p /opt/sas/temp
    chown sasinst /opt/sas/temp
fi

if [ -f ${inst_prop} ]; then
    if [ ! -f /opt/sas/home/SASFoundation/9.4/utilities/bin/setuid.sh ]; then
        su - sasinst -c "time /sasdepot/${depot_loc}/setup.sh -deploy -responsefile ${inst_prop} -lang en -loglevel 2 -templocation /opt/sas/temp -quiet"
        if [ $? -eq 0 ]; then
            echo "SAS Metadata Server installation has been completed succesfully."
            sudo /opt/sas/home/SASFoundation/9.4/utilities/bin/setuid.sh
            echo "Setuid script has b-een run successfully."
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
/opt/sas/home/SASFoundation/9.4/bin/sas_u8 -sysin /root/encext.sas -log /root/sasencext.log
fail_if_error $? "ERROR: SAS External Password encryption failed."
encsasextpw=$(</root/encext.txt)
sed -i "s/changeextpass/${encsasextpw}/g" $resource_dir/*.properties
echo "Encrypted password has been updated successfully."
##Encrypting sasintpw password
echo  "filename pwfile '/root/encint.txt'; proc pwencode in=${sasintpw} out=pwfile; run;" > /root/encint.sas
/opt/sas/home/SASFoundation/9.4/bin/sas_u8 -sysin /root/encint.sas -log /root/sasencint.log
fail_if_error $? "ERROR: SAS Internal Password encryption failed."
encsasintpw=$(</root/encint.txt)
sed -i "s/changeintpass/${encsasintpw}/g" $resource_dir/*.properties
echo "Encrypted password has been updated succesfully."

echo "*** Phase 2 - SAS Install Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"
