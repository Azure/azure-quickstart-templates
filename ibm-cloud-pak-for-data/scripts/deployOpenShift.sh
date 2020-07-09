#!/bin/bash

echo $(date) " - Starting Script"

set -e

export SUDOUSER=$1
export PASSWORD="$2"
export PRIVATEKEY=$3
export MASTER=$4
export MASTERPUBLICIPHOSTNAME=$5
export MASTERPUBLICIPADDRESS=$6
export INFRA=$7
export NODE=$8
export NODECOUNT=$9
export INFRACOUNT=${10}
export MASTERCOUNT=${11}
export ROUTING=${12}
export REGISTRYSA=${13}
export ACCOUNTKEY="${14}"
export TENANTID=${15}
export SUBSCRIPTIONID=${16}
export AADCLIENTID=${17}
export AADCLIENTSECRET="${18}"
export RESOURCEGROUP=${19}
export LOCATION=${20}
export METRICS=${21}
export LOGGING=${22}
export AZURE=${23}
export STORAGEKIND=${24}
export RHEL_USERNAME=${25}
export RHEL_PASSWORD=${26}
export DATA_STORAGEACCOUNT=${27}
export VNETNAME=${28}
export NODESECURITYGROUP=${29}
export NODEAVAILABILITYSET=${30}
export RHELPOOLID=${31}
export STORAGEOPTION=${32}
export NFSHOST=${33}
export SINGLEMULTI=${34}
export ARTIFACTSLOCATIONTOKEN="${35}"
export ARTIFACTSLOCATION=${36::-1}
export INFRAPUBLICIP=${37}
#TEMPPASSWORD=${38}
export OCUSER=$1
export OCPASSWORD="$2"

# Determine if Commercial Azure or Azure Government
CLOUD=$( curl -H Metadata:true "http://169.254.169.254/metadata/instance/compute/location?api-version=2017-04-02&format=text" | cut -c 1-2 )
export CLOUD=${CLOUD^^}

export MASTERLOOP=$((MASTERCOUNT - 1))
export INFRALOOP=$((INFRACOUNT - 1))
export NODELOOP=$((NODECOUNT - 1))

# Generate private keys for use by Ansible
echo $(date) " - Generating Private keys for use by Ansible for OpenShift Installation"

runuser -l $SUDOUSER -c "echo \"$PRIVATEKEY\" > /home/$SUDOUSER/.ssh/id_rsa"
runuser -l $SUDOUSER -c "chmod 600 /home/$SUDOUSER/.ssh/id_rsa*"

echo $(date) "- Configuring SSH ControlPath to use shorter path name"

sed -i -e "s/^# control_path = %(directory)s\/%%h-%%r/control_path = %(directory)s\/%%h-%%r/" /etc/ansible/ansible.cfg
sed -i -e "s/^#host_key_checking = False/host_key_checking = False/" /etc/ansible/ansible.cfg
sed -i -e "s/^#pty=False/pty=False/" /etc/ansible/ansible.cfg
sed -i -e "s/^#stdout_callback = skippy/stdout_callback = skippy/" /etc/ansible/ansible.cfg

