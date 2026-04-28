---
description: This template creates a minimal Microsoft.CloudHealth health model with a discovery rule and recommended signals — the fastest way to get started with Azure health modeling.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: healthmodel-basic
languages:
- bicep
- json
---
# Create a basic Azure Health Model with discovery and recommended signals

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-basic/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-basic/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-basic/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-basic/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-basic/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-basic/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-basic/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-basic%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-basic%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-basic%2Fazuredeploy.json)

This template deploys a minimal **Azure Health Model** (`Microsoft.CloudHealth/healthModels`) with a single **discovery rule** and **recommended signals** enabled. It is the fastest way to get started with health modeling in Azure.

## Overview

The template creates three resources:

1. **Health model** — the top-level resource with a system-assigned managed identity.
2. **Authentication setting** — configures the managed identity used by the discovery rule to query Azure Resource Graph.
3. **Discovery rule** — uses an Azure Resource Graph (ARG) query to find resources. Both `addRecommendedSignals` and `discoverRelationships` are enabled, so the platform automatically attaches curated health signals and infers topology between discovered entities.

By default the discovery rule finds all virtual machines in the current resource group. Customise the `resourceGraphQuery` parameter to target any set of Azure resources.

> **Looking for more control?** See the [healthmodel-with-custom-signals](../healthmodel-with-custom-signals/) quickstart to layer custom signal definitions on top of recommended signals.

## Prerequisites

- An Azure subscription.
- A resource group containing (or that will contain) the resources to monitor.

## Deployment

```bash
az deployment group create \
  --resource-group <resource-group-name> \
  --template-file main.bicep \
  --parameters healthModelName='<health-model-name>'
```

```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName <resource-group-name> `
  -TemplateFile main.bicep `
  -healthModelName '<health-model-name>'
```

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `healthModelName` | string | *(required)* | Name of the health model resource. |
| `location` | string | Resource group location | Location for all resources. |
| `resourceGraphQuery` | string | VMs in current resource group | ARG query returning a column named `id` with Azure resource IDs. |

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
- [Template reference: Microsoft.CloudHealth/healthModels](https://learn.microsoft.com/azure/templates/microsoft.cloudhealth/healthmodels)

`Tags: Health Model, Cloud Health, Discovery Rules, Recommended Signals, Monitoring, Microsoft.CloudHealth/healthModels, Microsoft.CloudHealth/healthModels/authenticationSettings, Microsoft.CloudHealth/healthModels/discoveryRules`
