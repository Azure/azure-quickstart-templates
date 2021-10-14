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

# CCS subscription and CR creation 

runuser -l $SUDOUSER -c "cat > $CPDTEMPLATES/ibm-ccs-sub.yaml <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  annotations: {}
  name: ibm-cpd-ccs-operator
  namespace: $OPERATORNAMESPACE
spec:
  channel: $CHANNEL
  config:
    resources: {}
  installPlanApproval: Automatic
  name: ibm-cpd-ccs
  source: ibm-operator-catalog
  sourceNamespace: openshift-marketplace
EOF"

runuser -l $SUDOUSER -c "cat > $CPDTEMPLATES/ibm-ccs-cr.yaml <<EOF
apiVersion: ccs.cpd.ibm.com/v1beta1
kind: CCS
metadata:
  name: ccs-cr
  namespace: $CPDNAMESPACE
spec:
  size: \"small\"
  REPLACE_VENDOR_OR_CLASS: REPLACE_SC
  license:
    accept: true
    license: Enterprise
  docker_registry_prefix: \"cp.icr.io/cp/cpd\"
EOF"


## Creating Subscription 

runuser -l $SUDOUSER -c "oc create -f $CPDTEMPLATES/ibm-ccs-sub.yaml"
runuser -l $SUDOUSER -c "echo 'Sleeping for 5m' "
runuser -l $SUDOUSER -c "sleep 5m"

# Check ibm-cpd-ccs-operator pod status

podname="ibm-cpd-ccs-operator"
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

## Creating ibm-ccs cr
if [[ $STORAGEOPTION == "nfs" ]];then 
runuser -l $SUDOUSER -c "sed -i -e s#REPLACE_VENDOR_OR_CLASS#storageClass#g $CPDTEMPLATES/ibm-ccs-cr.yaml"
runuser -l $SUDOUSER -c "sed -i -e s#REPLACE_SC#nfs#g $CPDTEMPLATES/ibm-ccs-cr.yaml"
elif [[ $STORAGEOPTION == "ocs" || $STORAGEOPTION == "portworx" ]];then 
runuser -l $SUDOUSER -c "sed -i -e s#REPLACE_VENDOR_OR_CLASS#storageVendor#g $CPDTEMPLATES/ibm-ccs-cr.yaml"
runuser -l $SUDOUSER -c "sed -i -e s#REPLACE_SC#$STORAGEVENDOR_VALUE#g $CPDTEMPLATES/ibm-ccs-cr.yaml"
fi


runuser -l $SUDOUSER -c "oc project $CPDNAMESPACE; oc create -f $CPDTEMPLATES/ibm-ccs-cr.yaml"

# Check CR Status

SERVICE="CCS"
CRNAME="ccs-cr"
SERVICE_STATUS="ccsStatus"

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