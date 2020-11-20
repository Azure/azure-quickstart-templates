#!/bin/bash
set -x
echo "*** Phase 2-PSS installation Script Started at `date +'%Y-%m-%d_%H-%M-%S'` ***"

## Function for error handling
fail_if_error() {
  [ $1 != 0 ] && {
    echo $2
    exit 10
  }
}

#Variables
SASSoftwareDepo=`facter sasdepot_folder` 
Domain=`facter domain_name`
app_name=`facter application_name`
sas_role=`facter sas_role`
count=`facter grid_nodes`
grid_hostname=`facter grid_hostname`
mid_hostname=`facter mid_hostname`
SASInstallLoc="/opt/sas"
lsf_sid=`facter lsf_sid`
sas_lustre_dir="/opt/sas"
res_dir="/opt/sas/resources/responsefiles"
resource_dir="/opt/sas/resources"
artifact_loc=`facter artifact_loc`
#lsf_install_config_url=${artifact_loc}properties/lsf_install.config
GridInstallTempLoc="$SASInstallLoc/platform/tmp"
LSFInstallLoc="$SASInstallLoc/platform/lsf"
PMInstallLoc="$SASInstallLoc/platform/pm"
pub_keyname=`facter pub_keyname`
key_vault_name=`facter key_vault_name`
sasint_secret_name=`facter sasint_secret_name`
sasext_secret_name=`facter sasext_secret_name`

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
cp -p /tmp/lustre_packages.zip /tmp/lustre_package/
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
if [ -d $res_dir ]; then
   chown sasinst:sas $res_dir
else
   mkdir -p $res_dir
   chown sasinst:sas $res_dir
fi

if [ -d $sas_lustre_dir/$sas_role/config ]; then
   chown sasinst:sas $sas_lustre_dir/$sas_role/config
else
   mkdir -p $sas_lustre_dir/$sas_role/config
   chown sasinst:sas $sas_lustre_dir/$sas_role/config
fi

if [ -d $sas_lustre_dir/$sas_role/sashome ]; then
   chown sasinst:sas $sas_lustre_dir/$sas_role/sashome
else
   mkdir -p $sas_lustre_dir/$sas_role/sashome
   chown sasinst:sas $sas_lustre_dir/$sas_role/sashome
fi

if [ -d $sas_lustre_dir/platform ]; then
   chown sasinst:sas $sas_lustre_dir/platform
else
   mkdir -p $sas_lustre_dir/platform
   chown sasinst:sas $sas_lustre_dir/platform
fi

if [ -d $sas_lustre_dir/gridshare ]; then
   chown sasinst:sas $sas_lustre_dir/gridshare
   chmod 777 $sas_lustre_dir/gridshare
else
   mkdir -p $sas_lustre_dir/gridshare
   chown sasinst:sas $sas_lustre_dir/gridshare
   chmod 777 $sas_lustre_dir/gridshare
fi

if [ -d $sas_lustre_dir/backup ]; then
   chown sasinst:sas $sas_lustre_dir/backup
else
   mkdir -p $sas_lustre_dir/backup
   chown sasinst:sas $sas_lustre_dir/backup
fi
chown sasinst:sas $sas_lustre_dir -R


#Downloading the lsf_install.config file
tar -xzvf /tmp/response-properties.tar.gz -C ${res_dir}
cp -p ${res_dir}/lsf_install.config ${resource_dir}
chown -R sasinst:sas ${resource_dir}

sed -i "s/domain_name/${Domain}/g" $resource_dir/lsf_install.config
sed -i "s/grid_host/$grid_hostname/g" $resource_dir/lsf_install.config
sed -i "s/mid_host/$mid_hostname/g" $resource_dir/lsf_install.config
sed -i "s|pminstallloc|$PMInstallLoc|g" $resource_dir/lsf_install.config
sed -i "s|lsfinstallloc|$LSFInstallLoc|g" $resource_dir/lsf_install.config

i=1
gridhostname=""
if [ $count == 0 ]; then
   sed -i "s/gridnodes//g" $resource_dir/lsf_install.config
else
   while [ "$count" != "0" ] ; do
      #echo grid0$i.$Domain
      gridhostname=${gridhostname}" "${app_name}gridnode$i.$Domain
      i=$(($i+1))
      count=$(($count-1))
   done
   sed -i "s/gridnodes/$gridhostname/g" $resource_dir/lsf_install.config
fi


