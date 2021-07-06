#!/bin/bash
#set -x

echo "*** Phase 5 - Viya Script Started at `date +'%Y-%m-%d_%H-%M-%S'` ***"

#variable declaration
app_name=`facter app_name`
domain_name=`facter domain_name`
microservices_vm_name=`facter microservices_vmname`
microservice_host=$app_name$microservices_vm_name.$domain_name
user=`whoami`
spre_vm_name=`facter spre_vmname`
spre_host=$app_name$spre_vm_name.$domain_name
cascontroller_vm_name=`facter cascontroller_vmname`
cas_host=$app_name$cascontroller_vm_name.$domain_name
casworker_vm_name=`facter casworker_vmname`
nodes=`facter cas_nodes`
DIRECTORY_NFS_SHARE="sasdepot"
ansible_directory="/sas/install"
playbook_directory="$ansible_directory/sas_viya_playbook"
inventory="$playbook_directory/inventory.ini"
viyarepo_loc=`facter viyarepo_folder`
artifact_loc=`facter artifact_loc`
viya_ark_uri=${artifact_loc}properties/viya-ark.tar.gz

if [[ -z "$SCRIPT_PHASE" ]]; then
        SCRIPT_PHASE="$1"
fi

if [[ "$SCRIPT_PHASE" -eq 1 ]]; then
#
##Downloading SAS Viya Orchestration CLI
#
        echo "Download SAS Viya Orchestration CLI"
        wget https://support.sas.com/installation/viya/35/sas-orchestration-cli/lax/sas-orchestration-linux.tgz
        if [ $? -eq 0 ]; then
            tar -xvf sas-orchestration-linux.tgz -C $ansible_directory
        else 
            echo "ERROR: Download of SAS Viya Orchestration CLI failed"
        fi
 #
 ##Creating Viya Playbook
 #
        $ansible_directory/sas-orchestration build --input /${DIRECTORY_NFS_SHARE}/${viyarepo_loc}/SAS_Viya_deployment_data.zip --platform redhat --repository-warehouse "file:///${DIRECTORY_NFS_SHARE}/${viyarepo_loc}/"
        if [ $? -eq 0 ]; then
                echo PWD=`pwd`
                ##untar SAS VIYA Playbook
                tar -xvf $PWD/SAS_Viya_playbook.tgz -C $ansible_directory
        else
                echo "SAS VIYA playbook build failed"
        fi
#
##altering Ansible Config
sed -i '/action_plugins/a host_key_checking = False' $playbook_directory/ansible.cfg

#
##Altering the Vars file 
#

sed -i "s~#CAS_DISK_CACHE~CAS_DISK_CACHE~" $playbook_directory/vars.yml
sed -i "s~/tmp~/cascache~" $playbook_directory/vars.yml
sed -i "/#CAS_VIRTUAL_PORT/ a newline" $playbook_directory/vars.yml
sed -i "s|newline|    CASDATADIR: /sasdata|g" $playbook_directory/vars.yml
sed -i 's/#SASV9_CONFIGURATION/SASV9_CONFIGURATION/g' $playbook_directory/vars.yml
echo "  1: 'WORK /saswork'" >> $playbook_directory/vars.yml
echo "  2: 'UTILLOC /saswork'" >> $playbook_directory/vars.yml
sed -i 's/#sasstudio.appserver.port/sasstudio.appserver.port/g' $playbook_directory/vars.yml
sed -i 's/#sasstudio.appserver.https.port/sasstudio.appserver.https.port/g' $playbook_directory/vars.yml
sed -i "/#webdms.workspaceServer.hostName/c\    webdms.workspaceServer.hostName: ${spre_host}" $playbook_directory/vars.yml
sed -i 's/#webdms.workspaceServer.port/webdms.workspaceServer.port/g' $playbook_directory/vars.yml
sed -i 's/#FOUNDATION_CONFIGURATION/FOUNDATION_CONFIGURATION/g' $playbook_directory/vars.yml
sed -i  "/FOUNDATION_CONFIGURATION/a temploc" $playbook_directory/vars.yml
sed -i  "s|temploc|  1: COMPUTESERVER_TMP_PATH=/saswork|g" $playbook_directory/vars.yml

#
##Altering the Inventory file
#
if [ -f $inventory ]; then

sed -i 's/<machine_address>/'"$microservice_host"'/g' $inventory
sed -i 's/<userid>/'"$user"'/g' $inventory
sed -i "s~<keyfile>~/$user/.ssh/id_rsa consul_bind_adapter=eth0~" $inventory

sed -i "2i$spre_vm_name ansible_host=$spre_host ansible_user=$user ansible_ssh_private_key_file=/$user/.ssh/id_rsa consul_bind_adapter=eth0" $inventory

