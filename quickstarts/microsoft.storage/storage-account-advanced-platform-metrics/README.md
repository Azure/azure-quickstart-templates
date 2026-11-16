---
description: Deploy a standard StorageV2 account with advanced platform metrics enabled for all blob containers.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: storage-account-advanced-platform-metrics
languages:
- bicep
- json
---
# Storage account with advanced platform metrics

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storage/storage-account-advanced-platform-metrics/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storage/storage-account-advanced-platform-metrics/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storage/storage-account-advanced-platform-metrics/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storage/storage-account-advanced-platform-metrics/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storage/storage-account-advanced-platform-metrics/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storage/storage-account-advanced-platform-metrics/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storage/storage-account-advanced-platform-metrics/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.storage%2Fstorage-account-advanced-platform-metrics%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.storage%2Fstorage-account-advanced-platform-metrics%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.storage%2Fstorage-account-advanced-platform-metrics%2Fazuredeploy.json)

This template deploys a **standard StorageV2 account** with **advanced platform metrics** enabled for all blob containers. It configures the `ContainerLevelCapacityMetrics` rule with `AllContainersFilter`, so individual container names do not need to be supplied.

## Sample overview and deployed resources

- **Microsoft.Storage/storageAccounts**: A general-purpose v2 storage account with the Hot access tier, HTTPS-only access, a minimum TLS version of 1.2, and anonymous blob access disabled.
- **Microsoft.Storage/storageAccounts/advancedPlatformMetrics**: The `ContainerLevelCapacityMetrics` child resource, enabled with an all-container filter.

The template does not create containers or upload data. The all-container rule also applies to containers created after deployment. An empty `filterValues` array represents the all-container selection, as specified in the [resource reference](https://learn.microsoft.com/azure/templates/microsoft.storage/2026-09-01/storageaccounts/advancedplatformmetrics).

## Prerequisites

- An Azure subscription and permission to deploy storage accounts and their advanced platform metrics child resources into an existing resource group.
- A region and standard storage SKU that support advanced platform metrics with API version `2026-09-01`.
- Azure CLI for command-line deployment. Bicep is required only when deploying or rebuilding the Bicep source.

This sample targets Azure public cloud (`AzureCloud`). The Azure Government button follows the repository README convention; confirm feature and API availability in that cloud before using it.

## Deployment steps

Use the **Deploy to Azure** button above after the sample has been merged, or deploy the Bicep source with Azure CLI. From this sample's directory, run:

```azurecli
az group create --name rg-storage-advanced-metrics --location westeurope
az deployment group create --resource-group rg-storage-advanced-metrics --name storage-advanced-metrics --template-file main.bicep --parameters @azuredeploy.parameters.json
```

The template defaults to the resource group's location, `Standard_LRS`, and a storage account name derived from the resource group ID. Optional parameters are `storageAccountName`, `location`, and `storageAccountSku`. Custom account names must contain 3-24 lowercase letters and numbers and be globally unique.

The SKU choices intentionally cover only standard StorageV2 redundancy options; premium account scenarios are outside this sample's scope.

Both [main.bicep](main.bicep) and its generated ARM template, [azuredeploy.json](azuredeploy.json), are included. To deploy the JSON template instead, replace `--template-file main.bicep` with `--template-file azuredeploy.json` in the command above.

After changing the Bicep source, regenerate the JSON template to keep both formats synchronized:

```azurecli
az bicep build --file main.bicep --outfile azuredeploy.json
```

## Usage

The deployment returns `storageAccountName`, `storageAccountId`, and `storageAccountBlobEndpoint`. The blob endpoint is read from the deployed account rather than constructed with a cloud-specific DNS suffix.

To confirm the metrics configuration, retrieve the deployed account ID and read the child resource:

```powershell
$storageAccountId = az deployment group show --resource-group rg-storage-advanced-metrics --name storage-advanced-metrics --query properties.outputs.storageAccountId.value --output tsv
az rest --method get --url "https://management.azure.com${storageAccountId}/advancedPlatformMetrics/ContainerLevelCapacityMetrics?api-version=2026-09-01" --query properties
```

The response should contain `enabled: true`, `ruleConfig.filterType: AllContainersFilter`, and an empty `ruleConfig.filterValues` array. Enabling the rule does not imply that metric data is immediately available; create containers and upload data separately to evaluate container-level capacity metrics.

## Notes

- Storage and monitoring charges may apply. Review [Azure Storage pricing](https://azure.microsoft.com/pricing/details/storage/blobs/) and [Azure Monitor pricing](https://azure.microsoft.com/pricing/details/monitor/) before deploying.
- Delete the test resource group when finished if it contains only resources created for this sample:

  ```azurecli
  az group delete --name rg-storage-advanced-metrics
  ```

`Tags: Microsoft.Storage/storageAccounts, Microsoft.Storage/storageAccounts/advancedPlatformMetrics, StorageV2, blob, monitoring, advanced platform metrics, container capacity, bicep`