# Cloning Ansible playbook repository
((cd /home/$SUDOUSER && git clone https://github.com/Microsoft/openshift-container-platform-playbooks.git) || (cd /home/$SUDOUSER/openshift-container-platform-playbooks && git pull))
if [ -d /home/$SUDOUSER/openshift-container-platform-playbooks ]
then
  echo " - Retrieved playbooks successfully"
else
  echo " - Retrieval of playbooks failed"
  exit 99
fi

# Create docker registry config based on Commercial Azure or Azure Government
if [[ $CLOUD == "US" ]]
then
  DOCKERREGISTRYYAML=dockerregistrygov.yaml
  export CLOUDNAME="AzureUSGovernmentCloud"
else
  DOCKERREGISTRYYAML=dockerregistrypublic.yaml
  export CLOUDNAME="AzurePublicCloud"
fi

# Create Master nodes grouping
echo $(date) " - Creating Master nodes grouping"

if [[ $INFRACOUNT == 0 ]];then
masterinfra="node-config-master-infra"
else
masterinfra="node-config-master"
fi

for (( c=0; c<$MASTERCOUNT; c++ ))
do
  mastergroup="$mastergroup
$MASTER-$c openshift_node_group_name=\"$masterinfra\""
done

# Create Infra nodes grouping
echo $(date) " - Creating Infra nodes grouping"

for (( c=0; c<$INFRACOUNT; c++ ))
do
  infragroup="$infragroup
$INFRA-$c openshift_node_group_name=\"node-config-infra\""
done

# Create Nodes grouping
echo $(date) " - Creating Nodes grouping"

for (( c=0; c<$NODECOUNT; c++ ))
do
  nodegroup="$nodegroup
$NODE-$c openshift_node_group_name=\"node-config-compute\""
done

#Storage grouping
echo $(date) " - Creating Storage Nodes grouping"

if [[ $STORAGEOPTION == "glusterfs" ]]
then
  for (( c=0; c<$NODECOUNT; c++ ))
  do
    storagegroup="$storagegroup
$NODE-$c glusterfs_devices='[\"/dev/sdc\"]'"
  done

  if [[ $NODECOUNT < 3 ]]
  then
  for (( c=0; c<$INFRACOUNT; c++ ))
  do
    storagegroup="$storagegroup
$INFRA-$c glusterfs_devices='[\"/dev/sdc\"]'"
  done
  fi
  glustercount=$(($NODECOUNT + $INFRACOUNT))
  if [[ $glustercount < 3 ]]
  then
  for (( c=1; c<$MASTERCOUNT; c++ ))
  do
    storagegroup="$storagegroup
$MASTER-$c glusterfs_devices='[\"/dev/sdc\"]'"
  done
  fi
else
  storagegroup="$NFSHOST-0"
fi

# Set HA mode if 3 or 5 masters chosen
if [[ $MASTERCOUNT != 1 ]]
then
	export HAMODE="openshift_master_cluster_method=native"
fi

if [[ $RHELPOOLID == "" ]]
then
	export OPENSHIFT_OAUTH=""
  export OPENSHIFT_TYPE="origin"
else
  export OPENSHIFT_TYPE="openshift-enterprise"
  export OPENSHIFT_OAUTH="oreg_auth_user=$RHEL_USERNAME
oreg_auth_password=$RHEL_PASSWORD"
fi

if [[ $ROUTING == "nipio" ]];then
export PUBLICDEPLOY="openshift_master_default_subdomain=$INFRAPUBLICIP.nip.io
openshift_master_cluster_hostname=$MASTERPUBLICIPHOSTNAME
openshift_master_cluster_public_hostname=$MASTERPUBLICIPHOSTNAME
openshift_master_cluster_public_vip=$MASTERPUBLICIPADDRESS
openshift_master_logging_public_url=https://kibana.$INFRAPUBLICIP.nip.io
openshift_logging_master_public_url=https://$MASTERPUBLICIPHOSTNAME:443"
fi

#GlusterFS Vars
if [[ $STORAGEOPTION == "glusterfs" ]]
then
  export STORAGEVARS="openshift_storage_glusterfs_image=registry.redhat.io/rhgs3/rhgs-server-rhel7:v3.11
openshift_storage_glusterfs_block_image=registry.redhat.io/rhgs3/rhgs-gluster-block-prov-rhel7:v3.11
openshift_storage_glusterfs_heketi_image=registry.redhat.io/rhgs3/rhgs-volmanager-rhel7:v3.11

openshift_storage_glusterfs_namespace=glusterfs
openshift_storage_glusterfs_storageclass=true
openshift_storage_glusterfs_storageclass_default=true
openshift_storage_glusterfs_block_deploy=false"
fi

# Single or Multi Zone
if [[ $SINGLEMULTI == 'single' ]]
then
	export AZORAS="openshift_cloudprovider_azure_availability_set_name=$NODEAVAILABILITYSET"
fi

# Setting the default openshift_cloudprovider_kind if Azure enabled
if [[ $AZURE == "true" ]]
then
	export CLOUDKIND="openshift_cloudprovider_azure_client_id=$AADCLIENTID
openshift_cloudprovider_azure_client_secret=$AADCLIENTSECRET
openshift_cloudprovider_azure_tenant_id=$TENANTID
openshift_cloudprovider_azure_subscription_id=$SUBSCRIPTIONID
openshift_cloudprovider_azure_cloud=$CLOUDNAME
openshift_cloudprovider_azure_vnet_name=$VNETNAME
openshift_cloudprovider_azure_security_group_name=$NODESECURITYGROUP
openshift_cloudprovider_azure_resource_group=$RESOURCEGROUP
openshift_cloudprovider_azure_location=$LOCATION
  CNS_DEFAULT_STORAGE=false"
	if [[ $STORAGEKIND == "managed" ]]
	then
		SCKIND="openshift_storageclass_parameters={'kind': 'managed', 'storageaccounttype': 'Premium_LRS'}"
	else
		SCKIND="openshift_storageclass_parameters={'kind': 'shared', 'storageaccounttype': 'Premium_LRS'}"
	fi
fi

# Create Ansible Hosts File
echo $(date) " - Create Ansible Hosts file"

cat > /etc/ansible/hosts <<EOF
# Create an OSEv3 group that contains the masters and nodes groups
[OSEv3:children]
masters
nodes
etcd
master0
new_nodes
new_masters
$STORAGEOPTION

# Set variables common for all OSEv3 hosts
[OSEv3:vars]
ansible_ssh_user=$SUDOUSER
ansible_become=yes
ansible_ssh_pass=${38}
$OPENSHIFT_OAUTH
openshift_deployment_type=$OPENSHIFT_TYPE
openshift_override_hostname_check=true
openshift_master_api_port=443
openshift_master_console_port=443

openshift_disable_check=docker_storage,disk_availability,memory_availability,docker_image_availability
$CLOUDKIND
$AZORAS

$HAMODE
$PUBLICDEPLOY

# Enable HTPasswdPasswordIdentityProvider
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]

# Disable service catalog - Install after cluster is up if Azure Cloud Provider is enabled
openshift_enable_service_catalog=false

# Disable the OpenShift SDN plugin
# openshift_use_openshift_sdn=true

# Variables if GlusterFS is selected
$STORAGEVARS

# Setup metrics
openshift_metrics_install_metrics=false
openshift_metrics_start_cluster=true
openshift_metrics_hawkular_nodeselector={"node-role.kubernetes.io/infra":"true"}
openshift_metrics_cassandra_nodeselector={"node-role.kubernetes.io/infra":"true"}
openshift_metrics_heapster_nodeselector={"node-role.kubernetes.io/infra":"true"}
# openshift_metrics_hawkular_hostname=https://hawkular-metrics.$INFRAPUBLICIP.nip.io/hawkular/metrics

# Setup logging
openshift_logging_install_logging=false
openshift_logging_fluentd_nodeselector={"logging":"true"}
openshift_logging_es_nodeselector={"node-role.kubernetes.io/infra":"true"}
openshift_logging_kibana_nodeselector={"node-role.kubernetes.io/infra":"true"}
openshift_logging_curator_nodeselector={"node-role.kubernetes.io/infra":"true"}
openshift_logging_elasticsearch_memory_limit=1Gi
#openshift_logging_es_number_of_shards=3

# host group for masters
[masters]
$MASTER-[0:${MASTERLOOP}]

# host group for etcd
[etcd]
$MASTER-[0:${MASTERLOOP}]

[master0]
$MASTER-0

[$STORAGEOPTION]
$storagegroup

# host group for nodes
[nodes]
$mastergroup
$infragroup
$nodegroup

# host group for new nodes
[new_nodes]

# host group for new masters
[new_masters]
EOF

echo $(date) " - Download ansible config files"
echo $(date) " - Cloning openshift-ansible repo for use in installation"

runuser -l $SUDOUSER -c "(cd /home/$SUDOUSER && wget $ARTIFACTSLOCATION/ansible-config/config.yml\"$ARTIFACTSLOCATIONTOKEN\" -O config.yml)"

if [ ! -d /home/$SUDOUSER/openshift-ansible ]
then
  (cd /home/$SUDOUSER && git clone -b release-3.11 https://github.com/openshift/openshift-ansible)
fi

chmod -R 777 /home/$SUDOUSER/openshift-ansible
echo $(date) " - Cloning openshift-ansible repo for use in installation - COMPLETED"

# Create Azure File Storage Class
cat > /home/$SUDOUSER/azure-file.yml <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azurefile
provisioner: kubernetes.io/azure-file
mountOptions:
  - dir_mode=0777
  - file_mode=0777
parameters:
  skuName: Premium_LRS
  location: $LOCATION
  storageAccount: $DATA_STORAGEACCOUNT
EOF

# Create /etc/origin/cloudprovider/azure.conf on all hosts if Azure is enabled
if [[ $AZURE == "true" ]]
then
	runuser $SUDOUSER -c "ansible-playbook -f 10 /home/$SUDOUSER/openshift-container-platform-playbooks/create-azure-conf.yaml"
	if [ $? -eq 0 ]
	then
		echo $(date) " - Creation of Cloud Provider Config (azure.conf) completed on all nodes successfully"
	else
		echo $(date) " - Creation of Cloud Provider Config (azure.conf) completed on all nodes failed to complete"
		exit 13
	fi
fi

# Configure Cluster
echo $(date) " - Configure Cluster"
runuser -l $SUDOUSER -c "ansible-playbook /home/$SUDOUSER/config.yml --extra-vars \"poolid=$RHELPOOLID\""

if [[ $STORAGEOPTION != "portworx" ]]
then
	runuser -l $SUDOUSER -c "(cd /home/$SUDOUSER && wget $ARTIFACTSLOCATION/ansible-config/$STORAGEOPTION.yml\"$ARTIFACTSLOCATIONTOKEN\" -O $STORAGEOPTION.yml)"
	runuser -l $SUDOUSER -c "ansible-playbook /home/$SUDOUSER/$STORAGEOPTION.yml"
fi

# Initiating installation of OpenShift Origin prerequisites using Ansible Playbook
echo $(date) " - Running Prerequisites via Ansible Playbook"
runuser -l $SUDOUSER -c "ansible-playbook -f 10 /home/$SUDOUSER/openshift-ansible/playbooks/prerequisites.yml"

echo $(date) " - Prerequisites check complete"

# Initiating installation of OpenShift Origin using Ansible Playbook
echo $(date) " - Installing OpenShift Container Platform via Ansible Playbook"

runuser -l $SUDOUSER -c "ansible-playbook -f 10 /home/$SUDOUSER/openshift-ansible/playbooks/deploy_cluster.yml"
echo $(date) " - OpenShift Origin Cluster install complete"

# echo $(date) " - Running additional playbooks to finish configuring and installing other components"

echo $(date) "Create OC Credentials"
runuser -l $SUDOUSER -c "ansible master0 -m command -a \"oc create user '$OCUSER'\""
runuser -l $SUDOUSER -c "ansible masters -m command -a \"htpasswd -b /etc/origin/master/htpasswd '$OCUSER' '$OCPASSWORD'\""
runuser -l $SUDOUSER -c "ansible master0 -m command -a \"oc adm policy add-cluster-role-to-user cluster-admin '$OCUSER'\""
echo $(date) "OC Credentials create complete"

# Configure Docker Registry to use Azure Storage Account
echo $(date) "- Configuring Docker Registry to use Azure Storage Account"
runuser $SUDOUSER -c "ansible-playbook -f 10 /home/$SUDOUSER/openshift-container-platform-playbooks/$DOCKERREGISTRYYAML"
echo $(date) "- Configuring Docker Registry Completed"

# Login User
echo $(date) "Login User"
runuser -l $SUDOUSER -c "oc login https://$MASTERPUBLICIPADDRESS:443 -u '$OCUSER' -p '$OCPASSWORD' --insecure-skip-tls-verify=true"
########################## POST INSTALL ###################

echo $(date) "Installing helm"
runuser -l $SUDOUSER -c "curl -L https://git.io/get_helm.sh | bash"

if [ $STORAGEOPTION == "portworx" ]
then
	echo $(date) "Portworx Cluster Authorization"
	# Portworx runs as a privileged container. Hence you need to add the Portworx service accounts to the privileged security context.
	runuser -l $SUDOUSER -c "oc adm policy add-scc-to-user privileged system:serviceaccount:kube-system:px-account"
	runuser -l $SUDOUSER -c "oc adm policy add-scc-to-user privileged system:serviceaccount:kube-system:portworx-pvc-controller-account"
	runuser -l $SUDOUSER -c "oc adm policy add-scc-to-user privileged system:serviceaccount:kube-system:px-lh-account"
	runuser -l $SUDOUSER -c "oc adm policy add-scc-to-user anyuid system:serviceaccount:kube-system:px-lh-account"
	runuser -l $SUDOUSER -c "oc adm policy add-scc-to-user anyuid system:serviceaccount:default:default"
	runuser -l $SUDOUSER -c "oc adm policy add-scc-to-user privileged system:serviceaccount:kube-system:px-csi-account"

	#Create Secrets for PX
	runuser -l $SUDOUSER -c "oc create secret generic -n kube-system px-azure --from-literal=AZURE_TENANT_ID=$TENANTID \
														--from-literal=AZURE_CLIENT_ID=$AADCLIENTID \
														--from-literal=AZURE_CLIENT_SECRET=$AADCLIENTSECRET"

	# Deploy Portworx
	runuser -l $SUDOUSER -c "(cd /home/$SUDOUSER && wget $ARTIFACTSLOCATION/ansible-config/px-spec.yaml\"$ARTIFACTSLOCATIONTOKEN\" -O px-spec.yaml)"
	runuser -l $SUDOUSER -c "oc create -f /home/$SUDOUSER/px-spec.yaml"

cat > /home/$SUDOUSER/px-sc.yaml << EOF
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: portworx-sc
provisioner: com.openstorage.pxd
parameters:
  repl: "3"
  priority_io: "high"
  shared: "true"
EOF
	runuser -l $SUDOUSER -c "oc create -f /home/$SUDOUSER/px-sc.yaml"
	echo $(date) "Set PX as default"
	runuser -l $SUDOUSER -c "oc patch storageclass portworx-sc -p '{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"true\"}}}'"
	echo $(date) "Set PX as default complete"
fi

if [[ $STORAGEOPTION == "nfs" ]]; then
  runuser -l $SUDOUSER -c "oc adm policy add-scc-to-user hostmount-anyuid system:serviceaccount:kube-system:nfs-client-provisioner"
  runuser -l $SUDOUSER -c "(cd /home/$SUDOUSER && wget $ARTIFACTSLOCATION/ansible-config/nfs-template.yaml\"$ARTIFACTSLOCATIONTOKEN\" -O nfs-template.yaml)"
  runuser -l $SUDOUSER -c "oc process -f /home/$SUDOUSER/nfs-template.yaml -p NFS_SERVER=$(getent hosts $storagegroup | awk '{ print $1 }') -p NFS_PATH=/exports/home | oc create -n kube-system -f -"
  echo $(date) "Set NFS as default"
  runuser -l $SUDOUSER -c "oc patch storageclass nfs -p '{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"true\"}}}'"
  echo $(date) "Set NFS as default complete"
fi

# Configure Default Storage
echo $(date) "Creating Azure File Storage Class"
runuser -l $SUDOUSER -c "oc create -f /home/$SUDOUSER/azure-file.yml"
echo $(date) "Azure File StorageClass Create Complete"

# Configure Metrics
if [ $METRICS == "true" ]
then
	sleep 30
	echo $(date) "- Deploying Metrics"
	if [ $AZURE == "true" ]
	then
		runuser -l $SUDOUSER -c "ansible-playbook -f 10 /home/$SUDOUSER/openshift-ansible/playbooks/openshift-metrics/config.yml -e openshift_metrics_install_metrics=True -e openshift_metrics_cassandra_storage_type=dynamic -e openshift_metrics_image_version=v3.11"
	else
		runuser -l $SUDOUSER -c "ansible-playbook -f 10 /home/$SUDOUSER/openshift-ansible/playbooks/openshift-metrics/config.yml -e openshift_metrics_install_metrics=True -e openshift_metrics_image_version=v3.11"
	fi
	if [ $? -eq 0 ]
	then
	   echo $(date) " - Metrics configuration completed successfully"
	else
	   echo $(date) "- Metrics configuration failed"
	   exit 11
	fi
fi

# Configure Logging

if [ $LOGGING == "true" ]
then
	sleep 60
	echo $(date) "- Deploying Logging"
	if [ $AZURE == "true" ]
	then
		runuser -l $SUDOUSER -c "ansible-playbook -f 10 /home/$SUDOUSER/openshift-ansible/playbooks/openshift-logging/config.yml -e openshift_logging_install_logging=True -e openshift_logging_es_pvc_dynamic=true -e openshift_master_dynamic_provisioning_enabled=True"
	else
		runuser -l $SUDOUSER -c "ansible-playbook -f 10 /home/$SUDOUSER/openshift-ansible/playbooks/openshift-logging/config.yml -e openshift_logging_install_logging=True"
	fi
	if [ $? -eq 0 ]
	then
	   echo $(date) " - Logging configuration completed successfully"
	else
	   echo $(date) "- Logging configuration failed"
	   exit 12
	fi
fi

# Delete yaml files
echo $(date) "- Deleting unecessary files"
rm -rf /home/$SUDOUSER/openshift-container-platform-playbooks
rm -rf /home/$SUDOUSER/*.yml

echo $(date) " - Script complete"
