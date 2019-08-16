# Kentico MVC environment

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fkentico-mvc-environment%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fkentico-mvc-environment%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys resources required to host Kentico MVC environments in Microsoft Azure. 

[Kentico](https://www.kentico.com) is an all-in-one content management, E-commerce, and Online Marketing platform that drives business results for companies of all sizes, both on-premise or in the cloud. It gives customers and partners powerful, comprehensive tools and customer-centric solutions to create stunning websites and manage customer experiences easily in a dynamic business environment. 

Kentico supports website development using ASP.&#8203;NET MVC 5. The support is based on a separate MVC application while Kentico runs in a different application that you use as a content platform.

Both Kentico and the MVC application access data from the same database and use the Kentico API. Web farms handle content synchronization of smart search indexes and other data. This approach allows the live site (MVC application) and the administration (Kentico) to exist separately, providing finer control over each website's presentation layer.

`Tags: Kentico, cms, MVC, content management, e-commerce, online marketing`

## Deployed resources

The template deploys the following resources:

### Microsoft.Sql

Deploys an Azure SQL server with the specified configuration. The template deploys the following:

+ **Azure SQL Server**: An Azure SQL Server instance

### Microsoft.&#8203;Web

Deploys and configures an App Service hosting plan together with two App Service websites. The template deploys the following:

+ **App Service Plan**: An App Service plan hosting both websites
+ **Azure App Service front-end Web App**: A Web App hosting the MVC front-end 
+ **Azure App Service administration Web App**: A Web App hosting the Kentico Administration

## Deployment steps

Click the "deploy to Azure" button at the beginning of this document and follow the ARM template deployment wizard.

## Usage

You can use this template to quickly configure and deploy resources necessary to host a Kentico MVC environment in Azure. A standard development process follows these general steps:
1. Develop a Kentico MVC project locally.
2. Use this template to prepare resources necessary to host the project in Azure.
3. Publish the Kentico administration and the front-end application projects to the deployed Web Apps.
4. Upload the project's database to the deployed Azure SQL server instance.

For more information about MVC development and general best practices, visit the [Kentico documentation](https://docs.kentico.com).

### Additional database installation
If you did not specify the *Connection String Database Name* field during the ARM template deployment, both Web Apps are created without database connection strings. Accessing either of the sites at this point allows you to perform a delayed database installation via the online [database installation wizard](https://kentico.com/CMSPages/DocLinkMapper.ashx?version=latest&link=database_installation_additional). 

Alternatively, provided you have a local database you want to use, you can specify the database connection strings after deployment in **Azure Portal -> App Services -> Your Web App -> Configuration**. Add the connection strings in the following format:

`Name: CMSConnectionString`
`Value: Data Source=tcp:<SQL_SERVER_NAME>.database.windows.net,1433;Initial Catalog=<DATABASE_NAME>;User Id=<USER_NAME>@<SQL_SERVER_NAME>;Password=<USER_PASSWORD>;`
`Type: SQLServer`

## Environment configuration

The environment is deployed with the following configuration:

+ The Azure SQL server is by default configured to accept connections from all Microsoft Azure IP addresses. To allow connections from non-Azure services or environments, you need to set custom firewall rules for the deployed Azure SQL server.
+ If deployed to an App Service plan with a pricing tier of S1 or higher, both Web App instances are configured to automatically scale out to up to two instances via the 'Auto scale' feature.