sed -i "3i$cascontroller_vm_name ansible_host=$cas_host ansible_user=$user ansible_ssh_private_key_file=/$user/.ssh/id_rsa consul_bind_adapter=eth0" $inventory

for ((i=0; i < $nodes ; i++))
do
  cat <<EOF >> caswork.txt
$casworker_vm_name$i
EOF
  caswork_host=$app_name$casworker_vm_name$i.$domain_name
  sed -i "4i$casworker_vm_name$i ansible_host=$caswork_host ansible_user=$user ansible_ssh_private_key_file=/$user/.ssh/id_rsa consul_bind_adapter=eth0" $inventory
done

sed -i "/\[sas_casserver_primary\]/{n;s/.*/$cascontroller_vm_name/}" $inventory
sed -i "/\[sas_casserver_worker\]/r caswork.txt" $inventory
sed -i "/\[ComputeServer\]/{n;s/.*/$spre_vm_name/}" $inventory
sed -i "/\[Operations\]/{n;s/.*/$spre_vm_name/}" $inventory
sed -i "/\[programming\]/{n;s/.*/$spre_vm_name/}" $inventory

cat <<EOF >> caswork.txt
$spre_vm_name
$cascontroller_vm_name
EOF
sed -i "/\[CommandLine\]/r caswork.txt" $inventory
rm -f caswork.txt
else
       echo "ERROR: Inventory file path doesnot exist"
fi
#
##Running System Assesement using ansible playbook
#
cd $playbook_directory && ansible-playbook system-assessment.yml -i inventory.ini -vvv

elif [[ "$SCRIPT_PHASE" -eq 2 ]]; then
         mkdir /.ssh && touch /.ssh/known_hosts 
        cd $playbook_directory && ansible-playbook install-only.yml -i inventory.ini -vvv
        echo "*** Phase 5 Part 2 - Viya Install only ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"

elif [[ "$SCRIPT_PHASE" -eq 3 ]]; then
        cd $playbook_directory && ansible-playbook site.yml -i inventory.ini -vvv
        echo "*** Phase 5 Part 3 - Viya Configuration ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"

elif [[ "$SCRIPT_PHASE" -eq 4 ]]; then
        wget $viya_ark_uri
        mkdir -p $playbook_directory/viya-ark
        tar -xzvf viya-ark.tar.gz -C $playbook_directory/viya-ark/
        ssh -tT $user@${spre_host} << EOF
echo "export SASMAKEHOMEDIR=1"     >> /opt/sas/viya/config/etc/spawner/default/spawner_usermods.sh
echo "export SASHOMEDIRPERMS=0700" >> /opt/sas/viya/config/etc/spawner/default/spawner_usermods.sh
EOF

for s in ${microservice_host} ${spre_host} ${cas_host}
do 
        ssh -tT $user@$s << EOF
. /opt/sas/viya/config/consul.conf
/opt/sas/viya/home/bin/sas-bootstrap-config --token-file /opt/sas/viya/config/etc/SASSecurityCertificateFramework/tokens/consul/default/client.token kv write config/launcher-server/global/environment/SASMAKEHOMEDIR 1
/opt/sas/viya/home/bin/sas-bootstrap-config --token-file /opt/sas/viya/config/etc/SASSecurityCertificateFramework/tokens/consul/default/client.token kv write config/launcher-server/global/environment/SASHOMEDIRPERMS 0700
EOF
done

for ((i=0; i < $nodes ; i++))
do
        casworker_node=$app_name$casworker_vm_name$i.$domain_name
        ssh -tT $user@$casworker_node << EOF
. /opt/sas/viya/config/consul.conf
/opt/sas/viya/home/bin/sas-bootstrap-config --token-file /opt/sas/viya/config/etc/SASSecurityCertificateFramework/tokens/consul/default/client.token kv write config/launcher-server/global/environment/SASMAKEHOMEDIR 1
/opt/sas/viya/home/bin/sas-bootstrap-config --token-file /opt/sas/viya/config/etc/SASSecurityCertificateFramework/tokens/consul/default/client.token kv write config/launcher-server/global/environment/SASHOMEDIRPERMS 0700
EOF
done
echo `ssh -o StrictHostKeyChecking=no $app_name$microservices_vm_name "grep -H -r "sasboot" /var/log/sas/viya/saslogon/default/sas-saslogon*  | sed 's/.*code=//'"`
sasboot=`ssh -o StrictHostKeyChecking=no $app_name$microservices_vm_name "grep -H -r "sasboot" /var/log/sas/viya/saslogon/default/sas-saslogon*  | sed 's/.*code=//'"`
echo "{'SAS_BOOT': '$sasboot'}" > /var/log/sas/install/sasboot.log
echo "#SASBOOT#"
cat /var/log/sas/install/sasboot.log
fi