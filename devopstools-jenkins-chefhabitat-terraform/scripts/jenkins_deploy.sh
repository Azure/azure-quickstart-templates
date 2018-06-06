#!/bin/bash
#Date - 06102017
#Developer - Sysgain

DATE=`date +%Y%m%d%T`
LOG=/tmp/jenkins_deploy.log.$DATE
srcdir="/usr/share/jenkins"
jenkinsdir="/var/lib/jenkins"
user="admin"
passwd=`cat /var/lib/jenkins/secrets/initialAdminPassword`
url="localhost:8080"
echo "$2,$3,$4,${15}" >> $srcdir/mongodbvhdurl.secrets

# Configure Repos for Azure Cli 2.0
echo "---Configure Repos for Azure Cli 2.0---" >> $LOG
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | sudo tee /etc/apt/sources.list.d/azure-cli.list >> $LOG
sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 417A0893 >> $LOG

# Repository Updates 
echo "---Repository Updates---"	>> $LOG
sudo apt-get update

#Installing Packages
echo "---Installing Packages---"	>> $LOG
sudo apt-get -y install apt-transport-https azure-cli html-xml-utils xmlstarlet jq >> $LOG

#Download the Required Jenkins Files
echo "---Download the Required Jenkins Files---" >> $LOG
wget -P $srcdir ${22}/scripts/elk-config.xml >> $LOG
wget -P $srcdir ${22}/scripts/MongoDBTerraformjob.xml >> $LOG
wget -P $srcdir ${22}/scripts/VMSSjob.xml >> $LOG
wget -P $srcdir ${22}/scripts/MongoDBPackerjob.xml >> $LOG
wget -P $srcdir ${22}/scripts/AppPackerjob.xml >> $LOG

#Configuring Jenkins
echo "---Configuring Jenkins---"
wget -P $srcdir http://$url/jnlpJars/jenkins-cli.jar
java -jar $srcdir/jenkins-cli.jar -s http://$url who-am-i --username $user --password $passwd
api=`curl --silent --basic http://$user:$passwd@$url/user/admin/configure | hxselect '#apiToken' | sed 's/.*value="\([^"]*\)".*/\1\n/g'`
CRUMB=`curl 'http://'$user':'$api'@'$url'/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)'`
echo $api
echo $CRUMB
curl -X POST -d '<jenkins><install plugin="packer@current" /></jenkins>' --header 'Content-Type: text/xml' -H "$CRUMB" http://$user:$api@$url/pluginManager/installNecessaryPlugins
curl -X POST -d '<jenkins><install plugin="terraform@current" /></jenkins>' --header 'Content-Type: text/xml' -H "$CRUMB" http://$user:$api@$url/pluginManager/installNecessaryPlugins
#systemctl restart jenkins && sleep 30
sleep 30 && java -jar $srcdir/jenkins-cli.jar -s  http://$url restart --username $user --password $passwd
#creating jenkins user
echo "jenkins.model.Jenkins.instance.securityRealm.createAccount("\'"jenkinsadmin"\'","\'"Password4321"\'")" | java -jar $srcdir/jenkins-cli.jar -auth admin:`cat /var/lib/jenkins/secrets/initialAdminPassword` -s http://localhost:8080 groovy =
if [ ! -f "elk-config.xml" ]
then
    xmlstarlet ed -u '//buildWrappers/org.jenkinsci.plugins.terraform.TerraformBuildWrapper/variables' -v "subscription_id = &quot;$1&quot;
client_id = &quot;$2&quot;
client_secret = &quot;$3&quot;
tenant_id = &quot;$4&quot;
ResourceGroup = &quot;$5&quot;
Location = &quot;$6&quot;
vnetName = &quot;$7&quot;
DynamicIP = &quot;$8&quot;
subnetName = &quot;$9&quot;
storageAccType = &quot;${10}&quot;
vmSize = &quot;${11}&quot;
vmName = &quot;${12}&quot;
storage_account = &quot;${15}&quot;
userName = &quot;${13}&quot;
password = &quot;${14}&quot;
_artifactsLocation = &quot;${22}&quot;
kibanaUsername = &quot;${23}&quot;
kibanaPassword = &quot;${24}&quot;
_artifactsLocationSasToken = &quot;${25}&quot;" $srcdir/elk-config.xml | sed "s/&amp;quot;/\"/g" > $srcdir/elk-newconfig.xml
fi

if [ ! -f "MongoDBTerraformjob.xml" ]
then
    xmlstarlet ed -u '//buildWrappers/org.jenkinsci.plugins.terraform.TerraformBuildWrapper/variables' -v "subscription_id = &quot;$1&quot;
