# VMSS with Public IP Prefix 

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-vmms-with-public-ip-prefix/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-vmms-with-public-ip-prefix/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-vmms-with-public-ip-prefix/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-vmms-with-public-ip-prefix/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-vmms-with-public-ip-prefix/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-vmms-with-public-ip-prefix/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vmms-with-public-ip-prefix%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vmms-with-public-ip-prefix%2Fazuredeploy.json)



This template deploys a Virtual Machine Scale Set with Public IP Prefix. 

## Parameters + Tips
Make sure to replace the parameters with your own information. You can configure the VM SKU for the VMSS and the public IP prefix length as you desire. Be aware of naming conventions and restrictions - HTTP 400 and authenticaiton errors encountered during deployment may be due to issues with your VMSS's name.  

## Deployed Resources

### Microsoft.Network
+ **Public IP Prefix**
+ **Virtual Network**
+ **Public IP Address**
+ **Load Balancer**

### Microsoft.Compute
+ **Virtual Machine Scale Set**

## Prerequisites

You must have an existing resource group. 

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

`Tags: VMSS, public ip prefix, virtual machine scale set


