# Create a free-tier Azure Cosmos DB account for Core (SQL) API

This template will create a free-tier Azure Cosmos account for Core (SQL) API in a single region with Session level consistency and one database with 400 RU/s that can be shared with up to 25 containers. Accounts in free tier will not be billed for usage of 400 RU/s or 5GB of data or less.

Below are the parameters which can be user configured in the parameters file including:

- **Location:** Enter location for primary region.
- **Database Name:** Enter the database name for the account.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)]("https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-free%2Fazuredeploy.json")  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)]("http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cosmosdb-free%2Fazuredeploy.json")
