---
description: Create a two Container App Environment with a basic Container App. It also deploys a Log Analytics Workspace to store logs.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: container-app-azurevote
languages:
- json
- bicep
---
# Creates a two Container App with a Container App Environment

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-azurevote/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-azurevote/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-azurevote/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-azurevote/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-azurevote/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-azurevote/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-azurevote/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.app%2Fcontainer-app-azurevote%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.app%2Fcontainer-app-azurevote%2Fazuredeploy.json)

This template shows how to run the classic Azure Vote sample app as a **Container App** in a **Container App Environment**. This service is still in **Preview**.

The Azure Vote sample app is a 2 container application. This sample shows how to run two containers in the same Container App.
- The front end container is written in python [[repo](https://github.com/Azure-Samples/azure-voting-app-redis)]
- The back end is a standard Redis container image

To look at the source code repository for the Azure Vote sample app, see:

- [Azure Vote Sample App](https://github.com/Azure-Samples/azure-voting-app-redis)

If you're new to **Container App**, see:

- [Microsoft Container Apps Documentation](https://docs.microsoft.com/azure/container-apps/)
- [Quickstarts: Microsoft Container Apps](https://docs.microsoft.com/azure/container-apps/get-started)
- [Container Apps Pricing](https://azure.microsoft.com/pricing/details/container-apps/)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

`Tags: ContainerApp, Container App, Container, Web, ARM Template, Microsoft.OperationalInsights/workspaces, Microsoft.App/managedEnvironments, Microsoft.App/containerApps`
