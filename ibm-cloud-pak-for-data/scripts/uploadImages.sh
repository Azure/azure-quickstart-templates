export SUDOUSER=$1
export OPENSHIFTPASSWORD=$2
export NAMESPACE=$3
export ASSEMBLY=$4
export CLUSTERNAME=$5
export DOMAINNAME=$6
export OPENSHIFTUSER=$7
export INSTALLERHOME=/home/$SUDOUSER/.ibm

# Upload
var=1
while [ $var -ne 0 ]; do
echo "Attempting to login $OPENSHIFTUSER to https://api.${CLUSTERNAME}.${DOMAINNAME}:6443 "
oc login "https://api.${CLUSTERNAME}.${DOMAINNAME}:6443" -u $OPENSHIFTUSER -p $OPENSHIFTPASSWORD --insecure-skip-tls-verify=true
var=$?
echo "exit code: $var"
done

oc project $NAMESPACE
$INSTALLERHOME/cpd-cli adm -r $INSTALLERHOME/repo.yaml -a $ASSEMBLY -n $NAMESPACE --accept-all-licenses --apply
REGISTRY=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')
TOKEN=$(oc serviceaccounts get-token cpdtoken -n $NAMESPACE)
$INSTALLERHOME/cpd-cli preload-images -r $INSTALLERHOME/repo.yaml -a $ASSEMBLY --action=transfer --transfer-image-to=$REGISTRY/$NAMESPACE --target-registry-username=$OPENSHIFTUSER --target-registry-password=$TOKEN --accept-all-licenses --insecure-skip-tls-verify

if [ $? -eq 0 ]
then
    echo $(date) " - Image upload successful"
else
    echo $(date) " - Image upload fail"
	exit 20
fi

echo "Script Complete"
#==============================================================