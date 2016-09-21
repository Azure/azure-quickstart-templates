# Host Jenkins in an Azure VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fazure-jenkins%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fazure-jenkins%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create an instance of Azure Jenkins. Azure Jenkins is a fully functional instance of Jenkins 2.7.2 pre-configured to use Azure resources. The current version of this image lets you use Azure as a package repository to upload and download your application and it's dependencies to Azure as part of a Jenkins continuous deployment v2 pipeline. It also lets you run Jenkins jobs on Azure Slave VMs.

## A. Deploy Azure Jenkins VM
1. Click "Deploy to Azure" button. If you haven't got an Azure subscription, it will guide you on how to signup for a free trial.
2. Enter a valid name for the VM, as well as a user name and password that you will use to login remotely to the VM via SSH.
3. Remember these. You will need this to access the VM next.

## B. Login remotely to the VM via SSH
Once the VM has been deployed, note down the IP generated in the Azure portal for the VM with the name you supplied. To login -
- If you are using Windows client you can use Putty or any bash shell on Windows to login to the VM with the username and password you supplied.
- If you are using Linux or Mac use Terminal to login to the VM with the username and password you supplied.

## C. Configure Sample Jobs and Azure Active Directory configuration 
1. Once you are logged into the VM, run /opt/azure_jenkins_config/config_azure.sh. This script will guide you to set up and configure the Azure Storage plugin to be used in the sample jobs to upload and download to Storage. 
It will also provide a Service Principal to access Azure resources from Jenkins.  
2. Remember the returned subscription ID, client ID, client secret and OAuth 2.0 Token Endpoint. 

## D. Configure Azure plugins
Pre-requisite: Ensure you have executed the script in section C above and have the Azure AD secrets to configure below plugins.

1. Configure Azure Slave plugin using the parameters from C2 and follow the instructions [here](https://github.com/jenkinsci/azure-slave-plugin/tree/ARM-dev)  
2. Configure Azure Container Service plugin using the parameters from C2 and follow the instructions [here](https://github.com/Microsoft/azure-acs-plugin)  

## Note
This template uses a base Azure Marketplace image which will be updated regularly with the latest tools and plugins to access Azure resources. Readme instructions will be updated accordingly.

## Known Issue
Deployment failures due to non-unique dns name.  

## Questions/Comments? azdevopspub@microsoft.com
