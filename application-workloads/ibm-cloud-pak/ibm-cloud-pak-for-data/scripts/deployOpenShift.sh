#!/bin/bash

echo $(date) " - ############## Starting Script ####################"

set -e

export SUDOUSER=$1
export OPENSHIFTPASSWORD=$2
export SSHKEY=$3
export WORKERCOUNT=$4
export MASTERCOUNT=$5
export SUBSCRIPTIONID=$6
export TENANTID=$7
export AADCLIENTID=$8
export AADSECRET=$9
export RESOURCEGROUPNAME=${10}
export LOCATION=${11}
export VIRTUALNETWORKNAME=${12}
export PXSPECURL=${13}
export STORAGEOPTION=${14}
export NFSIPADDRESS=${15}
export SINGLEORMULTI=${16}
export ARTIFACTSLOCATION=${17::-1}
export ARTIFACTSTOKEN=\"${18}\"
export BASEDOMAIN=${19}
export MASTERINSTANCETYPE=${20}
export WORKERINSTANCETYPE=${21}
export CLUSTERNAME=${22}
export CLUSTERNETWORKCIDR=${23}
export HOSTADDRESSPREFIX=${24}
export VIRTUALNETWORKCIDR=${25}
export SERVICENETWORKCIDR=${26}
export BASEDOMAINRG=${27}
export NETWORKRG=${28}
export MASTERSUBNETNAME=${29}
export WORKERSUBNETNAME=${30}
export PULLSECRET=${31}
export FIPS=${32}
export PUBLISH=${33}
export OPENSHIFTUSER=${34}
export ENABLEAUTOSCALER=${35}
export OUTBOUNDTYPE=${36}
export EXISTING_RESOURCE_GROUP_NAME=${37}

#Var
export INSTALLERHOME=/home/$SUDOUSER/.openshift

echo $(date) " - Disable and enable repo starting"
sudo yum update -y --disablerepo=* --enablerepo="*microsoft*"
echo $(date) " - Disable and enable repo completed"

# Grow Root File System
yum -y install cloud-utils-growpart.noarch
echo $(date) " - Grow Root FS"

