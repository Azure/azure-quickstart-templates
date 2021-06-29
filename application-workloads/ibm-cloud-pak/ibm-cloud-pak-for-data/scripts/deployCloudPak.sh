export SUDOUSER=$1
export OPENSHIFTPASSWORD=$2
export NAMESPACE=$3
export STORAGEOPTION=$4
export ASSEMBLY=$5
export CLUSTERNAME=$6
export DOMAINNAME=$7
export OPENSHIFTUSER=$8
export INSTALLERHOME=/home/$SUDOUSER/.ibm

#Add timestamp to script init
echo $(date) " - Attempting ${ASSEMBLY} install"

# Set parameters
storageclass="nfs"
override=""
if [[ $STORAGEOPTION == "portworx" ]]; then
    storageclass="portworx-shared-gp3"
    override="portworx"
elif [[ $STORAGEOPTION == "ocs" ]]; then
    storageclass="ocs-storagecluster-cephfs"
fi

#Login
var=1
while [ $var -ne 0 ]; do
echo "Attempting to login $OPENSHIFTUSER to https://api.${CLUSTERNAME}.${DOMAINNAME}:6443 "
oc login "https://api.${CLUSTERNAME}.${DOMAINNAME}:6443" -u $OPENSHIFTUSER -p $OPENSHIFTPASSWORD --insecure-skip-tls-verify=true
var=$?
echo "exit code: $var"
done

runuser -l $SUDOUSER -c "oc project $NAMESPACE"
runuser -l $SUDOUSER -c "cat > $INSTALLERHOME/$ASSEMBLY-service.yaml <<EOF
apiVersion: metaoperator.cpd.ibm.com/v1
kind: CPDService
metadata:
  name: $ASSEMBLY-cpdservice
  labels:
    app.kubernetes.io/instance: ibm-cp-data-operator-$ASSEMBLY-cpdservice
    app.kubernetes.io/managed-by: ibm-cp-data-operator
    app.kubernetes.io/name: ibm-cp-data-operator-$ASSEMBLY-cpdservice
spec:
  serviceName: $ASSEMBLY
  version: \"latest\"
  storageClass: $storageclass
  overrideConfig: \"${override}\"
  flags: \"\"
  autoPatch: false
  scale: \"\"
  optionalModules: []
  license: 
    accept: true
EOF"

runuser -l $SUDOUSER -c "oc create -f $INSTALLERHOME/$ASSEMBLY-service.yaml"

SERVICE=$ASSEMBLY
STATUS="Installing"

while [ "$STATUS" != "Ready" ];do
    echo "$SERVICE Installing!!!!"
    sleep 60 
    STATUS=$(oc get cpdservice $SERVICE-cpdservice -n $NAMESPACE --kubeconfig /home/$SUDOUSER/.kube/config --output="jsonpath={.status.status}" | xargs) 
    if [ "$STATUS" == "Failed" ]
    then
        echo "**********************************"
        echo "$SERVICE Installation Failed!!!!"
        echo "**********************************"
        exit 1
    fi
done 
echo "*************************************"
echo "$SERVICE Installation Finished!!!!"
echo "*************************************"
#==============================================================