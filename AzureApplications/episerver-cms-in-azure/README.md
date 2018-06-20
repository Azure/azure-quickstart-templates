# Provision Resources required to Deploy EPiserverCMS in Azure

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F101-episerver-in-azure%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-episerver-in-azure%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create resources required for EpiServerCMS deployment in Azure. The resources created as part of the template include a WebApp Embedded with ConnectionStrings, AppSettings and General Settings for properties like Websockets and AlwaysON. It further creates SQLServer and a database, a Storage Account and a ServiceBus. In Priniciple you can WebDeploy your Episerver Package and see your Application in action With Zero Effort on Creating Azure Resources. The template can support all tiers of service, details for each service can be found here:

[App Service Pricing](https://azure.microsoft.com/en-us/pricing/details/app-service/)

[SQL Database Pricing](https://azure.microsoft.com/en-us/pricing/details/sql-database/)

[Storage Service Pricing](https://azure.microsoft.com/en-us/pricing/details/storage/blobs/)

[Service Bus Pricing](https://azure.microsoft.com/en-us/pricing/details/service-bus/)

Once the Azure Resources are Prepared for EPiServerCMS, follow the instructions [Here](http://world.episerver.com/documentation/Items/Developers-Guide/Episerver-CMS/9/Deployment/Deployment-scenarios/Deploying-to-Azure-webapps/) for step by step guidance to deploy EPiServerCMS in Azure

For more information about Running EPiServer in Azure, [Click Here](https://azure.microsoft.com/en-us/blog/announcing-episerver-cms-in-azure-marketplace-3/).