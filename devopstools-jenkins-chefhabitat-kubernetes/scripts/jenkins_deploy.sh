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
wget -P $srcdir ${26}/scripts/elk-config.xml >> $LOG
wget -P $srcdir ${26}/scripts/VMSSjob.xml >> $LOG
wget -P $srcdir ${26}/scripts/kubernetes.xml >> $LOG
wget -P $srcdir ${26}/scripts/credentialsconfig.xml >> $LOG

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
curl -X POST -d '<jenkins><install plugin="kubernetes-cd@current" /></jenkins>' --header 'Content-Type: text/xml' -H "$CRUMB" http://$user:$api@$url/pluginManager/installNecessaryPlugins
curl -X POST -d '<jenkins><install plugin="publish-over-ssh@current" /></jenkins>' --header 'Content-Type: text/xml' -H "$CRUMB" http://$user:$api@$url/pluginManager/installNecessaryPlugins
#systemctl restart jenkins && sleep 30
sleep 30 && java -jar $srcdir/jenkins-cli.jar -s  http://$url restart --username $user --password $passwd
#creating jenkins user
echo "jenkins.model.Jenkins.instance.securityRealm.createAccount("\'"jenkinsadmin"\'","\'"Password4321"\'")" | java -jar $srcdir/jenkins-cli.jar -auth admin:`cat /var/lib/jenkins/secrets/initialAdminPassword` -s http://localhost:8080 groovy =
#updating credentials to credentials file

if [ ! -f "credentialsconfig.xml" ]
then
    xmlstarlet ed -u '//domainCredentialsMap/entry/java.util.concurrent.CopyOnWriteArrayList/com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl[id="LoginCredentials"]/username' -v "${22}" -u '//domainCredentialsMap/entry/java.util.concurrent.CopyOnWriteArrayList/com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl[id="LoginCredentials"]/password' -v "${23}" -u '//domainCredentialsMap/entry/java.util.concurrent.CopyOnWriteArrayList/com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl[id="subscriptiondetails"]/password' -v "$1" -u '//domainCredentialsMap/entry/java.util.concurrent.CopyOnWriteArrayList/com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey[id="sshkeyid"]/privateKeySource/privateKey' -v "${24}" -u '//domainCredentialsMap/entry/java.util.concurrent.CopyOnWriteArrayList/com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey[id="adminuserID"]/username' -v "${13}" $srcdir/credentialsconfig.xml | sed "s/&amp;quot;/\"/g" > $jenkinsdir/credentials.xml
fi

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
userName = &quot;${13}&quot;
password = &quot;${14}&quot;
_artifactsLocation = &quot;${26}&quot;
kibanaUsername = &quot;${27}&quot;
kibanaPassword = &quot;${28}&quot;
suffix = &quot;${29}&quot;
_artifactsLocationSasToken = &quot;${30}&quot;" $srcdir/elk-config.xml | sed "s/&amp;quot;/\"/g" > $srcdir/elk-newconfig.xml
fi

if [ ! -f "VMSSjob.xml" ]
then
    xmlstarlet ed -u '//builders/hudson.tasks.Shell/command' -v "cd /var/lib/jenkins/workspace/VMSSJob/Kubernetes
