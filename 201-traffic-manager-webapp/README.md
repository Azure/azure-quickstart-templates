# Azure Traffic Manager with web apps

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-traffic-manager-webapp/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-traffic-manager-webapp/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-traffic-manager-webapp/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-traffic-manager-webapp/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-traffic-manager-webapp/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-traffic-manager-webapp/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-traffic-manager-webapp%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-traffic-manager-webapp%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template shows how to create an Azure Traffic Manager profile to provide failover resilience between two Web Apps.

The accompanying PowerShell script shows how to create a resource group from the template and read back the Traffic Manager profile details.  Before running the script, edit *azuredeploy.parameters.json* and replace the values marked with *'#####'*.


See also:

- <a href="https://azure.microsoft.com/en-us/documentation/articles/traffic-manager-routing-methods/">Traffic Manager routing methods</a> for details of the different routing methods available.
- <a href="https://msdn.microsoft.com/en-us/library/azure/mt163581.aspx">Create or update a Traffic Manager profile</a> for details of the JSON elements relating to a Traffic Manager profile.


