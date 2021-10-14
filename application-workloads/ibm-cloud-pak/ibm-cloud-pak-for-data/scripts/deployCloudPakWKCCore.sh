#!/bin/sh

export SUDOUSER=$1
export OPENSHIFTPASSWORD=$2
export CPDNAMESPACE=$3
export STORAGEOPTION=$4
export ASSEMBLY=$5
export CLUSTERNAME=$6
export DOMAINNAME=$7
export OPENSHIFTUSER=$8
export APIKEY=$9
export CHANNEL=${10}
export VERSION=${11}

export INSTALLERHOME=/home/$SUDOUSER/.ibm
export OPERATORNAMESPACE=ibm-common-services
export INSTALLERHOME=/home/$SUDOUSER/.ibm
export OCPTEMPLATES=/home/$SUDOUSER/.openshift/templates
export CPDTEMPLATES=/home/$SUDOUSER/.cpd/templates

# Set parameters
if [[ $STORAGEOPTION == "portworx" ]]; then
    STORAGECLASS_VALUE="portworx-shared-gp3"
    STORAGEVENDOR_VALUE="portworx"
elif [[ $STORAGEOPTION == "ocs" ]]; then
    STORAGECLASS_VALUE="ocs-storagecluster-cephfs"
    STORAGEVENDOR_VALUE="ocs"
elif [[ $STORAGEOPTION == "nfs" ]]; then
    STORAGECLASS_VALUE="nfs"
    STORAGEVENDOR_VALUE=""
fi

#Login
var=1
while [ $var -ne 0 ]; do
echo "Attempting to login $OPENSHIFTUSER to https://api.${CLUSTERNAME}.${DOMAINNAME}:6443 "
oc login "https://api.${CLUSTERNAME}.${DOMAINNAME}:6443" -u $OPENSHIFTUSER -p $OPENSHIFTPASSWORD --insecure-skip-tls-verify=true
var=$?
echo "exit code: $var"
done

## Creating IIS SC yaml 

runuser -l $SUDOUSER -c "cat > $CPDTEMPLATES/ibm-wkc-iis-scc.yaml <<EOF
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
allowedCapabilities: null
apiVersion: security.openshift.io/v1
defaultAddCapabilities: null
fsGroup:
  type: RunAsAny
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: WKC/IIS provides all features of the restricted SCC
      but runs as user 10032.
  name: wkc-iis-scc
readOnlyRootFilesystem: false
requiredDropCapabilities:
- KILL
- MKNOD
- SETUID
- SETGID
runAsUser:
  type: MustRunAs
  uid: 10032
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
users:
- system:serviceaccount:$CPDNAMESPACE:wkc-iis-sa
EOF"

runuser -l $SUDOUSER -c "oc create -f $CPDTEMPLATES/ibm-wkc-iis-scc.yaml"
runuser -l $SUDOUSER -c "echo 'Sleeping for 1m' "
runuser -l $SUDOUSER -c "sleep 1m"

# WKC subscription and CR creation 

runuser -l $SUDOUSER -c "cat > $CPDTEMPLATES/ibm-wkc-sub.yaml <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  labels:
    app.kubernetes.io/instance:  ibm-cpd-wkc-operator
    app.kubernetes.io/managed-by: ibm-cpd-wkc-operator
    app.kubernetes.io/name:  ibm-cpd-wkc-operator
  name: ibm-cpd-wkc-operator
  namespace: ibm-common-services
spec:
  channel: $CHANNEL
  installPlanApproval: Automatic
  name: ibm-cpd-wkc
  source: ibm-operator-catalog
  sourceNamespace: openshift-marketplace
EOF"


runuser -l $SUDOUSER -c "cat > $CPDTEMPLATES/ibm-wkc-ocs-pwx-cr.yaml <<EOF
apiVersion: wkc.cpd.ibm.com/v1beta1
kind: WKC
metadata:
  name: wkc-cr
  namespace: $CPDNAMESPACE
spec:
  version: \"$VERSION\"
  storageVendor: \"$STORAGEVENDOR_VALUE\"
  license:
    accept: true
    license: Enterprise
  docker_registry_prefix: cp.icr.io/cp/cpd
  useODLM: true
  install_wkc_core_only: true
EOF"

runuser -l $SUDOUSER -c "cat > $CPDTEMPLATES/ibm-wkc-nfs-cr.yaml <<EOF
apiVersion: wkc.cpd.ibm.com/v1beta1
kind: WKC
metadata:
  name: wkc-cr
  namespace: $CPDNAMESPACE
spec:
  version: \"$VERSION\"
  storageClass: \"$STORAGECLASS_VALUE\"
  license:
    accept: true
    license: Enterprise
  docker_registry_prefix: cp.icr.io/cp/cpd
  useODLM: true
  install_wkc_core_only: true
EOF"

## Creating Subscription 

runuser -l $SUDOUSER -c "oc create -f $CPDTEMPLATES/ibm-wkc-sub.yaml"
runuser -l $SUDOUSER -c "echo 'Sleeping for 5m' "
runuser -l $SUDOUSER -c "sleep 5m"

# Check ibm-cpd-wkc-operator pod status

podname="ibm-cpd-wkc-operator"
name_space=$OPERATORNAMESPACE
status="unknown"
while [ "$status" != "Running" ]
do
  pod_name=$(oc get pods -n $name_space | grep $podname | awk '{print $1}' )
  ready_status=$(oc get pods -n $name_space $pod_name  --no-headers | awk '{print $2}')
  pod_status=$(oc get pods -n $name_space $pod_name --no-headers | awk '{print $3}')
  echo $pod_name State - $ready_status, podstatus - $pod_status
  if [ "$ready_status" == "1/1" ] && [ "$pod_status" == "Running" ]
  then 
  status="Running"
  else
  status="starting"
  sleep 10 
  fi
  echo "$pod_name is $status"
done

## Creating ibm-wkc cr

if [[ $STORAGEOPTION == "nfs" ]];then 

    runuser -l $SUDOUSER -c "oc project $CPDNAMESPACE; oc create -f $CPDTEMPLATES/ibm-wkc-nfs-cr.yaml"

elif [[ $STORAGEOPTION == "ocs" || $STORAGEOPTION == "portworx" ]];then 

    runuser -l $SUDOUSER -c "oc project $CPDNAMESPACE; oc create -f $CPDTEMPLATES/ibm-wkc-ocs-pwx-cr.yaml"
fi

# Check CR Status

SERVICE="WKC"
CRNAME="wkc-cr"
SERVICE_STATUS="wkcStatus"

STATUS=$(oc get $SERVICE $CRNAME -n $CPDNAMESPACE -o json | jq .status.$SERVICE_STATUS | xargs) 

while  [[ ! $STATUS =~ ^(Completed|Complete)$ ]]; do
    echo "$CRNAME is Installing!!!!"
    sleep 60 
    STATUS=$(oc get $SERVICE $CRNAME -n $CPDNAMESPACE -o json | jq .status.$SERVICE_STATUS | xargs) 
    if [ "$STATUS" == "Failed" ]
    then
        echo "**********************************"
        echo "$CRNAME Installation Failed!!!!"
        echo "**********************************"
        exit
    fi
done 
echo "*************************************"
echo "$CRNAME Installation Finished!!!!"
echo "*************************************"

echo "$(date) - ############### Script Complete #############"