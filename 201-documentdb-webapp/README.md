# Azure Cosmos DB Account with Web App

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-documentdb-webapp/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-documentdb-webapp/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-documentdb-webapp/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-documentdb-webapp/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-documentdb-webapp/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-documentdb-webapp/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-documentdb-webapp%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-documentdb-webapp%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

In this example, the template deploys an [Azure Cosmos DB account](https://azure.microsoft.com/en-us/documentation/articles/documentdb-introduction/#what-is-azure-documentdb), an [App Service Plan](https://azure.microsoft.com/en-us/documentation/articles/azure-web-sites-web-hosting-plans-in-depth-overview/), and creates a [Web App](https://azure.microsoft.com/en-us/documentation/articles/app-service-web-overview/) in the App Service Plan. It also adds two [Application settings](https://azure.microsoft.com/en-us/documentation/articles/web-sites-configure/) to the Web App that reference the Azure Cosmos DB account endpoint. This way solutions deployed to the Web App can connect to the Azure Cosmos DB account endpoint using those settings. 

### Note
This doesn't create an Azure Cosmos DB database, just the account where the database(s) go. You can create the database from the Web App code for example as per the [samples](https://github.com/Azure?utf8=%E2%9C%93&query=documentdb). 

