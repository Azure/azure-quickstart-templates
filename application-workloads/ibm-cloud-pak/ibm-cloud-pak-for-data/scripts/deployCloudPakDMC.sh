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

#Login
var=1
while [ $var -ne 0 ]; do
echo "Attempting to login $OPENSHIFTUSER to https://api.${CLUSTERNAME}.${DOMAINNAME}:6443 "
oc login "https://api.${CLUSTERNAME}.${DOMAINNAME}:6443" -u $OPENSHIFTUSER -p $OPENSHIFTPASSWORD --insecure-skip-tls-verify=true
var=$?
echo "exit code: $var"
done


# dmc operator and CR creation 

runuser -l $SUDOUSER -c "cat > $CPDTEMPLATES/ibm-dmc-catalogsource.yaml <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: ibm-cloud-databases-redis-operator-catalog
  namespace: openshift-marketplace
spec:
  displayName: ibm-cloud-databases-redis-operator-catalog
  publisher: IBM
  sourceType: grpc
  image: icr.io/cpopen/ibm-cloud-databases-redis-catalog@sha256:980e4182ec20a01a93f3c18310e0aa5346dc299c551bd8aca070ddf2a5bf9ca5
  updateStrategy:
    registryPoll:
      interval: 45m
---
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: ibm-dmc-operator-catalog
  namespace: openshift-marketplace
spec:
  displayName: ibm-dmc-operator-catalog
  publisher: IBM
  sourceType: grpc
  image: icr.io/cpopen/ibm-dmc-operator-catalog@sha256:a3a395ffec07b3f426718aed54ec164badfd55a7445c29f317da242409ae5d00
  updateStrategy:
    registryPoll:
      interval: 45m
EOF"

# Download dmc case package. 
runuser -l $SUDOUSER -c "wget https://raw.githubusercontent.com/IBM/cloud-pak/master/repo/case/ibm-dmc-4.0.0.tgz -P $CPDTEMPLATES -A 'ibm-dmc-4.0.0.tgz'"

runuser -l $SUDOUSER -c "oc create -f $CPDTEMPLATES/ibm-dmc-catalogsource.yaml"
runuser -l $SUDOUSER -c "echo 'Sleeping 2m for catalogsource to be created'"
runuser -l $SUDOUSER -c "sleep 2m"

runuser -l $SUDOUSER -c "cloudctl case launch  \
    --case $CPDTEMPLATES/ibm-dmc-4.0.0.tgz     \
    --namespace $OPERATORNAMESPACE             \
    --inventory dmcOperatorSetup               \
    --action installOperator                   \
    --tolerance=1"

runuser -l $SUDOUSER -c "echo 'Sleeping 2m for operator to install'"
runuser -l $SUDOUSER -c "sleep 2m"

runuser -l $SUDOUSER -c "cat > $CPDTEMPLATES/ibm-dmc-cr.yaml <<EOF
apiVersion: dmc.databases.ibm.com/v1
kind: Dmcaddon
metadata:
  name: dmcaddon-cr
  namespace: $CPDNAMESPACE
spec:
  namespace: $CPDNAMESPACE
  storageClass: $STORAGECLASS_VALUE
  pullPrefix: cp.icr.io/cp/cpd
  version: \"4.0.0\"
  license:
    accept: true
    license: Standard 
EOF"

# Check ibm-cpd-ae-operator pod status

podname="ibm-dmc-controller-manager"
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

## Creating ibm-dmc cr

runuser -l $SUDOUSER -c "oc project $CPDNAMESPACE; oc create -f $CPDTEMPLATES/ibm-dmc-cr.yaml"

# Check CR Status

SERVICE="dmcaddon"
CRNAME="dmcaddon-cr"
SERVICE_STATUS="dmcAddonStatus"

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