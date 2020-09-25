# Sample name

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-managed-application-custom-billing/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-managed-application-custom-billing/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-managed-application-custom-billing/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-managed-application-custom-billing/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-managed-application-custom-billing/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-managed-application-custom-billing/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Filahat%2Fazure-quickstart-templates%2Fmaster%2F101-managed-application-custom-billing%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Filahat%2Fazure-quickstart-templates%2Fmaster%2F101-managed-application-custom-billing%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

Readme TBD.

Deploy in Publisher subscription and use template output properties:

"identityApplicationId" => "Azure Active Directory application ID"
"tenantId" => "Azure Active Directory tenant ID"

to whitelist in partner center offer technical configurations

In your plan technical configuration use the template output property:

"webhookEndpoint" => "Notification Endpoint URL"

The function will listen to notifications about plan update, create an entry in CosmosDB for operation mapping. And, it will provide status of operation when AMA polls for status on given location.