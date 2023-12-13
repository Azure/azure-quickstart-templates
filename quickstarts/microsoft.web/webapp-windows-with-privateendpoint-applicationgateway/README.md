---
description: This template creates an Azure Web App with Private endpoint in Azure Virtual Network Subnet , an Application Gateway v2. The Application Gateway is deployed in a vNet (subnet). The Web App restricts access to traffic from the subnet using private endpoint
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: webapp-windows-with-privateendpoint-applicationgateway
languages:
- bicep
- json
---
# Create a Web App, PE and Application Gateway v2

This template deploys an Application Gateway in Azure Virtual Network (subnet), a second subnet that containts a Private endpoint as an App Service interface, an App Service which is configured with a Private endpoint, everything is created with generated names, however, you can easily modify the template to use other default values or parameterize values. You can also 'bring your own' subnet, web app, application gateway or public ip, if you have any of the items already created.



**Note: for production environment it is recommend having a custom domain (and associated certificate) available to avoid having to rely on the default ".azurewebsites" domain., will update this template to reflect best practice in next version, more details:** [Configure App Service with Application Gateway](https://learn.microsoft.com/en-us/azure/application-gateway/configure-web-app?tabs=customdomain,azure-portal)


To deploy the resource use the following Azure CLI:

```
az group create --name ExampleGroup --location "Central US"

az deployment group create \
  --name ExampleDeployment \
  --resource-group ExampleGroup \
  --template-file <path-to-bicep> \
```


![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-windows-with-privateendpoint-applicationgateway/PublicLastTestDate.svg)

![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-windows-with-privateendpoint-applicationgateway/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-windows-with-privateendpoint-applicationgateway/FairfaxLastTestDate.svg)

![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-windows-with-privateendpoint-applicationgateway/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-windows-with-privateendpoint-applicationgateway/BestPracticeResult.svg)

![Cred Scan Check]( https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-windows-with-privateendpoint-applicationgateway/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-windows-with-privateendpoint-applicationgateway/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fwebapp-windows-with-privateendpoint-applicationgateway%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fwebapp-windows-with-privateendpoint-applicationgateway%2Fazuredeploy.json)



`Tags: appService, Microsoft.Network/virtualNetworks, Microsoft.Web/serverfarms, Microsoft.Web/sites, Microsoft.Web/sites/config, Microsoft.Web/sites/hostNameBindings, Microsoft.Web/sites/networkConfig, Microsoft.Network/privateEndpoints, Microsoft.Network/privateDnsZones, Microsoft.Network/privateDnsZones/virtualNetworkLinks, Microsoft.Network/privateEndpoints/privateDnsZoneGroups`