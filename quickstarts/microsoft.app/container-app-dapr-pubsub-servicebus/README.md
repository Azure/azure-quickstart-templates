---
description: Create a Dapr pub-sub servicebus app using Container Apps.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: container-app-dapr-pubsub-servicebus
languages:
- json
- bicep
---
# Creates a Dapr pub-sub servicebus app using Container Apps

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-dapr-pubsub-servicebus/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-dapr-pubsub-servicebus/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-dapr-pubsub-servicebus/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-dapr-pubsub-servicebus/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-dapr-pubsub-servicebus/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-dapr-pubsub-servicebus/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.app/container-app-dapr-pubsub-servicebus/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.app%2Fcontainer-app-dapr-pubsub-servicebus%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.app%2Fcontainer-app-dapr-pubsub-servicebus%2Fazuredeploy.json)

This template shows how to deploy a Dapr pub-sub servicebus application as a **Container App** in a **Container App Environment**. 

The application deploys the Dapr application used in this [Azure sample template](https://github.com/Azure-Samples/pubsub-dapr-nodejs-servicebus). The template itself is optimised for Developers using the [Azure Developer CLI](https://github.com/Azure/azure-dev), whereas this quickstart is more focussed on the container build and Infrastructure deployment as a single deployment unit.

See the [Dapr Container App](https://github.com/Azure/bicep-registry-modules/blob/main/modules/app/dapr-containerapp/README.md) module in the Bicep Registry for more information.

If you're new to **Dapr**, see:

- [Dapr Concepts](https://docs.dapr.io/concepts/)

If you're new to **Container App**, see:

- [Microsoft Container Apps Documentation](https://docs.microsoft.com/azure/container-apps/)
- [Quickstarts: Microsoft Container Apps](https://docs.microsoft.com/azure/container-apps/get-started)
- [Container Apps Pricing](https://azure.microsoft.com/pricing/details/container-apps/)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

`Tags: Dapr, Pub-sub, Pubsub, ContainerApp, Container App, Container, Service Bus, ServiceBus, ARM Template, Microsoft.OperationalInsights/workspaces, Microsoft.App/managedEnvironments, Microsoft.App/containerApps`
