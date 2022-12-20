#!/bin/bash
set -x

echo "*** Phase 2 - Viya-ARK Script Started at `date +'%Y-%m-%d_%H-%M-%S'` ***"


## Functions
fail_if_error() {
  [ $1 != 0 ] && {
    echo $2
    exit 10
  }
}

#Variable declaration
pub_keyname=`facter secret_pub_keyname`
key_vault_name=`facter kv_vault_name`
artifact_loc=`facter artifact_loc`
sasint_secret_name=`facter sasintpwd`
sasext_secret_name=`facter casintpwd`
CODE_DIRECTORY="/opt/viya-ark"
playbook_directory="$CODE_DIRECTORY/pre-install-playbook"
#viya_ark_file=`facter viya_ark_file`

# Setting up the public key under root user for passwordless SSH
az login --identity
fail_if_error $? "ERROR: Azure login failed"
saspwd=`az keyvault secret show -n $sasint_secret_name --vault-name $key_vault_name | grep value | cut -d '"' -f4`
caspwd=`az keyvault secret show -n $sasext_secret_name --vault-name $key_vault_name | grep value | cut -d '"' -f4`
echo `az keyvault secret show -n ${pub_keyname}  --vault-name ${key_vault_name} | grep value | cut -d '"' -f4` >> ~/.ssh/authorized_keys

#wget $viya_ark_file

##untar viya-ark
if [ ! -d ${CODE_DIRECTORY} ]; then
    mkdir -p ${CODE_DIRECTORY}
fi
  tar -xzvf /tmp/viya-ark.tar.gz -C ${CODE_DIRECTORY}
  fail_if_error $? "viya-ark file not found"
#
## Running the Ansible Playbook on the Viya Servers
#
cd $playbook_directory && ansible-playbook viya_pre_install_playbook.yml -i pre-install.inventory.ini  -vvv
#
## Setting up Password for user SAS and CAS
#
username=("sas" "cas")
password=("$saspwd" "$caspwd")
for ((i=0;i<${#username[@]};++i));
do
        if [ `sed -n "/^${username[$i]}/p" /etc/passwd` ]
        then
                echo "Setting the password for ${username[$i]}"
                echo ${password[$i]} | passwd ${username[$i]}  --stdin
    else
                echo "User ${username[$i]} doesn't exist"
        fi
done

echo "*** Phase 2 - Viya-ARK Script ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"