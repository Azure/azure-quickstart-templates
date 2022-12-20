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

runuser -l $SUDOUSER -c "oc login \"https://api.${CLUSTERNAME}.${DOMAINNAME}:6443\" -u $OPENSHIFTUSER -p $OPENSHIFTPASSWORD --insecure-skip-tls-verify=true"

#Login
var=1
while [ $var -ne 0 ]; do
echo "Attempting to login $OPENSHIFTUSER to https://api.${CLUSTERNAME}.${DOMAINNAME}:6443 "
oc login "https://api.${CLUSTERNAME}.${DOMAINNAME}:6443" -u $OPENSHIFTUSER -p $OPENSHIFTPASSWORD --insecure-skip-tls-verify=true
var=$?
echo "exit code: $var"
done

# DV operator and CR creation 

runuser -l $SUDOUSER -c "cat > $CPDTEMPLATES/ibm-dv-sub.yaml <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ibm-dv-operator-catalog-subscription
  namespace: $OPERATORNAMESPACE        # Pick the project that contains the Cloud Pak for Data operator
spec:
  channel: $CHANNEL
  installPlanApproval: Automatic
  name: ibm-dv-operator
  source: ibm-operator-catalog
  sourceNamespace: openshift-marketplace
EOF"

runuser -l $SUDOUSER -c "oc project $OPERATORNAMESPACE; oc create -f $CPDTEMPLATES/ibm-dv-sub.yaml"

runuser -l $SUDOUSER -c "echo 'Sleeping 2m for DV Subscription to install'"
runuser -l $SUDOUSER -c "sleep 2m"

runuser -l $SUDOUSER -c "echo 'Sleeping 2m for operator to install'"
runuser -l $SUDOUSER -c "sleep 2m"

# Check ibm-dv-operator pod status

podname="ibm-dv-operator"
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

## Creating ibm-DV cr

runuser -l $SUDOUSER -c "cat > $CPDTEMPLATES/ibm-dv-cr.yaml <<EOF
apiVersion: db2u.databases.ibm.com/v1
kind: DvService
metadata:
  name: dv-service-cr
  namespace: $CPDNAMESPACE
spec:
  license:
    accept: true
    license: Enterprise
  version: $VERSION
  size: "small"
  docker_registry_prefix: cp.icr.io/cp/cpd
EOF"

runuser -l $SUDOUSER -c "oc project $OPERATORNAMESPACE; oc create -f $CPDTEMPLATES/ibm-dv-cr.yaml"
runuser -l $SUDOUSER -c "echo 'Sleeping 2m for DV CR to be created'"
runuser -l $SUDOUSER -c "sleep 2m"


# Check CR Status

SERVICE="DvService"
CRNAME="dv-service-cr"
SERVICE_STATUS="reconcileStatus"

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