cp np-mongo-controller.yaml /var/lib/jenkins/np-mongo-controllernew
cat /var/lib/jenkins/np-mongo-controllernew | sed &quot;s:ossacr.azurecr.io/mongodb:${25}.azurecr.io/mongodb:g&quot; > np-mongo-controller.yaml
cp np-web-controller.yaml /var/lib/jenkins/np-web-controllernew
cat /var/lib/jenkins/np-web-controllernew | sed &quot;s:ossacr.azurecr.io/national-parks:${25}.azurecr.io/national-parks:g&quot; > np-web-controller.yaml
rm /var/lib/jenkins/np-mongo-controllernew
rm /var/lib/jenkins/np-web-controllernew" -u '//builders/com.microsoft.jenkins.kubernetes.KubernetesDeploy/context/ssh/sshServer' -v "${16}mgmt.$6.cloudapp.azure.com" -u '//builders/com.microsoft.jenkins.kubernetes.KubernetesDeploy/context/dockerCredentials/org.jenkinsci.plugins.docker.commons.credentials.DockerRegistryEndpoint/url' -v "http://${25}.azurecr.io" -u '//builders/jenkins.plugins.publish__over__ssh.BapSshBuilderPlugin/delegate/delegate/publishers/jenkins.plugins.publish__over__ssh.BapSshPublisher/transfers/jenkins.plugins.publish__over__ssh.BapSshTransfer/execCommand' -v "sleep 30
kubectl get --no-headers=true pods -o name | awk -F "/" '{print \$2}' > /home/${13}/pods
for podname in \`cat /home/${13}/pods\`; do kubectl logs -f \$podname > /home/${13}/\$podname.log & done &
ls" $srcdir/VMSSjob.xml | sed "s/&amp;quot;/\"/g" > $srcdir/VMSSjob.xml-newconfig.xml
fi

if [ ! -f "kubernetes.xml" ]
then
    usrname="\$AZ_USER"
    paswd="\$AZ_PASSWORD"
    subID="\$AZ_SUBID"
    sshKey="\$SSH_KEY"
    xmlstarlet ed -u '//builders/hudson.tasks.Shell/command' -v "az login -u $usrname -p $paswd
az account set --subscription $subID
az acs create --orchestrator-type kubernetes --name ${17} --resource-group $5 --admin-username ${13} --agent-count ${18} --agent-vm-size ${21} --dns-prefix ${16} --master-count ${20} --master-vm-size ${21} --generate-ssh-keys
az acr create --resource-group $5 --name ${25} --sku Basic --admin-enabled true
sleep 40" -u '//builders/jenkins.plugins.publish__over__ssh.BapSshBuilderPlugin/delegate/delegate/publishers/jenkins.plugins.publish__over__ssh.BapSshPublisher/transfers/jenkins.plugins.publish__over__ssh.BapSshTransfer/execCommand' -v "echo \"deb https://packages.elastic.co/beats/apt stable main\" | sudo tee -a /etc/apt/sources.list.d/beats.list
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get update
sudo apt-get install filebeat
cd /etc/filebeat
ls
sudo rm -rf filebeat.yml
sudo wget ${26}/scripts/filebeat.sh
sh filebeat.sh ${26} elk${29}.$6.cloudapp.azure.com ${13}
sleep 10" $srcdir/kubernetes.xml | sed "s/&amp;quot;/\"/g" > $srcdir/kubernetes-newconfig.xml
fi

wget -P $jenkinsdir ${26}/scripts/org.jenkinsci.plugins.terraform.TerraformBuildWrapper.xml
wget -P $srcdir ${26}/scripts/jenkins.plugins.publish_over_ssh.BapSshPublisherPluginConfig.xml >>$LOG

if [ ! -f "jenkins.plugins.publish_over_ssh.BapSshPublisherPluginConfig.xml" ]
then
    xmlstarlet ed -u '//hostConfigurations/jenkins.plugins.publish__over__ssh.BapSshHostConfiguration/hostname' -v "${16}mgmt.$6.cloudapp.azure.com" -u '//hostConfigurations/jenkins.plugins.publish__over__ssh.BapSshHostConfiguration/username' -v "${13}" $srcdir/jenkins.plugins.publish_over_ssh.BapSshPublisherPluginConfig.xml > $jenkinsdir/jenkins.plugins.publish_over_ssh.BapSshPublisherPlugin.xml
fi
sleep 30 && java -jar $srcdir/jenkins-cli.jar -s  http://$url restart --username $user --password $passwd && sleep 30
curl -X POST "http://$user:$api@$url/createItem?name=ELKJob" --data-binary "@$srcdir/elk-newconfig.xml" -H "$CRUMB" -H "Content-Type: text/xml"
curl -X POST "http://$user:$api@$url/createItem?name=VMSSJob" --data-binary "@$srcdir/VMSSjob.xml-newconfig.xml" -H "$CRUMB" -H "Content-Type: text/xml"
curl -X POST "http://$user:$api@$url/createItem?name=KubernetesClusterjob" --data-binary "@$srcdir/kubernetes-newconfig.xml" -H "$CRUMB" -H "Content-Type: text/xml"
