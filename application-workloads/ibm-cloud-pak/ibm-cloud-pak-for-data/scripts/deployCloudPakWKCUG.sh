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

# UG CR creation 

runuser -l $SUDOUSER -c "cat > $CPDTEMPLATES/ibm-ug-ocs-pwx-cr.yaml <<EOF
apiVersion: wkc.cpd.ibm.com/v1beta1
kind: UG
metadata:
  name: ug-cr
  namespace: $CPDNAMESPACE
spec:
  version: \"$VERSION\"
  size: \"small\"
  storageVendor: \"$STORAGEVENDOR_VALUE\"
  license:
    accept: true
    license: \"Enterprise\"
  docker_registry_prefix: cp.icr.io/cp/cpd
EOF"

runuser -l $SUDOUSER -c "cat > $CPDTEMPLATES/ibm-ug-nfs-cr.yaml <<EOF
apiVersion: wkc.cpd.ibm.com/v1beta1
kind: UG
metadata:
  name: ug-cr
  namespace: $CPDNAMESPACE
spec:
  version: \"$VERSION\"
  size: \"small\"
  storageClass: \"$STORAGECLASS_VALUE\"
  license:
    accept: true
    license: \"Enterprise\"
  docker_registry_prefix: cp.icr.io/cp/cpd
EOF"


## Creating ibm-ug cr

if [[ $STORAGEOPTION == "nfs" ]];then 

    runuser -l $SUDOUSER -c "oc project $CPDNAMESPACE; oc create -f $CPDTEMPLATES/ibm-ug-nfs-cr.yaml"

elif [[ $STORAGEOPTION == "ocs" || $STORAGEOPTION == "portworx" ]];then 

    runuser -l $SUDOUSER -c "oc project $CPDNAMESPACE; oc create -f $CPDTEMPLATES/ibm-ug-ocs-pwx-cr.yaml"
fi

# Check CR Status

SERVICE="UG"
CRNAME="ug-cr"
SERVICE_STATUS="ugStatus"

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