---
description: Create a Container App Environment with a basic Container App. It also deploys a Log Analytics Workspace to store logs.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: container-app-create
languages:
- json
- bicep
---
# Creates a Container App within a Container App Environment

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-create/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-create/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.app%2Fcontainer-app-create%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.app%2Fcontainer-app-create%2Fazuredeploy.json)

This template provides a way to deploy a **Container App** in a **Container App Environment**.

If you're new to **Container App**, see:

- [Microsoft Container Apps Documentation](https://docs.microsoft.com/azure/container-apps/)
- [Quickstarts: Microsoft Container Apps](https://docs.microsoft.com/azure/container-apps/get-started)
- [Container Apps Pricing](https://azure.microsoft.com/pricing/details/container-apps/)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

`Tags: ContainerApp, Container App, Container, Web, ARM Template, Microsoft.OperationalInsights/workspaces, Microsoft.App/managedEnvironments, Microsoft.App/containerApps`
