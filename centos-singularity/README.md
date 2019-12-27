# Deploying a CentOS HPC VM with Singularity

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/centos-singularity/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/centos-singularity/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/centos-singularity/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/centos-singularity/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/centos-singularity/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/centos-singularity/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fbhummerstone%2Fazure-quickstart-templates%2Fcentos-singularity%2Fcentos-singularity%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fbhummerstone%2Fazure-quickstart-templates%2Fcentos-singularity%2Fcentos-singularity%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>


This template allows you to deploy a CentOS HPC VM with Singularity installed. By default this uses CentOS HPC 7.3, Singularity 2.3.1 and an A8 VM, but you can change these by passing parameters.

Note that only the following VM SKUs are currently supported:
* Standard_A8
* Standard_A9
* Standard_H16r
* Standard_H16mr

Their availability varies by region, so please double-check before deploying. 

