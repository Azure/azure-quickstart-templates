export OCUSER=$1
export OCPASSWD=$2
export MASTERPUBLICHOSTNAME=$3
export NAMESPACE=$4
export APIKEYUSERNAME=$5
export APIKEY=$6
export STORAGEOPTION=$7
export INSTALLERARTIFACTSLOCATION="https://prodcpdartifacts.blob.core.windows.net"
export INSTALLERARTIFACTSTOKEN="se=2020-12-31T23%3A59%3A00Z&sp=r&sv=2018-11-09&sr=c&sig=7Kh6HtbULEnm8DSjFkQ5UphUK9R%2Busk%2BxhkGlIIpCQE%3D"
export HOME=/root

# Download Installer files
assembly="wsl"
version="2.1.0"
namespace=$NAMESPACE
storageclass=$STORAGEOPTION
mkdir -p /ibm/$assembly
export INSTALLERHOME=/ibm/$assembly
(cd $INSTALLERHOME && wget $INSTALLERARTIFACTSLOCATION/cpdinstaller/cpd-linux?$INSTALLERARTIFACTSTOKEN -O cpd-linux)

if [[ $APIKEY == "" ]]; then
(cd $INSTALLERHOME && wget $INSTALLERARTIFACTSLOCATION/cpdinstaller/repo.yaml?$INSTALLERARTIFACTSTOKEN -O repo.yaml)
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

echo "Sleep for 30 seconds"
sleep 30
echo "Script Complete"
#==============================================================