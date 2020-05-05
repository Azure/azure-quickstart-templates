# Deploying a CentOS HPC VM with Singularity

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/centos-singularity/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/centos-singularity/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/centos-singularity/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/centos-singularity/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/centos-singularity/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/centos-singularity/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcentos-singularity%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcentos-singularity%2Fazuredeploy.json) 

This template allows you to deploy a CentOS HPC VM with Singularity installed. By default this uses CentOS HPC 7.3, Singularity 2.3.1 and an A8 VM, but you can change these by passing parameters.

Note that only the following VM SKUs are currently supported:
* Standard_A8
* Standard_A9
* Standard_H16r
* Standard_H16mr

Their availability varies by region, so please double-check before deploying. 


