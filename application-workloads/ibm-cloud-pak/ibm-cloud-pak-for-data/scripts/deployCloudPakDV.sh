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

# Download DV case package. 

runuser -l $SUDOUSER -c "wget https://raw.githubusercontent.com/IBM/cloud-pak/master/repo/case/ibm-dv-case/1.7.0/ibm-dv-case-1.7.0.tgz -P $CPDTEMPLATES -A 'ibm-dv-case-1.7.0.tgz'"

runuser -l $SUDOUSER -c "cloudctl case launch      \
    --case $CPDTEMPLATES/ibm-dv-case-1.7.0.tgz     \
    --namespace openshift-marketplace              \
    --inventory dv                                 \
    --action installCatalog                        \
    --tolerance=1"

runuser -l $SUDOUSER -c "cloudctl case launch      \
    --case $CPDTEMPLATES/ibm-dv-case-1.7.0.tgz     \
    --namespace $OPERATORNAMESPACE                 \
    --inventory dv                                 \
    --action installOperator                       \
    --tolerance=1"

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

runuser -l $SUDOUSER -c "cloudctl case launch      \
    --case $CPDTEMPLATES/ibm-dv-case-1.7.0.tgz     \
    --namespace $CPDNAMESPACE                      \
    --inventory dv                                 \
    --action applyCustomResources                  \
    --tolerance=1"


# Check CR Status

SERVICE="dvservice"
CRNAME="dv-service"
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