# Install a Jenkins Master and Slave node on Ubuntu Virtual Machines using Custom Script Linux Extension

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/jenkins-on-ubuntu/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/jenkins-on-ubuntu/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/jenkins-on-ubuntu/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/jenkins-on-ubuntu/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/jenkins-on-ubuntu/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/jenkins-on-ubuntu/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fjenkins-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fjenkins-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys a Jenkins master node on an Ubuntu virtual machines and multiple Jenkin slave nodes on two additional VM. This template also provisions a storage account, virtual network, availability sets, public IP addresses and network interfaces required by the installation.

Topology
--------

This template deploys a Jenkins master and a configurable number of Jenkins slave nodes.  
The master node is exposed on a public IP address that you can access through a browser on port :8080 as well as SSH on the standard port.

##Known Issues and Limitations
- The template does not currently configure SSL on master or slave nodes.
- The template uses username/password for provisioning and would ideally use an SSH key
- The deployment scripts are not currently idempotent and this template should only be used for provisioning a new master and slave.

