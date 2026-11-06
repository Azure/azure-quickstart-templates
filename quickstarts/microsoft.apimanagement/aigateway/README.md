---
description: Deploy Azure AI Gateway and Microsoft Foundry with gpt-6.1-sol and gpt-5-mini, managed identity, failover aliases, token and cost limits, and content safety.
page_type: sample
products:
- azure
- azure-resource-manager
- azure-api-management
urlFragment: aigateway
languages:
- bicep
---
# Azure AI Gateway with Microsoft Foundry models

Applications need a shared entry point for AI models with consistent authentication, routing, and usage controls. This template provisions Azure AI Gateway and Microsoft Foundry together, deploys `gpt-6.1-sol` and `gpt-5-mini`, and exposes the `gpt-latest` and `gpt-mini-latest` aliases. The gateway authenticates to Foundry using its managed identity, without backend API keys.

> **Looking for a reusable Bicep module?** If you are embedding AI Gateway inside a larger Bicep architecture (or bringing existing Foundry resources across resource groups), see the companion Azure Verified Module [`avm/res/api-management/aigateway`](https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/api-management/aigateway).
>
> **REST API & TypeSpec specification:** For the control-plane schema, see [`Microsoft.ApiManagement/AIGateway` in `Azure/azure-rest-api-specs`](https://github.com/Azure/azure-rest-api-specs/tree/main/specification/apimanagement/resource-manager/Microsoft.ApiManagement/AIGateway) and [`Azure/azure-rest-api-specs#47711`](https://github.com/Azure/azure-rest-api-specs/issues/47711).

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/aigateway/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/aigateway/PublicDeployment.svg)
![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/aigateway/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/aigateway/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/aigateway/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Faigateway%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](https://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Faigateway%2Fazuredeploy.json)

## What is deployed

The template creates a `Microsoft.ApiManagement/aigateways@2025-09-01-preview` gateway (`sku` omitted so the resource provider defaults to `Standard`) with a system-assigned managed identity and an active runtime API key named `default`. It references the service-created `default` workspace and keeps secret key values out of deployment outputs.

It also creates a `Microsoft.CognitiveServices/accounts@2025-06-01` account with `kind: 'AIServices'`, an S0 account SKU, and these `GlobalStandard` model deployments. Each deployment uses format `OpenAI` and capacity `10` by default.

| Model and deployment name | Version | Tokens per identity per minute | Monthly cost limit per identity |
| --- | --- | --- | --- |
| `gpt-6.1-sol` | `2026-09-29` | `200000` | USD `5` |
| `gpt-5-mini` | `2025-08-07` | `400000` | USD `5` |

The `foundry` model provider uses the account's AI Services endpoint (`https://<account>.services.ai.azure.com/`) and managed-identity credentials with audience `https://cognitiveservices.azure.com`. The gateway receives the **Azure AI User** role (`53ca6127-db72-4b80-b1b0-d745d6d5456d`) at the Foundry account scope.

Both models are registered under `workspaces/default/modelProviders/foundry/models` with `/v1/chat/completions` and `/v1/responses` as supported endpoints. Registration does not make an unsupported operation available on an underlying model; choose the endpoint supported by the model you invoke.

Each model registration has a per-identity token limit, a `monthly-caller-budget` cost limit with period `month`, and content safety thresholds of `Medium` for hate, self-harm, sexual, and violence content. These are per-model caller controls, not a single shared subscription or account budget. Adjust the model policy values in `main.bicep` to suit your workload.

The default aliases are:

| Alias | Routing |
| --- | --- |
| `gpt-latest` | `gpt-6.1-sol` at priority `0`, with failover to `gpt-5-mini` at priority `1`; both weights `100`. |
| `gpt-mini-latest` | `gpt-5-mini` at priority `0`, weight `100`. |

When `enableMonitoring` is `true`, the template creates Log Analytics and Application Insights (`AzureMonitorWorkspaceIngestionMode: 'Enabled'`), assigns **Monitoring Metrics Publisher** on the Application Insights component, and creates a telemetry exporter named `applicationInsights` with `kind: 'OpenTelemetry'`, `payloadCapture: false`, and managed-identity authentication (`https://monitor.azure.com`).

When `mcpMode` is `create` (default `none`), the template also registers the public Microsoft Learn MCP tool server (`workspaces/default/toolServers/learn`) pointing to `https://learn.microsoft.com/api/mcp` over `streamableHttp` with `credentials: { type: 'noAuth' }`.

This sample supports three model-configuration modes via `foundryMode`:
- **`create` (default):** Creates a new Foundry `AIServices` account, deploys `gpt-6.1-sol` and `gpt-5-mini`, grants **Cognitive Services OpenAI User** RBAC, registers the `foundry` model provider and models with policies, and creates the `gpt-latest` and `gpt-mini-latest` aliases.
- **`existing` (BYO Foundry):** Attaches an existing Foundry account in the resource group (`foundryAccountName`), grants RBAC to the gateway's managed identity, and registers the configured `foundryModels` and `aliases` without creating a new Foundry account or model deployments.
- **`none` (configure models later):** Deploys only the gateway, `default` workspace reference, runtime API key, and optional monitoring so you can attach providers, models, and aliases in a future step via `az aigateway` or the Azure portal.

It does not create a Foundry project, hosted agent, classic API Management service, or connector gateway.

## Prerequisites and costs

Use an Azure public-cloud subscription with AI Gateway preview access. Select a gateway region available to your preview subscription and a Foundry region with access and sufficient quota for **both exact model versions** and their `GlobalStandard` deployments. Model availability and capacity vary by subscription and region; deploying this sample does not grant access or quota.

Install the [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) with [Bicep support](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install#azure-cli). Your deployment identity needs permission to create the selected resources and role assignments on the new Foundry account, for example through Owner or an appropriate combination of Contributor and Role Based Access Control Administrator.

**Costs:** Deployment provisions a standalone AI Gateway (`Standard` SKU by default) and two model deployments. Model calls and optional monitoring incur additional charges. The model cost-limit policies are caller controls and do not cap all Azure resource charges.

The Foundry account disables local key authentication and enables public network access by default. For outbound VNet integration (`properties.backend.subnet.id`), pass `backendSubnetResourceId` pointing to a subnet in the same subscription and region delegated to `Microsoft.App/environments`. For inbound caller IP restriction, pass `allowedCallerCidrRanges` (for example `['10.0.0.0/8']`) to attach an `ipFilter` policy to registered models and MCP tool servers.

## Deploy

Run from this sample directory after choosing your subscription and regions:

```bash
az login
az account set --subscription "<subscription-id>"
az provider register --namespace Microsoft.ApiManagement --wait
az provider register --namespace Microsoft.CognitiveServices --wait

resourceGroup="aigateway-rg"
foundryLocation="<foundry-model-region>"
gatewayLocation="<aigateway-preview-region>"

az group create --name "$resourceGroup" --location "$foundryLocation"
az deployment group create \
  --name aigateway \
  --resource-group "$resourceGroup" \
  --template-file main.bicep \
  --parameters azuredeploy.parameters.json \
  --parameters location="$foundryLocation" gatewayLocation="$gatewayLocation"
```

### Attach an existing Foundry account (BYO) or defer model setup

```bash
# Attach an existing Foundry account and deployments in the same resource group
az deployment group create \
  --name aigateway \
  --resource-group "$resourceGroup" \
  --template-file main.bicep \
  --parameters foundryMode=existing foundryAccountName="<existing-foundry-account>"

# Deploy only the gateway now and configure providers/models/aliases in a later step
az deployment group create \
  --name aigateway \
  --resource-group "$resourceGroup" \
  --template-file main.bicep \
  --parameters foundryMode=none

# Optionally register the no-auth Microsoft Learn MCP tool server
az deployment group create \
  --name aigateway \
  --resource-group "$resourceGroup" \
  --template-file main.bicep \
  --parameters mcpMode=create
```

Clients select `gpt-latest` or `gpt-mini-latest` in the request's model field. Role assignments can take time to propagate before model requests succeed. Deployment outputs include the gateway and Foundry account IDs, model deployment IDs, alias names, workspace ID, gateway principal ID, and runtime API key resource ID. Retrieve runtime credentials through authorized gateway key management; do not copy them into source control or deployment outputs.

## Weighted load balancing

Lower priority values are preferred. Routes at different priorities provide failover; weights select among routes at the same priority. To balance traffic between `gpt-6.1-sol` and `gpt-5-mini` with an 80:20 preference, save this as `azuredeploy.parameters.local.json`:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "aliases": {
      "value": [
        {
          "name": "gpt-latest",
          "routes": [
            { "modelName": "gpt-6.1-sol", "priority": 0, "weight": 80 },
            { "modelName": "gpt-5-mini", "priority": 0, "weight": 20 }
          ]
        },
        {
          "name": "gpt-mini-latest",
          "routes": [
            { "modelName": "gpt-5-mini", "priority": 0, "weight": 100 }
          ]
        }
      ]
    }
  }
}
```

```bash
az deployment group create \
  --name aigateway \
  --resource-group "$resourceGroup" \
  --template-file main.bicep \
  --parameters azuredeploy.parameters.json azuredeploy.parameters.local.json \
  --parameters location="$foundryLocation" gatewayLocation="$gatewayLocation"
