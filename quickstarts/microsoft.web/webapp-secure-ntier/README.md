---
description: This template allows you to create a secure end to end solution with two web apps with staging slots, front end and back end, front end will consume securely the back through VNet injection and Private Endpoint
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: webapp-secure-ntier
languages:
- bicep
- json
---
# Secure N-tier Web App

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-secure-ntier/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-secure-ntier/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-secure-ntier/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-secure-ntier/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-secure-ntier/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-secure-ntier/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-secure-ntier/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fwebapp-secure-ntier%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fwebapp-secure-ntier%2Fazuredeploy.json)

This template deploys a secure front end - back end web app with staging slots. The web app 2 (front end web app) is plugged in a subnet with the feature regional VNet integration, settings are set to consume a DNS private zone, the web app 1 is the back end web app, only exposed through a private endpoint.
It will create a VNet, two subnets, one where your Private Endpoint will exist, the second where you will inject the front web app, an App Service Plan in Premium v2 tier, a Private Endpoint, settings for DNS queries to the DNS Private Zone, and a private DNS zone with record for the Private Endpoint.

If you are new to Azure App Service, see:

- [Azure App Service](https://azure.microsoft.com/services/app-service/web/)
- [Template reference](https://docs.microsoft.com/azure/templates/microsoft.web/allversions)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Compute&pageNumber=1&sort=Popular&term=web+apps)

If you are new to template deployment, see:

[Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

`Tags: appServices, Microsoft.Network/virtualNetworks, Microsoft.Web/serverfarms, Microsoft.Web/sites, Microsoft.Web/sites/config, Microsoft.Web/sites/hostNameBindings, Microsoft.Web/sites/networkConfig, Microsoft.Network/privateEndpoints, Microsoft.Network/privateDnsZones, Microsoft.Network/privateDnsZones/virtualNetworkLinks, Microsoft.Network/privateEndpoints/privateDnsZoneGroups`
