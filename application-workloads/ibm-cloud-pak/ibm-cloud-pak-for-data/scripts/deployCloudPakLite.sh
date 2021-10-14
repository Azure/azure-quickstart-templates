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

runuser -l $SUDOUSER -c "mkdir -p $INSTALLERHOME"
runuser -l $SUDOUSER -c "mkdir -p $OCPTEMPLATES"
runuser -l $SUDOUSER -c "mkdir -p $CPDTEMPLATES"
runuser -l $SUDOUSER -c "cat > $OCPTEMPLATES/kubecredentials <<EOF
username: $OPENSHIFTUSER
password: $OPENSHIFTPASSWORD
EOF"

# Set parameters
if [[ $STORAGEOPTION == "portworx" ]]; then
    STORAGECLASS_VALUE="portworx-shared-gp3"
elif [[ $STORAGEOPTION == "ocs" ]]; then
    STORAGECLASS_VALUE="ocs-storagecluster-cephfs"
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


#CPD Config

#runuser -l $SUDOUSER -c "wget https://github.com/IBM/cloud-pak-cli/releases/download/v3.8.0/cloudctl-linux-amd64.tar.gz -O $CPDTEMPLATES/cloudctl-linux-amd64.tar.gz"
#runuser -l $SUDOUSER -c "https://github.com/IBM/cloud-pak-cli/releases/download/v3.8.0/cloudctl-linux-amd64.tar.gz.sig -O $CPDTEMPLATES/cloudctl-linux-amd64.tar.gz.sig"
#runuser -l $SUDOUSER -c "cd $CPDTEMPLATES && sudo tar -xvf cloudctl-linux-amd64.tar.gz -C /usr/local/bin"
#runuser -l $SUDOUSER -c "chmod +x /usr/local/bin/cloudctl-linux-amd64"
#runuser -l $SUDOUSER -c "sudo mv /usr/local/bin/cloudctl-linux-amd64 /usr/local/bin/cloudctl"

# Service Account Token for CPD installation
runuser -l $SUDOUSER -c "oc new-project $CPDNAMESPACE"
runuser -l $SUDOUSER -c "oc create serviceaccount cpdtoken"
runuser -l $SUDOUSER -c "oc policy add-role-to-user admin system:serviceaccount:$CPDNAMESPACE:cpdtoken"

# Service Account Token for CPD installation
runuser -l $SUDOUSER -c "oc new-project $OPERATORNAMESPACE"
runuser -l $SUDOUSER -c "oc create serviceaccount cpdtoken"
runuser -l $SUDOUSER -c "oc policy add-role-to-user admin system:serviceaccount:$OPERATORNAMESPACE:cpdtoken"

## Installing jq
runuser -l $SUDOUSER -c "wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -O  $CPDTEMPLATES/jq"
runuser -l $SUDOUSER -c "sudo mv $CPDTEMPLATES/jq /usr/local/bin"
runuser -l $SUDOUSER -c "sudo chmod +x /usr/local/bin/jq"


# Update global pull secret and sysctl changes: 

runuser -l $SUDOUSER -c "cat > $CPDTEMPLATES/sysctl-worker.yaml <<EOF
apiVersion: machineconfiguration.openshift.io/v1
kind: KubeletConfig
metadata:
  name: db2u-kubelet
spec:
  machineConfigPoolSelector:
    matchLabels:
      db2u-kubelet: sysctl
  kubeletConfig:
    systemReserved:
      cpu: 1000m
      memory: 1Gi
    allowedUnsafeSysctls:
      - \"kernel.msg*\"
      - \"kernel.shm*\"
      - \"kernel.sem\"
EOF"


export ENTITLEMENT_USER=cp
export ENTITLEMENT_KEY=$APIKEY
pull_secret=$(echo -n "$ENTITLEMENT_USER:$ENTITLEMENT_KEY" | base64 -w0)
oc get secret/pull-secret -n openshift-config -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d > $OCPTEMPLATES/dockerconfig.json
sed -i -e 's|:{|:{"cp.icr.io":{"auth":"'$pull_secret'"\},|' $OCPTEMPLATES/dockerconfig.json
oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=$OCPTEMPLATES/dockerconfig.json

runuser -l $SUDOUSER -c "oc label machineconfigpool.machineconfiguration.openshift.io worker db2u-kubelet=sysctl"
runuser -l $SUDOUSER -c "oc create -f $CPDTEMPLATES/sysctl-worker.yaml"
runuser -l $SUDOUSER -c "sleep 3m"

# Check nodestatus if they are ready.

while true; do
    node_status=$(oc get nodes | grep -E "SchedulingDisabled|NotReady")
    if [[ -z $node_status ]]; then
        echo -e "\n******All nodes are running now.******"
        break
    fi
        echo -e "\n******Waiting for nodes to get ready.******"
        oc get nodes --no-headers | awk '{print $1 " " $2}'
        echo -e "\n******sleeping for 60Secs******"
        sleep 60
    done

# CPD Bedrock and Platform operator install: 

runuser -l $SUDOUSER -c "cat > $CPDTEMPLATES/ibm-operator-catalogsource.yaml <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: ibm-operator-catalog
  namespace: openshift-marketplace
spec:
  displayName: \"IBM Operator Catalog\" 
  publisher: IBM
  sourceType: grpc
  image: icr.io/cpopen/ibm-operator-catalog:latest
  updateStrategy:
    registryPoll:
      interval: 45m
