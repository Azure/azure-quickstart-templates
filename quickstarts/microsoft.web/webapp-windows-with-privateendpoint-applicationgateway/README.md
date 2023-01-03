# Deploying App Service Multi-Tenant, Private Endpoint and internet facing App Gateway

This template deploys an Application Gateway in Azure Virtual Network (subnet), a second subnet that containts a Private endpoint as an App Service interface, an App Service which is configured with a Private endpoint, everything is created with generated names, however, you can easily modify the template to use other default values or parameterize values. You can also 'bring your own' subnet, web app, application gateway or public ip, if you have any of the items already created.

To deploy the resource use the following Azure CLI:

```
az group create --name ExampleGroup --location "Central US"

az deployment group create \
  --name ExampleDeployment \
  --resource-group ExampleGroup \
  --template-file <path-to-bicep> \
```


![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-service-regional-vnet-integration/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-service-regional-vnet-integration/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-service-regional-vnet-integration/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-service-regional-vnet-integration/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-service-regional-vnet-integration/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-service-regional-vnet-integration/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-service-regional-vnet-integration/BicepVersion.svg)


`Tags: appService, Microsoft.Network/virtualNetworks, Microsoft.Web/serverfarms, Microsoft.Web/sites, Microsoft.Web/sites/config, Microsoft.Web/sites/hostNameBindings, Microsoft.Web/sites/networkConfig, Microsoft.Network/privateEndpoints, Microsoft.Network/privateDnsZones, Microsoft.Network/privateDnsZones/virtualNetworkLinks, Microsoft.Network/privateEndpoints/privateDnsZoneGroups`