---
description: This template creates an Azure Health Model with a three-tier application topology using logical entities and relationships.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: healthmodel-web-app
languages:
- bicep
- json
---
# Create a web app health model

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-web-app/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-web-app/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-web-app/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-web-app/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-web-app/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-web-app/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cloudhealth/healthmodel-web-app/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-web-app%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-web-app%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cloudhealth%2Fhealthmodel-web-app%2Fazuredeploy.json)

## Overview

This template deploys an [Azure Health Model](https://learn.microsoft.com/azure/cloud-health/) with a three-tier web application topology, complete with signal definitions and alerts on the root entity. It demonstrates the health modelling workflow — entity structure, signal definitions, and alerting — all deployable with a single parameter.

After deployment, wire the signal definitions to your entities by adding `signalGroups` via the portal or API.

For more information, see the [Azure Health Models documentation](https://learn.microsoft.com/azure/cloud-health/).

## Deployed Resources

The template creates the following resource hierarchy:

```
Root: <healthModelName>              (alert: Sev1 unhealthy, Sev3 degraded)
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

| Resource | Type | Count | Description |
|----------|------|-------|-------------|
| Health Model | `healthmodels` | 1 | With system-assigned managed identity. |
| Authentication Setting | `authenticationsettings` | 1 | Configures the managed identity for data source queries. |
| Signal Definitions | `signaldefinitions` | 7 | Reusable signal templates (5 metric, 2 log). |
| Entities | `entities` | 10 | Root + 3 tiers + 6 components. |
| Relationships | `relationships` | 9 | Wires the entity hierarchy together. |

### Signal Definitions

These are deployed as reusable templates. After deployment, attach them to entities by adding `signalGroups` via the portal or API.

| Signal | Kind | Metric / Query | Degraded | Unhealthy |
|--------|------|----------------|----------|-----------|
| HTTP Response Time | `AzureResourceMetric` | `HttpResponseTime` (Avg) | > 2s | > 5s |
| HTTP Server Errors | `AzureResourceMetric` | `Http5xx` (Total/5m) | > 5 | > 25 |
| APIM Failed Requests | `AzureResourceMetric` | `FailedRequests` (Total/5m) | > 10 | > 50 |
| Cosmos DB Availability | `AzureResourceMetric` | `ServiceAvailability` (Avg) | < 99.9% | < 99% |
| Redis Server Load | `AzureResourceMetric` | `serverLoad` (Avg) | > 70% | > 90% |
| Failed Requests (Log) | `LogAnalyticsQuery` | `AppRequests` (5m window) | > 10 | > 50 |
| Exception Rate (Log) | `LogAnalyticsQuery` | `AppExceptions` (5m window) | > 5 | > 20 |

## Next Steps

1. **Attach signals to entities** — update each T2 entity’s `signalGroups.azureResource` with the resource ID of the Azure resource to monitor and reference the signal definitions.
2. **Grant the managed identity** Monitoring Reader access to the monitored resources.
3. **Add action groups** to the root entity alerts to receive notifications (email, SMS, webhook, etc.).

## See Also

- [healthmodel-basic-discovery](../healthmodel-basic-discovery) — a basic health model that uses Azure Resource Graph to discover VMs by tag and adds recommended signals automatically.
- [healthmodel-web-app-discovery](../healthmodel-web-app-discovery) — a web app health model that combines discovery rules with additional manually-created entities.
- [healthmodel-servicegroup-discovery](../healthmodel-servicegroup-discovery) — a health model that discovers resources from an Azure Service Group.

`Tags: Microsoft.CloudHealth/healthmodels, health model, monitoring, observability, signals, alerts`
