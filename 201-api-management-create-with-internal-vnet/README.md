# Azure API Management Service

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-internal-vnet/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-internal-vnet/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-internal-vnet/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-internal-vnet/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-internal-vnet/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-api-management-create-with-internal-vnet/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-create-with-internal-vnet%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-create-with-internal-vnet%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template shows an example of how to deploy an Azure API Management service within your own virtual network's subnet in Internal mode. The Api Management service proxy gateway can only be reached from within your private Virtual Network. Both Http and Https port are blocked inbound from Internet. There is only one port 3443 allowed from Internet Inbound for the control plane traffic. The runtime traffic all remains within your own virtual private network. The template also deploys a NSG, which is based on the documentation here https://docs.microsoft.com/en-us/azure/api-management/api-management-using-with-vnet#a-namenetwork-configuration-issues-acommon-network-configuration-issues