rootdev=`findmnt --target / -o SOURCE -n`
rootdrivename=`lsblk -no pkname $rootdev`
rootdrive="/dev/"$rootdrivename
name=`lsblk  $rootdev -o NAME | tail -1`
part_number=${name#*${rootdrivename}}

growpart $rootdrive $part_number -u on
xfs_growfs $rootdev

if [ $? -eq 0 ]
then
    echo $(date) " - Root File System successfully extended"
else
    echo $(date) " - Root File System failed to be grown"
	exit 20
fi

echo $(date) " - Install Podman"
yum install -y podman
echo $(date) " - Install Podman Complete"

echo $(date) " - Install httpd-tools"
yum install -y httpd-tools
echo $(date) " - Install httpd-tools Complete"

echo $(date) " - Download Binaries"
runuser -l $SUDOUSER -c "mkdir -p /home/$SUDOUSER/.openshift"

runuser -l $SUDOUSER -c "wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.8.11/openshift-install-linux-4.8.11.tar.gz"
runuser -l $SUDOUSER -c "wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.8.11/openshift-client-linux-4.8.11.tar.gz"
runuser -l $SUDOUSER -c "tar -xvf openshift-install-linux-4.8.11.tar.gz -C $INSTALLERHOME"
runuser -l $SUDOUSER -c "sudo tar -xvf openshift-client-linux-4.8.11.tar.gz -C /usr/bin"

chmod +x /usr/bin/kubectl
chmod +x /usr/bin/oc
chmod +x $INSTALLERHOME/openshift-install
echo $(date) " - Download Binaries Done."

echo $(date) " - Setup Azure Credentials for OCP"
runuser -l $SUDOUSER -c "mkdir -p /home/$SUDOUSER/.azure"
runuser -l $SUDOUSER -c "touch /home/$SUDOUSER/.azure/osServicePrincipal.json"
cat > /home/$SUDOUSER/.azure/osServicePrincipal.json <<EOF
{"subscriptionId":"$SUBSCRIPTIONID","clientId":"$AADCLIENTID","clientSecret":"$AADSECRET","tenantId":"$TENANTID"}
EOF
echo $(date) " - Setup Azure Credentials for OCP - Complete"

echo $(date) " - Setup Install config"
runuser -l $SUDOUSER -c "mkdir -p $INSTALLERHOME/openshiftfourx"
runuser -l $SUDOUSER -c "touch $INSTALLERHOME/openshiftfourx/install-config.yaml"
zones=""
if [[ $SINGLEORMULTI == "az" ]]; then
zones="zones:
      - '1'
      - '2'
      - '3'"
fi
cat > $INSTALLERHOME/openshiftfourx/install-config.yaml <<EOF
apiVersion: v1
baseDomain: $BASEDOMAIN
compute:
- hyperthreading: Enabled
  name: worker
  platform: 
    azure:
      type: $WORKERINSTANCETYPE
      osDisk:
        diskSizeGB: 1024
      $zones
  replicas: $WORKERCOUNT
controlPlane:
  hyperthreading: Enabled
  name: master
  platform: 
    azure:
      type: $MASTERINSTANCETYPE
      osDisk:
        diskSizeGB: 1024
      $zones
  replicas: $MASTERCOUNT
metadata:
  creationTimestamp: null
  name: $CLUSTERNAME
networking:
  clusterNetwork:
  - cidr: $CLUSTERNETWORKCIDR
    hostPrefix: $HOSTADDRESSPREFIX
  machineCIDR: $VIRTUALNETWORKCIDR
  networkType: OpenShiftSDN
  serviceNetwork:
  - $SERVICENETWORKCIDR
platform:
  azure:
    baseDomainResourceGroupName: $BASEDOMAINRG
    region: $LOCATION
    networkResourceGroupName: $NETWORKRG
    virtualNetwork: $VIRTUALNETWORKNAME
    controlPlaneSubnet: $MASTERSUBNETNAME
    computeSubnet: $WORKERSUBNETNAME
    outboundType: $OUTBOUNDTYPE
    resourceGroupName: $EXISTING_RESOURCE_GROUP_NAME
pullSecret: '$PULLSECRET'
fips: $FIPS
publish: $PUBLISH
sshKey: |
  $SSHKEY
EOF
echo $(date) " - Setup Install config - Complete"

runuser -l $SUDOUSER -c "cp $INSTALLERHOME/openshiftfourx/install-config.yaml $INSTALLERHOME/openshiftfourx/install-config-backup.yaml"

echo $(date) " - Install OCP"
runuser -l $SUDOUSER -c "export ARM_SKIP_PROVIDER_REGISTRATION=true"
runuser -l $SUDOUSER -c "$INSTALLERHOME/openshift-install create cluster --dir=$INSTALLERHOME/openshiftfourx --log-level=debug"
runuser -l $SUDOUSER -c "sleep 120"
echo $(date) " - OCP Install Complete"

echo $(date) " - Kube Config setup"
runuser -l $SUDOUSER -c "mkdir -p /home/$SUDOUSER/.kube"
runuser -l $SUDOUSER -c "cp $INSTALLERHOME/openshiftfourx/auth/kubeconfig /home/$SUDOUSER/.kube/config"
echo $(date) "Kube Config setup done"

#Switch to Machine API project
runuser -l $SUDOUSER -c "oc project openshift-machine-api"

echo $(date) " - Setting up Cluster Autoscaler"
runuser -l $SUDOUSER -c "cat > $INSTALLERHOME/openshiftfourx/cluster-autoscaler.yaml <<EOF
apiVersion: 'autoscaling.openshift.io/v1'
kind: 'ClusterAutoscaler'
metadata:
  name: 'default'
spec:
  podPriorityThreshold: -10
  resourceLimits:
    maxNodesTotal: 24
    cores:
      min: 48
      max: 128
    memory:
      min: 128
      max: 512
  scaleDown: 
    enabled: true
    delayAfterAdd: '3m'
    delayAfterDelete: '2m'
    delayAfterFailure: '30s'
    unneededTime: '60s'
EOF"

echo $(date) " - Cluster Autoscaler setup complete"

echo $(date) " - Setting up Machine Autoscaler"
clusterid=$(oc get machineset -n openshift-machine-api -o jsonpath='{.items[0].metadata.labels.machine\.openshift\.io/cluster-api-cluster}' --kubeconfig /home/$SUDOUSER/.kube/config)
runuser -l $SUDOUSER -c "cat > $INSTALLERHOME/openshiftfourx/machine-autoscaler.yaml <<EOF
---
kind: MachineAutoscaler
apiVersion: autoscaling.openshift.io/v1beta1
metadata:
  name: ${clusterid}-worker-${LOCATION}1
  namespace: 'openshift-machine-api'
spec:
  minReplicas: 1
  maxReplicas: 12
  scaleTargetRef:
    apiVersion: machine.openshift.io/v1beta1
    kind: MachineSet
    name: ${clusterid}-worker-${LOCATION}1
---
kind: MachineAutoscaler
apiVersion: autoscaling.openshift.io/v1beta1
metadata:
  name: ${clusterid}-worker-${LOCATION}2
  namespace: openshift-machine-api
spec:
  minReplicas: 1
  maxReplicas: 12
  scaleTargetRef:
    apiVersion: machine.openshift.io/v1beta1
    kind: MachineSet
    name: ${clusterid}-worker-${LOCATION}2
---
kind: MachineAutoscaler
apiVersion: autoscaling.openshift.io/v1beta1
metadata:
  name: ${clusterid}-worker-${LOCATION}3
  namespace: openshift-machine-api
spec:
  minReplicas: 1
  maxReplicas: 12
  scaleTargetRef:
    apiVersion: machine.openshift.io/v1beta1
    kind: MachineSet
    name: ${clusterid}-worker-${LOCATION}3
EOF"

echo $(date) " - Machine Autoscaler setup complete"

echo $(date) " - Setting up Machine health checks"
clusterid=$(oc get machineset -n openshift-machine-api -o jsonpath='{.items[0].metadata.labels.machine\.openshift\.io/cluster-api-cluster}' --kubeconfig /home/$SUDOUSER/.kube/config)
runuser -l $SUDOUSER -c "cat > $INSTALLERHOME/openshiftfourx/machine-health-check.yaml <<EOF
---
apiVersion: machine.openshift.io/v1beta1
kind: MachineHealthCheck
metadata:
  name: health-check-worker-${LOCATION}1
  namespace: openshift-machine-api
spec:
  selector:
    matchLabels:
      machine.openshift.io/cluster-api-machine-role: worker
      machine.openshift.io/cluster-api-machine-type: worker
      machine.openshift.io/cluster-api-machineset: ${clusterid}-worker-${LOCATION}1
  unhealthyConditions:
  - type:    \"Ready\"
    timeout: \"300s\"
    status: \"False\"
  - type:    \"Ready\"
    timeout: \"300s\"
    status: \"Unknown\"
  maxUnhealthy: \"30%\"
---
apiVersion: machine.openshift.io/v1beta1
kind: MachineHealthCheck
metadata:
  name: health-check-worker-${LOCATION}2 
  namespace: openshift-machine-api
spec:
  selector:
    matchLabels:
      machine.openshift.io/cluster-api-machine-role: worker
      machine.openshift.io/cluster-api-machine-type: worker
      machine.openshift.io/cluster-api-machineset: ${clusterid}-worker-${LOCATION}2
  unhealthyConditions:
  - type:    \"Ready\"
    timeout: \"300s\"
    status: \"False\"
  - type:    \"Ready\"
    timeout: \"300s\"
    status: \"Unknown\"
  maxUnhealthy: \"30%\"
---
apiVersion: machine.openshift.io/v1beta1
kind: MachineHealthCheck
metadata:
  name: health-check-worker-${LOCATION}3 
  namespace: openshift-machine-api
spec:
  selector:
    matchLabels:
      machine.openshift.io/cluster-api-machine-role: worker
      machine.openshift.io/cluster-api-machine-type: worker
      machine.openshift.io/cluster-api-machineset: ${clusterid}-worker-${LOCATION}3
  unhealthyConditions:
  - type:    \"Ready\"
    timeout: \"300s\"
    status: \"False\"
  - type:    \"Ready\"
    timeout: \"300s\"
    status: \"Unknown\"
  maxUnhealthy: \"30%\"
EOF"

##Enable/Disable Autoscaler
if [[ $ENABLEAUTOSCALER == "true" || $ENABLEAUTOSCALER == "True" ]]; then
  runuser -l $SUDOUSER -c "oc create -f $INSTALLERHOME/openshiftfourx/cluster-autoscaler.yaml"
  runuser -l $SUDOUSER -c "oc create -f $INSTALLERHOME/openshiftfourx/machine-autoscaler.yaml"
  runuser -l $SUDOUSER -c "oc create -f $INSTALLERHOME/openshiftfourx/machine-health-check.yaml"
fi

echo $(date) " - Machine Health Check setup complete"

echo $(date) " - Setting up $STORAGEOPTION"
if [[ $STORAGEOPTION == "portworx" ]]; then
  runuser -l $SUDOUSER -c "wget $ARTIFACTSLOCATION/scripts/px-install.yaml$ARTIFACTSTOKEN -O $INSTALLERHOME/openshiftfourx/px-install.yaml"
  runuser -l $SUDOUSER -c "wget $ARTIFACTSLOCATION/scripts/px-storageclasses.yaml$ARTIFACTSTOKEN -O $INSTALLERHOME/openshiftfourx/px-storageclasses.yaml"
  runuser -l $SUDOUSER -c "oc create -f $INSTALLERHOME/openshiftfourx/px-install.yaml"
  runuser -l $SUDOUSER -c "sleep 30"
  runuser -l $SUDOUSER -c "oc apply -f '$PXSPECURL'"
  runuser -l $SUDOUSER -c "oc create -f $INSTALLERHOME/openshiftfourx/px-storageclasses.yaml"
fi

if [[ $STORAGEOPTION == "nfs" ]]; then
  runuser -l $SUDOUSER -c "oc adm policy add-scc-to-user hostmount-anyuid system:serviceaccount:kube-system:nfs-client-provisioner"
  runuser -l $SUDOUSER -c "wget $ARTIFACTSLOCATION/scripts/nfs-template.yaml$ARTIFACTSTOKEN -O  $INSTALLERHOME/openshiftfourx/nfs-template.yaml"
  runuser -l $SUDOUSER -c "oc process -f $INSTALLERHOME/openshiftfourx/nfs-template.yaml -p NFS_SERVER=$NFSIPADDRESS -p NFS_PATH=/exports/home | oc create -n kube-system -f -"
fi
echo $(date) " - Setting up $STORAGEOPTION - Done"

echo $(date) " - Creating $OPENSHIFTUSER user"
runuser -l $SUDOUSER -c "htpasswd -c -B -b /tmp/.htpasswd '$OPENSHIFTUSER' '$OPENSHIFTPASSWORD'"
runuser -l $SUDOUSER -c "sleep 3"
runuser -l $SUDOUSER -c "oc create secret generic htpass-secret --from-file=htpasswd=/tmp/.htpasswd -n openshift-config"
runuser -l $SUDOUSER -c "cat >  $INSTALLERHOME/openshiftfourx/auth.yaml <<EOF
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  tokenConfig:
    accessTokenMaxAgeSeconds: 172800
  identityProviders:
  - name: htpasswdProvider 
    challenge: true 
    login: true 
    mappingMethod: claim 
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpass-secret
EOF"
runuser -l $SUDOUSER -c "oc apply -f $INSTALLERHOME/openshiftfourx/auth.yaml"
runuser -l $SUDOUSER -c "oc adm policy add-cluster-role-to-user cluster-admin '$OPENSHIFTUSER'"

echo $(date) " - ############## Script Complete ####################"