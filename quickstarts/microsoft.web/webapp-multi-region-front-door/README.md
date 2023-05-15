---
description: This template allows you to create a secure, highly available, multi-region end to end solution with two web apps in different regions behind Azure Front Door
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: webapp-multi-region-front-door
languages:
- bicep
- json
---
# Highly Available Multi-region Web App

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-multi-region-front-door/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-multi-region-front-door/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-multi-region-front-door/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-multi-region-front-door/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-multi-region-front-door/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-multi-region-front-door/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-multi-region-front-door/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fwebapp-multi-region-front-door%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fwebapp-multi-region-front-door%2Fazuredeploy.json)

This template deploys a identical web app infrastructure in two separate regions as well as an Azure Front Door to direct traffic. By default, one web app is set to the primary and the other is set to the secondary and all traffic is routed to the primary. In the case of a region outage in the primary region, Front Door will direct all traffic to the secondary region.

The primary region will be set to the region you select for your resource group. The secondary region will be set to East US. For a true fault tolerant deployment, don't use East US as the location for your resource group and instead use West US as those regions form one of the [regional pairs](https://learn.microsoft.com/azure/reliability/cross-region-replication-azure#azure-cross-region-replication-pairings-for-all-geographies) assigned by Azure.

If you are new to Azure App Service, see:

- [Azure App Service](https://azure.microsoft.com/services/app-service/web/)
- [Template reference](https://docs.microsoft.com/azure/templates/microsoft.web/allversions)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Compute&pageNumber=1&sort=Popular&term=web+apps)

If you are new to template deployment, see:

[Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

`Tags: appServices, Microsoft.Network/virtualNetworks, Microsoft.Web/serverfarms, Microsoft.Web/sites, Microsoft.Web/sites/config, Microsoft.Web/sites/hostNameBindings, Microsoft.Web/sites/networkConfig, Microsoft.Network/privateEndpoints, Microsoft.Network/privateDnsZones, Microsoft.Network/privateDnsZones/virtualNetworkLinks, Microsoft.Network/privateEndpoints/privateDnsZoneGroups`