```

The override supplies the entire alias array and keeps `gpt-mini-latest` unchanged. The two `gpt-latest` routes now share priority `0`; observed distribution varies with traffic and backend availability. Route names are restricted to the two registered models, priorities to `0`-`100`, and weights to `1`-`100`. Alias names must be unique.

Renaming or removing an alias during incremental deployment does not delete its old resource. Disabling monitoring does not delete previously deployed monitoring resources. Remove retired resources explicitly.

## Parameters

| Parameter | Purpose | Default |
| --- | --- | --- |
| `gatewayName` | Gateway name, 3-24 characters. | `aigateway-` plus a resource-group-derived suffix. |
| `location` | Foundry, model deployment, and monitoring region. | Resource group location. |
| `gatewayLocation` | Region with AI Gateway preview access. | `location`. |
| `foundryMode` | `create` (new Foundry account + models), `existing` (attach BYO Foundry account), or `none` (gateway only; configure models later). | `create`. |
| `foundryAccountName` | Name of the new or existing Foundry account. | `aigateway-foundry-` plus a resource-group-derived suffix. |
| `modelCapacity` | GlobalStandard capacity for each model deployment when `foundryMode` is `create`. | `10`. |
| `foundryModels` | Models to deploy (`create`) and register in the gateway catalog (`create` or `existing`). | `gpt-6.1-sol` (`2026-09-29`) and `gpt-5-mini` (`2025-08-07`). |
| `aliases` | Client-facing alias and route configuration when `foundryMode` is `create` or `existing`. | `gpt-latest` and `gpt-mini-latest`. |
| `mcpMode` | `none` (no MCP tools by default) or `create` (register the no-auth Microsoft Learn MCP server at `https://learn.microsoft.com/api/mcp`). | `none`. |
| `backendSubnetResourceId` | Optional subnet resource ID in the same subscription and region (delegated to `Microsoft.App/environments`) for outbound VNet integration (`properties.backend.subnet.id`). | `''`. |
| `allowedCallerCidrRanges` | Optional CIDR ranges allowed to call registered models and MCP tool servers via an inline `ipFilter` policy. | `[]`. |
| `gatewayUserPrincipalId` | Optional caller or Foundry project principal ID to grant the **AI Gateway User** role (`caad7a21-134e-43f4-a550-c5ffc17e051c`) on the gateway. | `''`. |
| `enableMonitoring` | Create monitoring and a payload-free OpenTelemetry exporter. | `false`. |
| `tags` | Resource tags. | `{}`. |

