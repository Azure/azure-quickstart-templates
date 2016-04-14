# DocumentDB Account with Web App

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-documentdb-webapp%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-documentdb-webapp%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

In this example, the template deploys a [DocumentDB account](https://azure.microsoft.com/en-us/documentation/articles/documentdb-introduction/#what-is-azure-documentdb), an [App Service Plan](https://azure.microsoft.com/en-us/documentation/articles/azure-web-sites-web-hosting-plans-in-depth-overview/), and creates a [Web App](https://azure.microsoft.com/en-us/documentation/articles/app-service-web-overview/) in the App Service Plan. It also adds two [Application settings](https://azure.microsoft.com/en-us/documentation/articles/web-sites-configure/) to the Web App that reference the DocumentDB account endpoint. This way solutions deployed to the Web App can connect to the DocumentDB account endpoint using those settings. 

### Note
This doesn't create a DocumentDB database, just the account where the database(s) go. You can create the database from the Web App code for example as per the [samples](https://github.com/Azure?utf8=%E2%9C%93&query=documentdb). 