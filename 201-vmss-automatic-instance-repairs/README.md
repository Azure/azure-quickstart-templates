# Deploy a VM scale set with automatic instance repairs enabled

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-automatic-instance-repairs/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-automatic-instance-repairs/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-automatic-instance-repairs/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-automatic-instance-repairs/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-automatic-instance-repairs/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-automatic-instance-repairs/CredScanResult.svg" />&nbsp;

The following template deploys a VM Scale Set with automatic instance repairs policy enabled.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-windows-autoscale%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-windows-autoscale%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

The template deploys a VM scale set of Linux VMs with Apache installed through a custom script extension. The VM scale set also has health monitoring and automatic repairs enabled through the following
- health monitoring through application health extension with HTTP protocol and port number 80
- instance repairs thrgouh automatic instance repairs policy with grace period 30 minutes
