# Create a new instance of Jenkins running on an Ubuntu VM in Azure.  

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Farroyc%2Fazure-quickstart-templates%2Fmaster%2Fazure-jenkins%2Fazuredeploy.json" target="_blank">
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

## Note

This template use a base image which will be updated regularly to include new features for azure plugin on jenkins. Readme will be updated accordingly.
