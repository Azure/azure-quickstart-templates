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
    override="--override-config portworx"
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
$INSTALLERHOME/cpd-cli adm -r $INSTALLERHOME/repo.yaml -a $ASSEMBLY -n $NAMESPACE --accept-all-licenses --apply
REGISTRY=$(oc registry info --internal)
$INSTALLERHOME/cpd-cli install -c ${storageclass} -r $INSTALLERHOME/repo.yaml -a $ASSEMBLY -n $NAMESPACE  --cluster-pull-prefix=$REGISTRY/$NAMESPACE --accept-all-licenses ${override} --insecure-skip-tls-verify

if [ $? -eq 0 ]
then
    echo $(date) " - ${ASSEMBLY} install successful"
else
    echo $(date) " - ${ASSEMBLY} install failed"
	exit 20
fi

echo "Script Complete"
#==============================================================