EOF"

runuser -l $SUDOUSER -c "cat > $CPDTEMPLATES/db2u-catalogsource.yaml <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: ibm-db2uoperator-catalog
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: docker.io/ibmcom/ibm-db2uoperator-catalog:latest
  imagePullPolicy: Always
  displayName: IBM Db2U Catalog
  publisher: IBM
  updateStrategy:
    registryPoll:
      interval: 45m
EOF"

runuser -l $SUDOUSER -c "cat > $CPDTEMPLATES/ibm-operator-og.yaml <<EOF
apiVersion: operators.coreos.com/v1alpha2
kind: OperatorGroup
metadata:
  name: operatorgroup
  namespace: ibm-common-services
spec:
  targetNamespaces:
  - ibm-common-services
EOF"

runuser -l $SUDOUSER -c "cat > $CPDTEMPLATES/cpd-platform-operator-sub.yaml <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: cpd-operator
  namespace: ibm-common-services    # The project that contains the Cloud Pak for Data operator
spec:
  channel: $CHANNEL
  installPlanApproval: Automatic
  name: cpd-platform-operator
  source: ibm-operator-catalog
  sourceNamespace: openshift-marketplace
EOF"

runuser -l $SUDOUSER -c "cat > $CPDTEMPLATES/cpd-platform-operator-operandrequest.yaml <<EOF
apiVersion: operator.ibm.com/v1alpha1
kind: OperandRequest
metadata:
  name: empty-request
  namespace: $CPDNAMESPACE        # Replace with the project where you will install Cloud Pak for Data
spec:
  requests: []
EOF"


# Run catalog source 

runuser -l $SUDOUSER -c "oc create -f $CPDTEMPLATES/ibm-operator-catalogsource.yaml"
runuser -l $SUDOUSER -c "echo 'Sleeping for 1m' "
runuser -l $SUDOUSER -c "sleep 1m"

# Create DB2U Operator catalog source

runuser -l $SUDOUSER -c "oc create -f $CPDTEMPLATES/db2u-catalogsource.yaml"
runuser -l $SUDOUSER -c "echo 'Sleeping for 2m' "
runuser -l $SUDOUSER -c "sleep 2m"

# Check ibm-operator-catalog pod status

podname="ibm-operator-catalog"
name_space="openshift-marketplace"
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

# Create IBM Operator Group

runuser -l $SUDOUSER -c "oc create -f $CPDTEMPLATES/ibm-operator-og.yaml"

# Creating CPD Platform operator subscription: 

runuser -l $SUDOUSER -c "oc create -f $CPDTEMPLATES/cpd-platform-operator-sub.yaml"
runuser -l $SUDOUSER -c "echo 'Sleeping for ' "
runuser -l $SUDOUSER -c "sleep 2m"

# Check cpd-platform-operator-manager pod status

podname="cpd-platform-operator-manager"
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

# Check ibm-namespace-scope-operator pod status

podname="ibm-namespace-scope-operator"
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

# Check ibm-common-service-operator pod status

podname="ibm-common-service-operator"
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


# Check operand-deployment-lifecycle-manager pod status

podname="operand-deployment-lifecycle-manager"
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

runuser -l $SUDOUSER -c "oc create -f $CPDTEMPLATES/cpd-platform-operator-operandrequest.yaml"
runuser -l $SUDOUSER -c "echo 'Sleeping for 2m' "
runuser -l $SUDOUSER -c "sleep 2m"

# Install Lite-cr 
runuser -l $SUDOUSER -c "cat > $CPDTEMPLATES/ibmcpd-cr.yaml <<EOF
apiVersion: cpd.ibm.com/v1
kind: Ibmcpd
metadata:
  name: ibmcpd-cr                                         # This is the recommended name, but you can change it
  namespace: REPLACE_NAMESPACE                            # Replace with the project where you will install Cloud Pak for Data
spec:
  license:
    accept: true
    license: Enterprise                                   # Specify the Cloud Pak for Data license you purchased
  storageClass: \"REPLACE_STORAGECLASS\"                    # Replace with the name of a RWX storage class
  zenCoreMetadbStorageClass: \"REPLACE_STORAGECLASS\"       # (Recommended) Replace with the name of a RWO storage class
  version: \"$VERSION\"
EOF"

runuser -l $SUDOUSER -c "sed -i -e s#REPLACE_STORAGECLASS#$STORAGECLASS_VALUE#g $CPDTEMPLATES/ibmcpd-cr.yaml"
runuser -l $SUDOUSER -c "sed -i -e s#REPLACE_NAMESPACE#$CPDNAMESPACE#g $CPDTEMPLATES/ibmcpd-cr.yaml"
runuser -l $SUDOUSER -c "oc project $CPDNAMESPACE; oc create -f $CPDTEMPLATES/ibmcpd-cr.yaml"

# Check CR Status

SERVICE="ibmcpd"
CRNAME="ibmcpd-cr"
SERVICE_STATUS="controlPlaneStatus"

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

# Enable CSV injector patch
# Can be removed later if this is no longer required. 
oc patch namespacescope common-service --type='json' -p='[{"op":"replace", "path": "/spec/csvInjector/enable", "value":true}]' -n $OPERATORNAMESPACE


echo "$(date) - ############### Script Complete #############"