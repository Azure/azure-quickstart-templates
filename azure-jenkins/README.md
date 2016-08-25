# Create a new instance of Jenkins running on an Ubuntu VM in Azure.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Farroyc%2Fazure-quickstart-templates%2Fupdatecustomscript%2Fazure-jenkins%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Farroyc%2Fazure-quickstart-templates%2Fmaster%2Fazure-jenkins%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create a new VM with an instance of Jenkins installed and ready to configure for deploying your application to Azure. The deployed Linux VM will have Ubuntu 14.04 LTS, openjdk-7, Azure CLI and Jenkins 2.7.2.

The template will create two VMs in your subscription. The first (name ImageTransferVM) is solely responsible for handling setup operations. Once the deployment has completed you can remove this VM and it's associated resoures. Follow https://azure.microsoft.com/en-us/documentation/articles/resource-group-portal/
to delete resources from azure resourcegroup.

The second VM will be the actual instance of Jenkins. Once the second VM has been deployed, you will need to ssh into the machine to complete the configuration of Jenkins.

## Deployment steps

You can click the "Deploy to Azure" button at the beginning of this document to deploy using the scripts in the root of this repo.

## Azure Storage Jenkins plugin configure steps
1. After the VM is provisioned, a script (/tmp/config_storage.sh) need to be executed manually once you ssh into the VM. The script will guide you to set up the storage account needed for Azure Storage Jenkins plugin.
2. The script will:
   1. Ask you to login to your Azure account.
   2. Once you login, there will be a list of subscriptions printed in the Console and ask you to select the subscription you want to use. If you have only one subscription, it will be selected as default automatically.
   3. After subscription is set, there will be a list of storage accounts printed and ask you to select one you want to use. If you have only one storage account under selected subscription, it will be selected automatically.
   4. After storage account is set, there will be a list of containers printed and ask you to select one as source container.
   5. After source container is set, you will need to continue to select the destination container. If you have only one container in the selected storage account, it will be set as both source and destination container.
3. Once the script is finished, storage account setup for Azure storage Jenkins plugin is done.

## Note

This template use a base image which will be updated regularly to include new features for azure plugin on jenkins. Readme will be updated accordingly.

DO NOT CHANGE ANYTHING in the setup-scripts