## Operational notes

Pure Bicep handles all core gateway, Foundry, RBAC, policy, MCP, VNet, and OpenTelemetry exporter resources. A few operational behaviors are outside the scope of declarative ARM deployments:

- **RBAC propagation readiness:** Entra role assignments (`Azure AI User`, `AI Gateway User`, `Monitoring Metrics Publisher`) can take 1–3 minutes to propagate on the data plane after ARM completes.
- **Managed DCR role scope:** When `AzureMonitorWorkspaceIngestionMode: 'Enabled'` creates a default Data Collection Rule in Azure Monitor's managed `ai_*_managed` resource group, Azure's deny assignment on that managed resource group blocks nested `Microsoft.Resources/deployments/write`. If your gateway identity does not inherit `Monitoring Metrics Publisher` at subscription scope, grant it directly on the `applicationInsightsDcrId` output via CLI or REST.
- **Failed-gateway recovery and Foundry project/agent wiring:** Automatically deleting and recreating a gateway stuck in `Failed` state, wiring Foundry Project connections (`ApiManagement`), or injecting local developer CLI tokens (`gh auth token`) require imperative steps.

For zero-dependency Bash and PowerShell post-provision scripts that automate these optional checks and Foundry Hosted Agent wiring, see [`infra/scripts/` in `Azure-Samples/simple-foundry-hosted-agent-python-aigateway`](https://github.com/Azure-Samples/simple-foundry-hosted-agent-python-aigateway/tree/main/infra/scripts) and [`infra/scripts/` in `Azure-Samples/simple-foundry-hosted-agent-dotnet-aigateway`](https://github.com/Azure-Samples/simple-foundry-hosted-agent-dotnet-aigateway/tree/main/infra/scripts).

## References

- [Microsoft Foundry documentation](https://learn.microsoft.com/azure/ai-foundry/)
- [Azure OpenAI role-based access control](https://learn.microsoft.com/azure/ai-foundry/openai/how-to/role-based-access-control)
- [Deploy Bicep with the Azure CLI](https://learn.microsoft.com/azure/azure-resource-manager/bicep/deploy-cli)

`Tags: Microsoft.ApiManagement/aigateways, Microsoft.ApiManagement/aigateways/workspaces/modelProviders, Microsoft.ApiManagement/aigateways/workspaces/modelProviders/models, Microsoft.ApiManagement/aigateways/workspaces/aliases, Microsoft.ApiManagement/aigateways/apiKeys, Microsoft.ApiManagement/aigateways/workspaces/telemetryExporters, Microsoft.CognitiveServices/accounts, Microsoft.CognitiveServices/accounts/deployments, Microsoft.Authorization/roleAssignments, Microsoft.OperationalInsights/workspaces, Microsoft.Insights/components, SystemAssigned`
