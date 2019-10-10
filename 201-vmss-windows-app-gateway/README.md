# Windows VM Scale Set with Application Gateway Integration

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-windows-app-gateway/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-windows-app-gateway/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-windows-app-gateway/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-windows-app-gateway/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-windows-app-gateway/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vmss-windows-app-gateway/CredScanResult.svg" />&nbsp;

This template deploys a Windows VM Scale Set integrated with Azure Application Gateway.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-windows-app-gateway%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-windows-app-gateway%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

The Application Gateway is configured for round robin load balancing of incoming connections at port 80 (of the gateway's public IP address) to VMs in the scale set.

Note that this template does not install an application on the VM Scale Set VMs, so if you want to demonstrate the round robin load balancing, the template will need to be updated (for example by adding an extension to install a web server).

This template supports VM scale sets of up to 1,000 VMs, and uses Azure Managed Disks.

