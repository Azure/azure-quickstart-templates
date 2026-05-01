---
description: This template creates an Azure Health Model that discovers all resources belonging to an Azure Service Group.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: healthmodel-servicegroup-discovery
languages:
- bicep
- json
---
# Create a health model with Service Group discovery

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-servicegroup-discovery/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-servicegroup-discovery/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-servicegroup-discovery/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-servicegroup-discovery/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-servicegroup-discovery/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-servicegroup-discovery/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-servicegroup-discovery/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-servicegroup-discovery%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-servicegroup-discovery%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-servicegroup-discovery%2Fazuredeploy.json)

## Overview

This template deploys an [Azure Health Model](https://learn.microsoft.com/azure/cloud-health/) that discovers all resources belonging to an Azure Service Group. Nested Service Groups are discovered recursively (up to 10 levels deep), with each nested group represented as its own entity in the health model hierarchy.

For more information, see the [Azure Health Models documentation](https://learn.microsoft.com/azure/cloud-health/).

## Prerequisites

- An existing Azure Service Group with member resources.
- After deployment, grant the health model's managed identity **Reader** access at a scope that covers the Service Group's member resources.

## Deployed Resources

| Resource | Type | Description |
|----------|------|-------------|
| Health Model | `Microsoft.CloudHealth/healthmodels` | The health model with system-assigned managed identity. |
| Authentication Setting | `authenticationsettings` | Configures the system-assigned identity for data source queries. |
| Discovery Rule | `discoveryrules` | Discovers resources from the Service Group via Azure Resource Graph. |

After deployment, the discovery rule will:

- Query the `relationshipresources` table in Azure Resource Graph to find all member resources of the Service Group.
- Discover **nested Service Groups** recursively and represent each as an entity.
- Create **relationships** between discovered resources.
- Add **recommended signals** to discovered resources automatically.

## Next Steps

1. **Grant the managed identity** Reader access at a scope that covers the discovered resources.
2. **Configure alerts** on entities to get notified when health degrades.

## See Also

- [healthmodel-tiered-app](../healthmodel-tiered-app) — a health model with manually-created entities and relationships, no discovery.
- [healthmodel-vm-discovery](../healthmodel-vm-discovery) — a health model that discovers VMs by tag.
- [healthmodel-tiered-discovery](../healthmodel-tiered-discovery) — a tiered health model that combines ARG discovery with additional manually-created entities.
- [healthmodel-appinsights-discovery](../healthmodel-appinsights-discovery) — a health model that discovers topology from Application Insights.

`Tags: Microsoft.CloudHealth/healthmodels, health model, monitoring, observability, discovery, service group`
