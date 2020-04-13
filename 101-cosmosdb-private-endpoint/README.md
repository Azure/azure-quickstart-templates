# Create an Azure Cosmos account, a virtual network and a private endpoint

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-cosmosdb-private-endpoint/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-cosmosdb-private-endpoint/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-cosmosdb-private-endpoint/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-cosmosdb-private-endpoint/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-cosmosdb-private-endpoint/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-cosmosdb-private-endpoint/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-private-endpoint%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-private-endpoint%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template will create a virtual network, a Cosmos account and a private endpoint exposing the Cosmos account to the virtual network.

Below are the parameters which can be user configured in the parameters file including:

- **Location:** Select where the resource should be created (default is target resource group's location).
- **Virtual Network Name:** Enter a name for the virtual network.
- **Account Name:** Enter a name for the new Cosmos account.
- **Public Network Access:** Select whether public traffic is allowed to access the account (default is Enabled). When value is set to Disabled, public network traffic is blocked even before the private endpoint is created.
- **Private Endpoint Name:** Enter a name for the private endpoint.

`Tags : CosmosDB`
