---
description: This template creates an Azure Health Model that automatically discovers virtual machines using Azure Resource Graph queries filtered by tag.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: healthmodel-vm-discovery
languages:
- bicep
- json
---
# Create a health model with VM discovery

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-vm-discovery/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-vm-discovery/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-vm-discovery/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-vm-discovery/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-vm-discovery/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-vm-discovery/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-vm-discovery/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-vm-discovery%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-vm-discovery%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-vm-discovery%2Fazuredeploy.json)

## Overview

This template deploys an [Azure Health Model](https://learn.microsoft.com/azure/cloud-health/) that automatically discovers virtual machines using an Azure Resource Graph query filtered by tag. Recommended monitoring signals (CPU, memory, disk) are added to each discovered VM automatically.

For more information, see the [Azure Health Models documentation](https://learn.microsoft.com/azure/cloud-health/).

## Prerequisites

Before deploying, tag the virtual machines you want to monitor:

```bash
az tag update --resource-id <vm-resource-id> --operation merge --tags healthmodel=<your-health-model-name>
```

## Deployed Resources

| Resource | Type | Description |
|----------|------|-------------|
| Health Model | `Microsoft.CloudHealth/healthmodels` | The health model with system-assigned managed identity. |
| Authentication Setting | `authenticationsettings` | Configures the system-assigned identity for data source queries. |
| Discovery Rule | `discoveryrules` | Discovers VMs matching the specified tag. Recommended signals are added automatically. |

After deployment, the discovery rule will find all VMs with the matching tag and create entities with monitoring signals under the root of the health model.

## Next Steps

- To monitor additional resource types, add more discovery rules via the portal or a follow-up template.
- To organise discovered resources into groupings, create entities and relationships manually.

## See Also

- [healthmodel-tiered-app](../healthmodel-tiered-app) — a health model with manually-created entities and relationships, no discovery.
- [healthmodel-tiered-discovery](../healthmodel-tiered-discovery) — a tiered health model that combines discovery rules with additional manually-created entities.
- [healthmodel-appinsights-discovery](../healthmodel-appinsights-discovery) — a health model that discovers topology from Application Insights.
- [healthmodel-servicegroup-discovery](../healthmodel-servicegroup-discovery) — a health model that discovers resources from an Azure Service Group.

`Tags: Microsoft.CloudHealth/healthmodels, health model, monitoring, observability, discovery, virtual machines`
