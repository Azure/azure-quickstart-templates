---
description: This template creates an Azure Monitor health model with a three-tier structure combining Azure Resource Graph discovery with additional manually-created entities.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: healthmodel-web-app-discovery
languages:
- bicep
- json
---
# Create a web app health model with discovery

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-web-app-discovery/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-web-app-discovery/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-web-app-discovery/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-web-app-discovery/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-web-app-discovery/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-web-app-discovery/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-web-app-discovery/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-web-app-discovery%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-web-app-discovery%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-web-app-discovery%2Fazuredeploy.json)

## Overview

This template deploys an [Azure Monitor health model](https://learn.microsoft.com/azure/cloud-health/) that combines a three-tier entity structure with automatic resource discovery and additional manually-created entities.

For more information, see the [Azure Monitor health models documentation](https://learn.microsoft.com/azure/cloud-health/).

Discovery rules find Azure resources automatically, but not everything you care about is an Azure resource. External APIs, business workflows, cross-resource concerns, and SLA targets don't appear in Azure Resource Graph. This template shows how to combine discovered resources with additional manually-created entities that represent those concepts.

The three additional entities included (custom-entity-1, custom-entity-2, custom-entity-3) are placeholders — rename or replace them to fit your workload. After deployment, attach signals to them manually (KQL queries, Azure Monitor workspace Prometheus metrics, or external signals via the API).

## Prerequisites

This template discovers **existing** Azure resources using Azure Resource Graph queries filtered by tag. You must have resources already deployed that you want to monitor — without them, the discovery rules will find nothing and the model will only contain the tier entities and placeholders.

Before deploying, tag the resources you want discovered with `workload=my-web-app` (or your chosen tag name/value).

## What Gets Deployed

```
Root: <healthModelName>                              (auto-created)
│
├── frontend                                         (tier entity + discovery rule)
│   ├── [Web Apps with matching tag]                  (discovered, recommended signals on)
│   └── custom-entity-1                              (placeholder — rename and add signals)
│
├── backend                                          (tier entity + discovery rule)
│   ├── [VMs with matching tag]                       (discovered, recommended signals on)
│   └── custom-entity-2                              (placeholder — rename and add signals)
│
└── data                                             (tier entity + discovery rule)
    ├── [Cosmos DB accounts with matching tag]        (discovered, recommended signals on)
    └── custom-entity-3                              (placeholder — rename and add signals)
```

| Resource | Type | Count |
|----------|------|-------|
| Health Model | `Microsoft.CloudHealth/healthmodels` | 1 |
| Authentication Setting | `authenticationsettings` | 1 |
| Tier Entities | `entities` | 3 |
| Tier Relationships | `relationships` | 3 |
| Discovery Rules | `discoveryrules` | 3 |
| Additional Entities | `entities` | 3 (placeholders — rename to fit your workload) |
| Additional Relationships | `relationships` | 3 |

**Discovery rules find:**

| Tier | Resource Type | ARG Query Filter |
|------|---------------|------------------|
| Frontend | `microsoft.web/sites` | type + tag |
| Backend | `microsoft.compute/virtualmachines` | type + tag |
| Data | `microsoft.documentdb/databaseaccounts` | type + tag |

## Key Concepts

Discovery rules query Azure Resource Graph and automatically create entities for matching resources with recommended monitoring signals (CPU, memory, disk, etc.).

You can also create entities manually in the template for things that don't appear in Azure Resource Graph. Attach signals to these after deployment via the portal or API — KQL queries, Azure Monitor workspace Prometheus metrics, or external signals.

All entities — whether created by discovery or by the template — are the same resource type. Health state rolls up through relationships to the root regardless of how the entity was created.

## Next Steps

After deployment:

1. **Grant the managed identity Reader access** at the subscription or resource group level. This is required before any resources will be discovered — without it, the discovery rules will not return any results and the model will remain empty.
2. **Add signals** to the placeholder entities (custom-entity-1, custom-entity-2, custom-entity-3) via the portal or API.
3. **Configure alerts** on tier entities to get notified when aggregated health degrades.

## See Also

- [healthmodel-web-app](../healthmodel-web-app) — a health model with manually-created entities and relationships, no discovery.
- [healthmodel-basic-discovery](../healthmodel-basic-discovery) — a basic health model that uses Azure Resource Graph to discover VMs by tag and adds recommended signals automatically.
- [healthmodel-servicegroup-discovery](../healthmodel-servicegroup-discovery) — a health model that discovers resources from an Azure Service Group.

`Tags: Microsoft.CloudHealth/healthmodels, health model, monitoring, observability, discovery, web-app`
