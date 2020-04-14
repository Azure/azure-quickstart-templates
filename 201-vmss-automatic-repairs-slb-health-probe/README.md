# Deployment of a VM Scale Set of Linux VMs behind an load balancer with health probe and automatic instance repairs enabled

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-automatic-repairs-slb-health-probe/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-automatic-repairs-slb-health-probe/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-automatic-repairs-slb-health-probe/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-automatic-repairs-slb-health-probe/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-automatic-repairs-slb-health-probe/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-automatic-repairs-slb-health-probe/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-automatic-repairs-slb-health-probe%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-automatic-repairs-slb-health-probe%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true"/>
</a>

This template allows you to deploy a VM scale set of Linux VMs using the latest version of Ubuntu Linux 18.04-LTS. This scale set is behind a load balancer with health probe configured. This load balancer health probe is used for application health monitoring by the scale set. The VM scale set also has automatic repairs policy enabled with a grace period of 30 minutes.
