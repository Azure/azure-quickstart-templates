---
description: This template creates an Azure Health Model with a three-tier application topology using logical entities and relationships.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: healthmodel-tiered-app
languages:
- bicep
- json
---
# Create a tiered health model

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-tiered-app/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-tiered-app/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-tiered-app/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-tiered-app/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-tiered-app/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-tiered-app/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-tiered-app/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-tiered-app%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-tiered-app%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-tiered-app%2Fazuredeploy.json)

## Overview

This template deploys an [Azure Health Model](https://learn.microsoft.com/azure/cloud-health/) with a three-tier application topology. Health models provide a structured, hierarchical view of your workload's health by organizing entities and their relationships into a tree that aggregates health state from the bottom up.

For more information, see the [Azure Health Models documentation](https://learn.microsoft.com/azure/cloud-health/).

## Deployed Resources

The template creates the following resource hierarchy:

```
Root: <healthModelName>              (auto-created)
├── frontend
│   ├── web
│   └── api-gateway
├── backend
│   ├── api
│   └── worker
└── data
    ├── database
    └── cache
```

| Resource | Type | Description |
|----------|------|-------------|
| Health Model | `Microsoft.CloudHealth/healthmodels` | The health model with system-assigned managed identity. A root entity is automatically created with the same name. |
| Authentication Setting | `authenticationsettings` | Configures the system-assigned identity for data source queries. |
| 3 Tier-1 Entities | `entities` | Logical groupings: Frontend, Backend, Data. |
| 6 Tier-2 Entities | `entities` | Components: Web, API Gateway, API, Worker, Database, Cache. |
| 9 Relationships | `relationships` | Wires the entity hierarchy together. |

## Next Steps

After deploying this template, the entities will show **Unknown** health state because no signals are configured yet. To make the model operational:

1. **Assign signals** to the Tier-2 entities by linking Azure resource metrics, Log Analytics queries, or Prometheus metrics.
2. **Grant the managed identity** read access to the data sources you want to monitor.
3. **Configure alerts** on entities to get notified when health degrades.

## See Also

- [healthmodel-vm-discovery](../healthmodel-vm-discovery) — a health model that uses Azure Resource Graph to discover VMs by tag and adds recommended signals automatically.
- [healthmodel-tiered-discovery](../healthmodel-tiered-discovery) — a tiered health model that combines discovery rules with additional manually-created entities.
- [healthmodel-appinsights-discovery](../healthmodel-appinsights-discovery) — a health model that discovers topology from Application Insights.
- [healthmodel-servicegroup-discovery](../healthmodel-servicegroup-discovery) — a health model that discovers resources from an Azure Service Group.

`Tags: Microsoft.CloudHealth/healthmodels, health model, monitoring, observability`
