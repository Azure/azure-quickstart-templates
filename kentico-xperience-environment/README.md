# Kentico Experience environment

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/kentico-mvc-environment/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/kentico-mvc-environment/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/kentico-mvc-environment/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/kentico-mvc-environment/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/kentico-mvc-environment/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/kentico-mvc-environment/CredScanResult.svg)
[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fkentico-mvc-environment%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fkentico-mvc-environment%2Fazuredeploy.json)





This template deploys resources required to host Kentico Experience environments in Microsoft Azure.

[Kentico Xperience](https://xperience.io/) is an all-in-one content management, E-commerce, and Online Marketing platform that drives business results for companies of all sizes, both on-premise or in the cloud. It gives customers and partners powerful, comprehensive tools and customer-centric solutions to create stunning websites and manage customer experiences easily in a dynamic business environment.

Xperience supports website development using ASP.&#8203;NET Core or ASP.NET MVC 5. The support is based on a live site application, running together with a separate Xperience administration application that serves as a content platform.

Both the Xperience and live site applications access data from the same database and use the Xperience API. Web farms handle content synchronization of the application cache, files, and other data. This approach allows the live site and the administration to exist separately, providing finer control over each website's presentation layer.

`Tags: Kentico, Xperience, cms, ASP.NET, content management, e-commerce, online marketing`

## Deployed resources

The template deploys the following resources:

### Microsoft.Sql

Deploys an Azure SQL server with the specified configuration. 

The deployed SQL server by default only allows connections from other Azure resources. To allow connections from non-Azure services or environments, you need to set custom firewall rules.

#### Deployed resources:

+ **Azure SQL Server**: An Azure SQL Server instance

### Microsoft.&#8203;Web

Deploys and configures two Azure App Service Web Apps, each with a separate hosting plan (allowing for independent scale-out of both applications to multiple instances). In most cases, the live site application will receive the bulk of the traffic and have different performance requirements than the administration interface.

Furthermore, if deployed to an App Service plan with a pricing tier of *S1* or higher, the Web App hosting the live site application is configured to automatically scale out to up to two instances when necessary via the 'Autoscale' feature. Note that using 'Autoscale' may require you to reconfigure the live site application's session state storage to account for multiple applications. See [Storing session state data in an Azure Environment](https://devnet.kentico.com/CMSPages/DocLinkMapper.ashx?version=latest&link=azure_state_storing) in the Xperience documentation.

#### Deployed resources:

+ **Administration App Service Plan:** An App Service plan housing the Xperience administration application
+ **Live-site App Service Plan:** An App Service plan housing the ASP.NET Core or MVC 5 front-end application 
+ **Azure App Service front-end Web App:** A Web App hosting the front-end application
+ **Azure App Service administration Web App:** A Web App hosting the Xperience Administration application

### Microsoft.Insights

Deploys Application Insights for the live site application.

#### Deployed resources:

+ **Application Insights:** An Application Insights service that provides performance monitoring for the Web App hosting the live site application.

## Usage

You can use this template to configure and deploy resources necessary to host a Kentico Xperience environment in Azure. A recommended development process follows these general steps:

1. Develop an [MVC](https://devnet.kentico.com/CMSPages/DocLinkMapper.ashx?version=latest&link=mvc_development) or [Core](https://devnet.kentico.com/CMSPages/DocLinkMapper.ashx?version=latest&link=core_section_root) Xperience project locally.
2. Use this template to deploy resources necessary to host the Xperience site in Azure (click *Deploy to Azure* at the top of this document).
	- See the **Deployed resources** section for an overview of all resources deployed by the template.
3. [Publish](https://devnet.kentico.com/CMSPages/DocLinkMapper.ashx?version=latest&link=kentico_azure_webapps) the Xperience administration and front-end applications to the deployed Web Apps.
4. Upload the project's database to a database created under the Azure SQL server instance deployed by the template. 

For more information about site development and general best practices, visit the [Xperience documentation](https://docs.xperience.io/).

## Deployment steps

 1. Click the "**Deploy** to Azure" button at the top of this document.
 2. Select your Azure subscription, resource group, and resource location.
 3. Provide the information required to deploy Azure services used to host your Xperience site.
	 - You are free to modify all provided default values **except** for the **Location** setting. Modifying the **Location** setting's value may cause issues during the template deployment. 
4. Click **Review + create** and finish the template deployment.
	- The template deploys all resources necessary to host Xperience sites in Microsoft Azure.
5. Deploy your local database, live site application and administration application to the created Azure SQL server and Web Apps.
	- For step-by-step instructions detailing this process, visit the [Xperience documentation](https://devnet.kentico.com/CMSPages/DocLinkMapper.ashx?version=latest&link=kentico_azure_webapps).

### Additional database installation

If you did not specify the *Connection String Database Name* setting during the ARM template deployment, the template creates both Web App instances without pre-configured connection strings.

You can specify the connection strings after deployment in **Azure Portal -> App Services -> Your Web App -> Configuration**. Add the connection strings in the following format:

`Name: CMSConnectionString`

`Value: Data Source=tcp:<SQL_SERVER_NAME>.database.windows.net,1433;Initial Catalog=<DATABASE_NAME>;User Id=<USER_NAME>@<SQL_SERVER_NAME>;Password=<USER_PASSWORD>;`

`Type: SQLServer`

Substitute the *<SQL_SERVER_NAME>*, *<DATABASE_NAME>*, *<USER_NAME>*, and *<USER_PASSWORD>* placeholders with the information you provided during template deployment.