mkdir -p $GridInstallTempLoc $LSFInstallLoc $PMInstallLoc
cp /sasdepot/$SASSoftwareDepo/third_party/Platform_Process_Manager/*/Linux_for_x64/*.tar $GridInstallTempLoc
cp /sasdepot/$SASSoftwareDepo/third_party/Platform_Grid_Management_Service/*/Linux_for_x64/gms*.tar.Z $GridInstallTempLoc
PMInstallTemp=`tar xvf $GridInstallTempLoc/*.tar -C $GridInstallTempLoc | tail -n 1 | cut -d '/' -f 2`
cp /sasdepot/$SASSoftwareDepo/sid_files/$lsf_sid $GridInstallTempLoc/$PMInstallTemp/license.dat
cp $resource_dir/lsf_install.config $GridInstallTempLoc/$PMInstallTemp/install.config


#LSF and PM install on Master only
sed -i.bak 's+\./_jsinstall.*+\./_jsinstall -y -s -f _install.config+' $GridInstallTempLoc/$PMInstallTemp/jsinstall
cd $GridInstallTempLoc/$PMInstallTemp ; echo 1 | ./jsinstall -f ./install.config

result=`echo "$?"`
if [ "$result" == "0" ]; then
   echo "*******LSF & PM  installation completed successfully******"
else
   echo "Error: LSF & PM  installation failed"
   exit 1
fi

#Post install
chmod 0777 $LSFInstallLoc/work
chmod 0777 $LSFInstallLoc/log -R

count=`facter grid_nodes`
cp $LSFInstallLoc/conf/lsf.cluster.sas_cluster $LSFInstallLoc/conf/lsf.cluster.sas_cluster_bkp
if [ $count == 0 ]; then
   sed -i "s/$app_name$sas_role.$Domain   !   !   1   (mg)/$app_name$sas_role.$Domain   !   !   1   (mg SASApp)/g" $LSFInstallLoc/conf/lsf.cluster.sas_cluster
else
   i=1
   while [ "$count" != "0" ] ; do
      #echo grid0$i.$Domain
      sed -i "s/$app_name$sas_role.$Domain   !   !   1   (mg)/$app_name$sas_role.$Domain   !   !   1   (mg SASApp)/g" $LSFInstallLoc/conf/lsf.cluster.sas_cluster
      sed -i "s/${app_name}gridnode$i.$Domain   !   !   1   (mg)/${app_name}gridnode$i.$Domain   !   !   1   (mg SASApp)/g" $LSFInstallLoc/conf/lsf.cluster.sas_cluster
      echo $?
		i=$(($i+1))
      count=$(($count-1))
   done
fi

# Adding SASApp resource to LSF
sed -i "$ i SASApp     Boolean    ()       ()       ()" $LSFInstallLoc/conf/lsf.shared

#Get the binaries directories of PM and LSF
LSFBinDir=`ls -l $LSFInstallLoc | sed '2q;d' |  awk '{print $NF}'`
PMBinDir=`ls -l $PMInstallLoc | sed '2q;d' |  awk '{print $NF}'`

# LSF on boot auto start config
cd $LSFInstallLoc/$LSFBinDir/install ; ./hostsetup --top="$LSFInstallLoc" --boot="y" --profile="y"  --start="y"
fail_if_error $? "Error: LSF hostsetup utility failed"

if [ ! -f /etc/lsf.sudoers ]; then
   echo "LSF_STARTUP_PATH=$LSFInstallLoc/$LSFBinDir/linux2.6-glibc2.3-x86_64/etc" >> /etc/lsf.sudoers
   echo 'LSF_STARTUP_USERS="sasinst lsfadmin"' >> /etc/lsf.sudoers
fi

# PM on boot auto start config
source $PMInstallLoc/conf/profile.js; jadmin start
source $PMInstallLoc/conf/profile.js; $PMInstallLoc/$PMBinDir/install/bootsetup
fail_if_error $? "Error: PM bootsetup failed"

#GMS install on Master only
gunzip -d $GridInstallTempLoc/gms*_install.tar.Z
GMSInstallTempLoc=`tar xvf $GridInstallTempLoc/gms*_install.tar -C $GridInstallTempLoc | tail -n 1 | cut -d '/' -f 1`

echo "LSF_TOP=$LSFInstallLoc" >> $GridInstallTempLoc/$GMSInstallTempLoc/install.config
echo 'BOOT="Y"' >> $GridInstallTempLoc/$GMSInstallTempLoc/install.config

cd $GridInstallTempLoc/$GMSInstallTempLoc; ./gmsinstall -f install.config
fail_if_error $? "Error: GMS Installation failed"

$LSFInstallLoc/gms/bin/gaadmin start
fail_if_error $? "Error: GMS service failed to start"
result=`echo "$?"`

#change ownership
chown -R sasinst:sas $LSFInstallLoc
chown -R sasinst:sas $PMInstallLoc

echo "*** Phase 4 - PSS installation Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"
