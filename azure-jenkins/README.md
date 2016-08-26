# Host Jenkins in an Azure VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Farroyc%2Fazure-quickstart-templates%2Fmaster%2Fazure-jenkins%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Farroyc%2Fazure-quickstart-templates%2Fmaster%2Fazure-jenkins%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create an instance of Azure Jenkins. Azure Jenkins is a fully functional instance of Jenkins 2.7.2 pre-configured to use Azure resources. The current version of this image lets you use Azure as a package repository to upload and download your application and it's dependencies to Azure as part of a Jenkins continuous deployment v2 pipeline.

## Deploy Azure Jenkins VM
1. Click "Deploy to Azure" button. If you haven't got an Azure subscription, it will guide you on how to signup for a free trial.
2. Enter a valid name for the VM, as well as a user name and password that you will use to login remotely to the VM via SSH.
3. Remember these. You will need this to access the VM next.

## Login remotely to the VM via SSH
Once the VM has been deployed, note down the IP generated in the Azure portal for the VM with the name you supplied. To login -
- If you are using Windows client use Putty to login to the VM with the username and password you supplied.
- If you are using Linux or Mac use Terminal to login to the VM with the username and password you supplied.

## Configure Jenkins to access Azure
1. Once you are logged into the VM, run /opt/azure_jenkins_config/config_storage.sh. This script will guide you to set up the storage account needed for Azure Storage Jenkins plugin.
   > Note: If the script doesn't exist, download it using below command.

   ```bash
   sudo wget -O /opt/azure_jenkins_config/config_storage.sh "https://raw.githubusercontent.com/arroyc/azure-quickstart-templates/master/azure-jenkins/setup-scripts/config_storage.sh"
   ```
2. Login to your Azure account using the live id you used when creating your Azure subscription or with any valid user in your Azure subscription.
3. Select the subscription you want to use if you have more than one.
4. Select the storage account you want to use if you have more than one.
5. Select the destination container you will upload files to if you have more than one.

## Note
This template use a base Azure Marketplace image which will be updated regularly to describe to use Azure resources with Jenkins. Readme instructions will be updated accordingly.
