# Provision Resources required to Deploy EPiserverCMS in Azure

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/episerver/episerver-cms-in-azure/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/episerver/episerver-cms-in-azure/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/episerver/episerver-cms-in-azure/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/episerver/episerver-cms-in-azure/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/episerver/episerver-cms-in-azure/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/episerver/episerver-cms-in-azure/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fepiserver%2Fepiserver-cms-in-azure%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fepiserver%2Fepiserver-cms-in-azure%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fepiserver%2Fepiserver-cms-in-azure%2Fazuredeploy.json) 

This template allows you to create resources required for EpiServerCMS deployment in Azure. The resources created as part of the template include a WebApp Embedded with ConnectionStrings, AppSettings and General Settings for properties like Websockets and AlwaysON. It further creates SQLServer and a database, a Storage Account and a ServiceBus. In Priniciple you can WebDeploy your Episerver Package and see your Application in action With Zero Effort on Creating Azure Resources. The template can support all tiers of service, details for each service can be found here:

[App Service Pricing](https://azure.microsoft.com/en-us/pricing/details/app-service/)

[SQL Database Pricing](https://azure.microsoft.com/en-us/pricing/details/sql-database/)

[Storage Service Pricing](https://azure.microsoft.com/en-us/pricing/details/storage/blobs/)

[Service Bus Pricing](https://azure.microsoft.com/en-us/pricing/details/service-bus/)

Once the Azure Resources are Prepared for EPiServerCMS, follow the instructions [Here](http://world.episerver.com/documentation/Items/Developers-Guide/Episerver-CMS/9/Deployment/Deployment-scenarios/Deploying-to-Azure-webapps/) for step by step guidance to deploy EPiServerCMS in Azure

For more information about Running EPiServer in Azure, [Click Here](https://azure.microsoft.com/en-us/blog/announcing-episerver-cms-in-azure-marketplace-3/).


