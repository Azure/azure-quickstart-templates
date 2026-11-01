---
description: Deploy Azure AI Gateway with optional managed-identity Azure OpenAI routing, a weighted model alias, token limits, and Application Insights.
page_type: sample
products:
- azure
- azure-resource-manager
- azure-api-management
urlFragment: aigateway
languages:
- bicep
---
# Azure AI Gateway with optional Azure OpenAI routing

Applications that call multiple AI model deployments need a common entry point for routing, authentication, and usage limits. This template deploys Azure AI Gateway and can connect existing Azure OpenAI deployments through a client-facing model alias. The gateway uses its managed identity to authenticate to Azure OpenAI, so backend API keys are not needed.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/aigateway/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/aigateway/PublicDeployment.svg)
![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/aigateway/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/aigateway/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/aigateway/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Faigateway%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](https://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Faigateway%2Fazuredeploy.json)

## What is deployed

The default deployment creates a `Microsoft.ApiManagement/aigateways` resource using API version `2025-09-01-preview`, the **Premium** SKU, a system-assigned managed identity, and an active runtime API key named `default`. The service supplies the `default` workspace. The template does not return secret key values.

When `backend` is supplied, the template also creates an Azure OpenAI model provider, a model registration for each existing deployment, and a weighted alias with a per-identity token limit. It assigns the gateway the **Cognitive Services OpenAI User** role on that Azure OpenAI account only. It does not create or change the backend account or its model deployments.

When `enableMonitoring` is `true`, the template creates Log Analytics and Application Insights and configures an Application Insights telemetry exporter with `payloadCapture: false`.

This sample does not deploy a classic API Management service or a connector gateway.

## Prerequisites

Use an Azure subscription and region with access to the Azure AI Gateway preview, and register the `Microsoft.ApiManagement` resource provider. Preview availability is not guaranteed in every region or subscription. This sample targets Azure public cloud only.

Install the [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) with [Bicep support](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install#azure-cli). Your deployment identity needs permission to create the selected resources. Connecting a backend additionally requires permission to create role assignments on the existing Azure OpenAI account, for example through the Role Based Access Control Administrator role at that scope.

For backend routing, use an existing Azure OpenAI account **in the same resource group as the gateway** with reachable network access and existing chat-completion deployments. Deployment names, model names, and model versions must match that account. Managed identity grants authorization but does not bypass the account's firewall or private network configuration.

**Costs:** The gateway uses Premium; Consumption is not supported by this preview contract. Review pricing and preview terms before deploying. Optional monitoring incurs Log Analytics and Application Insights charges, and routed model calls incur backend model charges.

## Deploy the gateway

Run these commands from this sample directory. Choose a region available to your preview subscription.

```bash
az login
az account set --subscription "<subscription-id>"
az provider register --namespace Microsoft.ApiManagement --wait

resourceGroup="aigateway-rg"
gatewayLocation="<aigateway-preview-region>"

az group create --name "$resourceGroup" --location "$gatewayLocation"
az deployment group create \
  --name aigateway \
  --resource-group "$resourceGroup" \
  --template-file main.bicep \
  --parameters azuredeploy.parameters.json \
  --parameters gatewayLocation="$gatewayLocation"
```

This deploys a gateway without a backend. Add model routing before sending model requests. Deployment outputs include the gateway, workspace, and runtime API key resource IDs and the gateway managed identity's principal ID.

## Route two existing model deployments through an alias

Save the following as `azuredeploy.parameters.local.json`, replacing the account and deployment details with your existing resources. Run the deployment in the resource group that contains that account.

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "backend": {
      "value": {
        "accountName": "your-existing-azure-openai-account",
        "aliasName": "chat",
        "models": [
          {
            "name": "chat-primary",
            "deploymentName": "your-first-deployment",
            "modelName": "gpt-4o",
            "modelVersion": "2024-08-06",
            "priority": 0,
            "weight": 70
          },
          {
            "name": "chat-secondary",
            "deploymentName": "your-second-deployment",
            "modelName": "gpt-4o-mini",
            "modelVersion": "2024-07-18",
            "priority": 0,
            "weight": 30
          }
        ]
      }
    },
    "aliasTokenLimit": {
      "value": 10000
    },
    "enableMonitoring": {
      "value": true
    }
  }
}
```

```bash
resourceGroup="<existing-azure-openai-resource-group>"
gatewayLocation="<aigateway-preview-region>"

az deployment group create \
  --name aigateway \
  --resource-group "$resourceGroup" \
  --template-file main.bicep \
  --parameters azuredeploy.parameters.local.json \
  --parameters gatewayLocation="$gatewayLocation"
```

Clients use `chat` as the model name. Both routes have priority `0`, so their relative weights express a 70:30 routing preference; observed distribution varies with traffic and backend availability. For primary/fallback routing instead, set the second route's priority to `1`. Lower priority values are preferred, and weights select among routes at the same priority. Model registration names must be unique within the provider.

The alias limits each identity to 10,000 tokens per minute by default. Role assignments can take time to propagate before the first model request succeeds. Retrieve runtime credentials through an authorized key-management operation or the gateway's management experience; do not copy them into templates, source control, or deployment outputs.

Changing a model registration or alias name does not remove the old resource during an incremental deployment. Likewise, disabling monitoring or removing `backend` does not delete previously deployed resources or revoke previous role assignments; remove them explicitly when retiring a configuration.

## Parameters

| Parameter | Purpose | Default |
| --- | --- | --- |
| `gatewayName` | Gateway name, 3-24 characters. | A deterministic name based on the resource group. |
| `location` | Monitoring resource region. | Resource group location. |
| `gatewayLocation` | Region with AI Gateway preview access. | `location`. |
| `backend` | Existing account, alias name, and model deployment configurations. | `null` (no backend). |
| `aliasTokenLimit` | Tokens per identity per minute on the alias. | `10000`. |
| `enableMonitoring` | Create monitoring resources and a payload-free exporter. | `false`. |
| `tags` | Resource tags. | `{}`. |

## References

- [Azure API Management documentation](https://learn.microsoft.com/azure/api-management/)
- [Azure OpenAI role-based access control](https://learn.microsoft.com/azure/ai-foundry/openai/how-to/role-based-access-control)
- [Deploy Bicep with the Azure CLI](https://learn.microsoft.com/azure/azure-resource-manager/bicep/deploy-cli)

`Tags: Microsoft.ApiManagement/aigateways, Microsoft.ApiManagement/aigateways/workspaces/modelProviders, Microsoft.ApiManagement/aigateways/workspaces/modelProviders/models, Microsoft.ApiManagement/aigateways/workspaces/aliases, Microsoft.ApiManagement/aigateways/apiKeys, Microsoft.ApiManagement/aigateways/workspaces/telemetryExporters, Microsoft.Authorization/roleAssignments, Microsoft.OperationalInsights/workspaces, Microsoft.Insights/components, SystemAssigned`