client_id = &quot;$2&quot;
client_secret = &quot;$3&quot;
tenant_id = &quot;$4&quot;
ResourceGroup = &quot;$5&quot;
Location = &quot;$6&quot;
vnetName = &quot;$7&quot;
StaticIP = &quot;${18}&quot;
PriavteIP = &quot;${19}&quot;
subnetName = &quot;${16}&quot;
storageAccType = &quot;${10}&quot;
vmSize = &quot;${11}&quot;
vmName = &quot;${17}&quot;
userName = &quot;${13}&quot;
password = &quot;${14}&quot; 
sharedStorage = &quot;${15}&quot;
imageUri = &quot;UpdateUrl&quot;" $srcdir/MongoDBTerraformjob.xml | sed "s/&amp;quot;/\"/g" > $srcdir/MongoDBTerraformjob-newconfig.xml
fi

if [ ! -f "VMSSjob.xml" ]
then
    xmlstarlet ed -u '//buildWrappers/org.jenkinsci.plugins.terraform.TerraformBuildWrapper/variables' -v "subscription_id = &quot;$1&quot;
client_id = &quot;$2&quot;
client_secret = &quot;$3&quot;
tenant_id = &quot;$4&quot;
ResourceGroup = &quot;$5&quot;
Location = &quot;$6&quot;
vnetName = &quot;$7&quot;
DynamicIP = &quot;$8&quot;
subnetName = &quot;${20}&quot;
vmSize = &quot;${11}&quot;
userName = &quot;${13}&quot;
password = &quot;${14}&quot;
imageUri = &quot;UpdateUrl&quot;" $srcdir/VMSSjob.xml | sed "s/&amp;quot;/\"/g" > $srcdir/VMSSjob.xml-newconfig.xml
fi

if [ ! -f "MongoDBPackerjob.xml" ]
then
    xmlstarlet ed -u '//publishers/biz.neustar.jenkins.plugins.packer.PackerPublisher/params' -v "-var &apos;client_id=$2&apos; -var &apos;client_secret=$3&apos; -var &apos;resource_group=$5&apos; -var &apos;storage_account=${15}&apos; -var &apos;subscription_id=$1&apos; -var &apos;tenant_id=$4&apos; -var &apos;artifacts_location=${22}&apos; -var &apos;azure_region=$6&apos;" $srcdir/MongoDBPackerjob.xml | sed "s/amp;//g" > $srcdir/MongoDBPackerjob-newconfig.xml

fi

if [ ! -f "AppPackerjob.xml" ]
then
    xmlstarlet ed -u '//publishers/biz.neustar.jenkins.plugins.packer.PackerPublisher/params' -v "-var &apos;client_id=$2&apos; -var &apos;client_secret=$3&apos; -var &apos;resource_group=$5&apos; -var &apos;storage_account=${15}&apos; -var &apos;subscription_id=$1&apos; -var &apos;tenant_id=$4&apos; -var &apos;Hartfile=UpdateHartFile&apos; -var &apos;artifacts_location=${22}&apos; -var &apos;azure_region=$6&apos;" $srcdir/AppPackerjob.xml | sed "s/amp;//g" > $srcdir/AppPackerjob-newconfig.xml

fi
	
wget -P $jenkinsdir ${22}/scripts/biz.neustar.jenkins.plugins.packer.PackerPublisher.xml
wget -P $jenkinsdir ${22}/scripts/org.jenkinsci.plugins.terraform.TerraformBuildWrapper.xml
sleep 30 && java -jar $srcdir/jenkins-cli.jar -s  http://$url restart --username $user --password $passwd && sleep 30
curl -X POST "http://$user:$api@$url/createItem?name=ELKJob" --data-binary "@$srcdir/elk-newconfig.xml" -H "$CRUMB" -H "Content-Type: text/xml"
curl -X POST "http://$user:$api@$url/createItem?name=AppPackerjob" --data-binary "@$srcdir/AppPackerjob-newconfig.xml" -H "$CRUMB" -H "Content-Type: text/xml"
curl -X POST "http://$user:$api@$url/createItem?name=MongoDBPackerjob" --data-binary "@$srcdir/MongoDBPackerjob-newconfig.xml" -H "$CRUMB" -H "Content-Type: text/xml"
curl -X POST "http://$user:$api@$url/createItem?name=MongoDBTerraformjob" --data-binary "@$srcdir/MongoDBTerraformjob-newconfig.xml" -H "$CRUMB" -H "Content-Type: text/xml"
curl -X POST "http://$user:$api@$url/createItem?name=VMSSJob" --data-binary "@$srcdir/VMSSjob.xml-newconfig.xml" -H "$CRUMB" -H "Content-Type: text/xml"