export SUDOUSER=$1
export OPENSHIFTPASSWORD=$2
export NAMESPACE=$3
export STORAGEOPTION=$4
export ASSEMBLY=$5
export CLUSTERNAME=$6
export DOMAINNAME=$7
export OPENSHIFTUSER=$8
export INSTALLERHOME=/home/$SUDOUSER/.ibm

# Set parameters
storageclass="nfs"
override=""
if [[ $STORAGEOPTION == "portworx" ]]; then
    storageclass="portworx-shared-gp"
    override="--override $INSTALLERHOME/portworx-override.yaml"
fi

# Install
var=1
while [ $var -ne 0 ]; do
echo "Attempting to login $OPENSHIFTUSER to https://api.${CLUSTERNAME}.${DOMAINNAME}:6443 "
oc login "https://api.${CLUSTERNAME}.${DOMAINNAME}:6443" -u $OPENSHIFTUSER -p $OPENSHIFTPASSWORD --insecure-skip-tls-verify=true
var=$?
echo "exit code: $var"
done

oc project $NAMESPACE
$INSTALLERHOME/cpd-linux adm -r $INSTALLERHOME/repo.yaml -a $ASSEMBLY -n $NAMESPACE --accept-all-licenses --apply
REGISTRY=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')
TOKEN=$(oc serviceaccounts get-token cpdtoken -n $NAMESPACE)
$INSTALLERHOME/cpd-linux -c ${storageclass} -r $INSTALLERHOME/repo.yaml -a $ASSEMBLY -n $NAMESPACE  --transfer-image-to=$REGISTRY/$NAMESPACE --target-registry-username=$OPENSHIFTUSER --target-registry-password=$TOKEN --accept-all-licenses ${override} --insecure-skip-tls-verify

echo "Script Complete"
#==============================================================