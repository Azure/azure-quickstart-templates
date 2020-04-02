export OCUSER=$1
export OCPASSWD=$2
export MASTERPUBLICHOSTNAME=$3
export NAMESPACE=$4
export APIKEYUSERNAME=$5
export APIKEY=$6
export STORAGEOPTION=$7
export ARTIFACTSLOCATION=${8::-1}
export ARTIFACTSTOKEN="$9"
export HOME=/root

# Download Installer files
assembly="aiopenscale"
version="v2.5.0.0"
storageclass=$STORAGEOPTION
namespace=$NAMESPACE
mkdir -p /ibm/$assembly
export INSTALLERHOME=/ibm/$assembly
(cd $INSTALLERHOME && wget $ARTIFACTSLOCATION/scripts/cpd-linux$ARTIFACTSTOKEN -O cpd-linux)

if [[ $APIKEY == "" ]]; then
    echo $(date) "- APIKey not provided. See README on how to get it."
    exit 12
else

(cd $INSTALLERHOME &&
cat > repo.yaml << EOF
registry:
  - url: cp.icr.io/cp/cpd
    username: $APIKEYUSERNAME
    apikey: $APIKEY
    name: base-registry
fileservers:
  - url: https://raw.github.com/IBM/cloud-pak/master/repo/cpd
EOF
)
fi

chmod +x $INSTALLERHOME/cpd-linux

# Authenticate and Install
oc login -u ${OCUSER} -p ${OCPASSWD} ${MASTERPUBLICHOSTNAME} --insecure-skip-tls-verify=true

registry=$(oc get routes -n default | grep docker-registry | awk '{print $2}')

#Docker login
echo "$(date) Get SA token"
token=$(oc serviceaccounts get-token cpdtoken)

echo "Docker login to $registry registry"
docker login -u $(oc whoami) -p $token $registry
echo "Docker login complete"

#Run installer
cd $INSTALLERHOME

# Install CPD
echo "$(date) Begin Install"
./cpd-linux adm -r repo.yaml -a $assembly -n $namespace --accept-all-licenses --apply

./cpd-linux -c $storageclass -r repo.yaml -a $assembly -n $namespace \
    --transfer-image-to=$registry/$namespace --target-registry-username=$(oc whoami) \
    --target-registry-password=$token --accept-all-licenses

if [ $? -eq 0 ]
then
    echo $(date) " - Installation completed successfully"
else
    echo $(date) "- Installation failed"
    exit 11
fi

echo "Script Complete"
#==============================================================