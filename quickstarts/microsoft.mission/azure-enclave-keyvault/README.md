---
description: Deploy a private Azure Key Vault with optional Azure Enclave workload association.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: azure-enclave-keyvault
languages:
- bicep
- json
---
# Deploy a private Key Vault for an Azure Enclave workload

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/azure-enclave-keyvault/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/azure-enclave-keyvault/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/azure-enclave-keyvault/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/azure-enclave-keyvault/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/azure-enclave-keyvault/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/azure-enclave-keyvault/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/azure-enclave-keyvault/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.mission%2Fazure-enclave-keyvault%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.mission%2Fazure-enclave-keyvault%2Fazuredeploy.json)

This subscription-scope template deploys a private Azure Key Vault into an existing or new resource group. The portal experience can associate the deployment with an Azure Enclave workload, but the template also supports deployment without an enclave. This sample supports Azure Public and Azure US Government.

## Resources and configuration

The template deploys or configures the following resources:

- An Azure Key Vault with RBAC authorization, soft delete, disabled public network access, and optional purge protection.
- A private endpoint for the Key Vault in an existing virtual network and subnet in the deployment subscription.
- Zero or more optional RSA, RSA-HSM, EC, or EC-HSM keys. Keys receive a one-year expiry and an automatic rotation action 30 days after creation.
- Optional private DNS registration. You can omit DNS registration, select an existing private DNS zone, or create and link a `privatelink.vaultcore.azure.net` zone.
- Optional Key Vault diagnostic settings that send audit logs, policy evaluation details, and metrics to a Log Analytics workspace.
- Optional Azure Enclave workload configuration. The deployment can use an existing workload or create a workload, and it can add a new workload resource group to the workload's resource group collection.
- Optional anonymous deployment telemetry. When enabled, the template creates an empty nested deployment whose name identifies the sample version. Telemetry is disabled when `enableTelemetry` is `false` or `isMsisrTenant` is `true`.

## Portal discovery behavior

The portal form performs discovery before deployment. It enumerates the subscriptions that the signed-in user can access and lets the user select one. It then sends an Azure Resource Graph query scoped to that selected subscription for resources of type `Microsoft.Mission/virtualEnclaves`.

After the user selects an enclave, the form retrieves that enclave, discovers its workloads, and retrieves the selected workload's associated resource group collection. The form also selects the enclave virtual network from the enclave resource collection. These discovery operations are implemented by `createUiDefinition.json`; `main.bicep` does not scan subscriptions or run Resource Graph queries. The Bicep template receives the selected resource IDs and names as deployment parameters.

Users can select **No enclave** to skip Azure Enclave workload creation and association. In that path, the form lets the user select an existing resource group or provide a name for a new resource group in the selected subscription.

## Prerequisites

- Permissions to create a subscription-scope deployment and the selected resources. Creating a resource group requires permission to write resource groups at subscription scope.
- An existing virtual network and nondelegated subnet in the selected subscription for the Key Vault private endpoint.
- For portal auto-discovery, permission to list accessible subscriptions, query Azure Resource Graph, and read the selected `Microsoft.Mission/virtualEnclaves` resource and its workloads.
- When associating a new resource group with an Azure Enclave workload, permission to update the workload and create or use the resource group.
- If an enclave deny assignment blocks workload or resource deployment changes, put the enclave in maintenance mode before deployment and exit maintenance mode after the deployment completes. This caveat does not apply to the **No enclave** path.
- A Log Analytics workspace when diagnostics are enabled.
- An existing `privatelink.vaultcore.azure.net` private DNS zone when the existing-zone option is selected.

## Deploy with Azure CLI

From this sample directory, sign in, select the target subscription, replace the generated values in `azuredeploy.parameters.json`, and run:

```azurecli
az deployment sub create \
  --name azure-enclave-keyvault \
  --location eastus \
  --template-file main.bicep \
  --parameters @azuredeploy.parameters.json
```

The deployment location stores subscription deployment metadata. The template deploys the Key Vault in the location supplied through the template parameters.

## Deploy with Azure PowerShell

From this sample directory, connect to Azure, select the target subscription, replace the generated values in `azuredeploy.parameters.json`, and run:

```powershell
New-AzSubscriptionDeployment `
  -Name 'azure-enclave-keyvault' `
  -Location 'eastus' `
  -TemplateFile '.\main.bicep' `
  -TemplateParameterFile '.\azuredeploy.parameters.json'
```

## Deploy with the repository script

The repository's `Deploy-AzTemplate.ps1` script compiles `main.bicep` to `main.json` locally and detects the compiled template's subscription scope. From the repository root, run:

```powershell
.\Deploy-AzTemplate.ps1 `
  -ArtifactStagingDirectory '.\quickstarts\microsoft.mission\azure-enclave-keyvault' `
  -Location 'eastus' `
  -bicep
```

The script requires the Az PowerShell modules listed in the script and the Bicep CLI. The repository's resource-group-only Bash helper is not suitable for this subscription-scope template.

`Tags: Azure Enclave, Microsoft.Mission, Key Vault, private endpoint, private DNS, diagnostics, Bicep`