# Gexp Private Node

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/expanse/go-expanse-on-ubuntu/PublicLastTestDate.svg)
![Azure Public Test Result]( https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/expanse/go-expanse-on-ubuntu/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/expanse/go-expanse-on-ubuntu/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result]( https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/expanse/go-expanse-on-ubuntu/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/expanse/go-expanse-on-ubuntu/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/expanse/go-expanse-on-ubuntu/CredScanResult.svg)


<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/go-expanse-on-ubuntu/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/go-expanse-on-ubuntu/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/go-expanse-on-ubuntu/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/go-expanse-on-ubuntu/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/go-expanse-on-ubuntu/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/go-expanse-on-ubuntu/CredScanResult.svg" />&nbsp;

This Microsoft Azure template deploys a single Expanse client with a private chain for development and testing.

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fexpanse%2Fgo-expanse-on-ubuntu%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fexpanse%2Fgo-expanse-on-ubuntu%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fexpanse%2Fgo-expanse-on-ubuntu%2Fazuredeploy.json) 

Once your deployment is complete you will have a expanse environment with:

1. Expanse installed

2. A script to activate an Expanse node and begin interacting with the Expanse protocol.

![Expanse-Azure](images/exp.png)

# Template Parameters
When you launch the installation of the cluster, you need to specify the following parameters:
* `dnsLabelPrefix`: this is the public DNS name for the VM that you will use interact with your gexp console. You just need to specify an unique name.
* `adminUsername`: self-explanatory. This is the account you will use for connecting to the node
* `adminPassword`: self-explanatory. Be aware that Azure requires passwords to have One upper case, one lower case, a special character, and a number
* `vmSize`: The type of VM that you want to use for the node. The default size is D1 (1 core 3.5GB RAM) but you can change that if you expect to run workloads that require more RAM or CPU resources.
* `location`: The region where the VM should be deployed to

# Go Expanse Private Node Walkthrough
1. Get your node's IP
 1. browse to https://portal.azure.com

 2. then click browse all, followed by "resource groups", and choose your resource group

 3. then expand your resources, and public ip address of your node.

2. Connect to your gexp node
 1. SSH to the public ip of your node as the user you specified for `adminUsername`
 2. Enter your `adminPassword`

# Deploying your first contract

Welcome to Expanse! You are one step closer becoming a decentralized application developer.

