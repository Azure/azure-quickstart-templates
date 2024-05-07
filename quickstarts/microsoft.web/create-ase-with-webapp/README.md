---
description: Creates an Azure App Service Environment inside A Virtual Network Subnet. This template also adds a Azure Web App inside the App Service Environment. Template originally authored by Callum Brankin of PixelPin
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: create-ase-with-webapp
languages:
- json
---
# Create Azure App Service Environment With An Web App Added.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/create-ase-with-webapp/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/create-ase-with-webapp/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/create-ase-with-webapp/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/create-ase-with-webapp/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/create-ase-with-webapp/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/create-ase-with-webapp/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fcreate-ase-with-webapp%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fcreate-ase-with-webapp%2Fazuredeploy.json)

This template creates a Virtual Network with a App Service environment, along with a App Service Plan and a App Service added to the App Service environment.

`Tags: Microsoft.Network/virtualNetworks, Microsoft.Web/hostingEnvironments, Microsoft.Web/serverfarms, Microsoft.Web/sites`
