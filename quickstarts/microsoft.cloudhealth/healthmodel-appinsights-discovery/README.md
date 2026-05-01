---
description: This template creates an Azure Health Model that discovers application topology from an Application Insights component.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: healthmodel-appinsights-discovery
languages:
- bicep
- json
---
# Create a health model with App Insights topology discovery

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-appinsights-discovery/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-appinsights-discovery/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-appinsights-discovery/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-appinsights-discovery/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-appinsights-discovery/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-appinsights-discovery/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-appinsights-discovery/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-appinsights-discovery%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-appinsights-discovery%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-appinsights-discovery%2Fazuredeploy.json)

## Overview

This template deploys an [Azure Health Model](https://learn.microsoft.com/azure/cloud-health/) that discovers your application topology from an existing Application Insights component. The discovery rule reads the Application Insights app map to find cloud roles and their dependency targets, then creates entities and relationships automatically.

For more information, see the [Azure Health Models documentation](https://learn.microsoft.com/azure/cloud-health/).

## Prerequisites

- An existing Application Insights component with a backing Log Analytics Workspace.
- The Application Insights component must have recent telemetry data so that cloud roles and dependencies are visible in the app map.
- After deployment, grant the health model's managed identity **Monitoring Reader** access to the Application Insights component and its backing Log Analytics Workspace.

## Deployed Resources

| Resource | Type | Description |
|----------|------|-------------|
| Health Model | `Microsoft.CloudHealth/healthmodels` | The health model with system-assigned managed identity. |
| Authentication Setting | `authenticationsettings` | Configures the system-assigned identity for data source queries. |
| Discovery Rule | `discoveryrules` | Discovers topology from Application Insights. |

After deployment, the discovery rule will:

- Create entities for each **cloud role** found in the app map.
- Resolve **dependency targets** (e.g. database hostnames) to Azure resource IDs and create entities for them.
- Create **relationships** between cloud roles and their dependency targets.
- Add **recommended signals** to discovered entities automatically.

## Next Steps

1. **Grant the managed identity** Monitoring Reader access to the Application Insights component and its Log Analytics Workspace.
2. **Configure alerts** on entities to get notified when health degrades.

## See Also

- [healthmodel-tiered-app](../healthmodel-tiered-app) — a health model with manually-created entities and relationships, no discovery.
- [healthmodel-vm-discovery](../healthmodel-vm-discovery) — a health model that discovers VMs by tag.
- [healthmodel-tiered-discovery](../healthmodel-tiered-discovery) — a tiered health model that combines ARG discovery with additional manually-created entities.
- [healthmodel-servicegroup-discovery](../healthmodel-servicegroup-discovery) — a health model that discovers resources from an Azure Service Group.

`Tags: Microsoft.CloudHealth/healthmodels, health model, monitoring, observability, discovery, application insights`
