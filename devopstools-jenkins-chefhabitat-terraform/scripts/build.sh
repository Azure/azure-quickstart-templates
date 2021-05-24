#!/bin/sh
appID=$1
password=$2
tenantID=$3
storageAcc=$4
subscriptionID=$5
apt-get update

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get -y install ca-certificates curl apt-transport-https lsb-release gnupg

curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 417A0893

apt-get -y install azure-cli openjdk-8-jdk

addgroup hab
useradd -g hab hab
usermod -aG hab
sleep 30
curl https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | bash
mkdir /scripts
echo "#!/bin/sh" >> /scripts/uploadhart.sh
echo "HARTFILE=\$1" >> /scripts/uploadhart.sh
echo "storageAccount='$storageAcc'" >> /scripts/uploadhart.sh
echo "export AZURE_STORAGE_ACCOUNT='$storageAcc'" >> /scripts/uploadhart.sh
echo "az login --service-principal -u '$appID' --password '$password' --tenant '$tenantID' > /dev/null" >> /scripts/uploadhart.sh
echo "az account set --subscription $subscriptionID" >> /scripts/uploadhart.sh
echo "az storage container create --name apphart --output table > /dev/null" >> /scripts/uploadhart.sh
echo "az storage blob upload --container-name apphart -f \$HARTFILE -n \$HARTFILE > /dev/null" >> /scripts/uploadhart.sh
chmod +x /scripts/uploadhart.sh
