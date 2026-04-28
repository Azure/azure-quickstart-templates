---
description: This template creates a Microsoft.CloudHealth health model with a discovery rule, recommended signals, and custom signal definitions for health monitoring.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: healthmodel-with-custom-signals
languages:
- bicep
- json
---
# Create an Azure Health Model with custom signal definitions

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-with-custom-signals/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-with-custom-signals/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-with-custom-signals/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-with-custom-signals/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-with-custom-signals/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-with-custom-signals/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-with-custom-signals/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-with-custom-signals%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-with-custom-signals%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-with-custom-signals%2Fazuredeploy.json)

This template deploys an **Azure Health Model** (`Microsoft.CloudHealth/healthModels`) with a **discovery rule**, **recommended signals**, and a **custom signal definition** to enable proactive health monitoring of Azure resources.

## Overview

Azure Health Models provide a unified way to define and monitor the health of your workloads. This quickstart demonstrates three key concepts:

### Discovery Rules

Discovery rules automatically detect Azure resources that should be part of the health model. A discovery rule uses an **Azure Resource Graph** (ARG) query to find matching resources. The query must return at least a column named `id` containing the Azure resource ID of each discovered resource. Discovered resources are represented as **entities** in the health model.

This template configures a discovery rule that finds all virtual machines in the current resource group. You can customise the `resourceGraphQuery` parameter to target any set of resources.

### Recommended Signals

When `addRecommendedSignals` is set to **Enabled** on a discovery rule, the platform automatically attaches curated health signals to each discovered entity based on its resource type. These signals use well-known Azure platform metrics and are maintained by Microsoft — no manual signal configuration is required.

### Custom Signal Definitions

In addition to recommended signals, you can define your own **signal definitions** (`Microsoft.CloudHealth/healthModels/signalDefinitions`). Each signal definition targets a specific metric or query, and includes evaluation rules with **degraded** and **unhealthy** thresholds. This template includes a custom CPU utilization signal as an example:

| Threshold | Operator | Default | Health State |
|---|---|---|---|
| Degraded | GreaterThan | 75 % | Degraded |
| Unhealthy | GreaterThan | 90 % | Unhealthy |

### Relationship Discovery

When `discoverRelationships` is set to **Enabled**, the platform infers parent/child relationships between discovered entities using built-in topology rules. These relationships are used to propagate health state through the model.

## Resources deployed

| Resource | Type | Description |
|---|---|---|
| Health model | `Microsoft.CloudHealth/healthModels` | Top-level resource with a system-assigned managed identity. |
| Authentication setting | `Microsoft.CloudHealth/healthModels/authenticationSettings` | Configures the managed identity used by discovery rules to query Azure Resource Graph. |
| Discovery rule | `Microsoft.CloudHealth/healthModels/discoveryRules` | Finds resources via an ARG query and optionally adds recommended signals and relationships. |
| Signal definition | `Microsoft.CloudHealth/healthModels/signalDefinitions` | Custom CPU utilization signal with degraded/unhealthy thresholds. |

## Prerequisites

- An Azure subscription.
- A resource group containing (or that will contain) the resources to monitor.

## Deployment

You can deploy this template using the **Deploy to Azure** button above, or via the Azure CLI:

```bash
az deployment group create \
  --resource-group <resource-group-name> \
  --template-file main.bicep \
  --parameters healthModelName='<health-model-name>'
```

Or with Azure PowerShell:

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
| `resourceGraphQuery` | string | VMs in current resource group | Azure Resource Graph query that discovers resources. Must return a column named `id`. |
| `addRecommendedSignals` | string | `Enabled` | Whether the discovery rule automatically adds recommended signals to discovered entities. |
| `discoverRelationships` | string | `Enabled` | Whether the discovery rule automatically discovers relationships between entities. |
| `cpuUnhealthyThreshold` | int | `90` | CPU utilization threshold (%) that marks a resource as unhealthy. |
| `cpuDegradedThreshold` | int | `75` | CPU utilization threshold (%) that marks a resource as degraded. |

## Outputs

| Output | Type | Description |
|---|---|---|
| `healthModelId` | string | Resource ID of the deployed health model. |
| `healthModelName` | string | Name of the deployed health model. |
| `healthModelPrincipalId` | string | Principal ID of the health model's system-assigned managed identity. |
| `authenticationSettingName` | string | Name of the authentication setting child resource. |
| `discoveryRuleName` | string | Name of the discovery rule child resource. |
| `cpuSignalName` | string | Name of the custom CPU utilization signal definition. |

## Resources

If you are new to Azure Health Models, see:

- [Azure Cloud Health overview](https://learn.microsoft.com/azure/cloud-health/)
- [Health modeling in Azure](https://learn.microsoft.com/azure/cloud-health/health-modeling)
- [Template reference: Microsoft.CloudHealth/healthModels](https://learn.microsoft.com/azure/templates/microsoft.cloudhealth/healthmodels)
- [Azure Resource Manager documentation](https://learn.microsoft.com/azure/azure-resource-manager/)

`Tags: Health Model, Cloud Health, Discovery Rules, Recommended Signals, Signal Definitions, Monitoring, Microsoft.CloudHealth/healthModels, Microsoft.CloudHealth/healthModels/authenticationSettings, Microsoft.CloudHealth/healthModels/discoveryRules, Microsoft.CloudHealth/healthModels/signalDefinitions`
