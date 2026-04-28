---
description: This template creates a Microsoft.CloudHealth health model that uses Application Insights topology-based discovery to automatically find application components and their dependencies.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: healthmodel-appinsights-topology
languages:
- bicep
- json
---
# Create an Azure Health Model with Application Insights topology discovery

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-appinsights-topology/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-appinsights-topology/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-appinsights-topology/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-appinsights-topology/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-appinsights-topology/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-appinsights-topology/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-appinsights-topology/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-appinsights-topology%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-appinsights-topology%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-appinsights-topology%2Fazuredeploy.json)

This template deploys an **Azure Health Model** (`Microsoft.CloudHealth/healthModels`) that uses **Application Insights topology** to discover application components and their dependencies.

## Overview

Instead of writing an Azure Resource Graph query, this quickstart uses the **Application Insights application map** as the discovery source. The platform reads the topology from your Application Insights resource and creates health model entities for each component and dependency it finds.

The template creates three resources:

1. **Health model** — the top-level resource with a system-assigned managed identity.
2. **Authentication setting** — configures the managed identity used by the discovery rule to access the Application Insights resource.
3. **Discovery rule** — uses the `ApplicationInsightsTopology` specification kind to discover components. Both `addRecommendedSignals` and `discoverRelationships` are enabled.

### When to use this template

- You have an Application Insights resource instrumented with your application.
- You want the health model to automatically reflect your application's topology (front-end, back-end, databases, external dependencies).
- You prefer topology-driven discovery over explicit resource queries.

> **Looking for resource-based discovery?** See the [healthmodel-basic](../healthmodel-basic/) quickstart for ARG-based discovery, or [healthmodel-with-custom-signals](../healthmodel-with-custom-signals/) to add custom signal definitions.

## Prerequisites

- An Azure subscription.
- An existing Application Insights resource (`Microsoft.Insights/components`) with application telemetry flowing in.
- The health model's managed identity needs **Reader** access to the Application Insights resource.

## Deployment

```bash
az deployment group create \
  --resource-group <resource-group-name> \
  --template-file main.bicep \
  --parameters healthModelName='<health-model-name>' \
               applicationInsightsResourceId='<app-insights-resource-id>'
```

```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName <resource-group-name> `
  -TemplateFile main.bicep `
  -healthModelName '<health-model-name>' `
  -applicationInsightsResourceId '<app-insights-resource-id>'
```

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `healthModelName` | string | *(required)* | Name of the health model resource. |
| `location` | string | Resource group location | Location for all resources. |
| `applicationInsightsResourceId` | string | *(required)* | Full resource ID of the Application Insights component (e.g. `/subscriptions/.../providers/Microsoft.Insights/components/my-app`). |

## Outputs

| Output | Type | Description |
|---|---|---|
| `healthModelId` | string | Resource ID of the deployed health model. |
| `healthModelName` | string | Name of the deployed health model. |
| `healthModelPrincipalId` | string | Principal ID of the system-assigned managed identity. |
| `discoveryRuleName` | string | Name of the discovery rule child resource. |

## Resources

- [Azure Cloud Health overview](https://learn.microsoft.com/azure/cloud-health/)
- [Health modeling in Azure](https://learn.microsoft.com/azure/cloud-health/health-modeling)
- [Application Insights application map](https://learn.microsoft.com/azure/azure-monitor/app/app-map)
- [Template reference: Microsoft.CloudHealth/healthModels](https://learn.microsoft.com/azure/templates/microsoft.cloudhealth/healthmodels)

`Tags: Health Model, Cloud Health, Application Insights, Topology, Discovery Rules, Recommended Signals, Monitoring, Microsoft.CloudHealth/healthModels, Microsoft.CloudHealth/healthModels/authenticationSettings, Microsoft.CloudHealth/healthModels/discoveryRules`
