---
description: Deploy a private Azure Storage account with optional Azure Enclave workload association.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: azure-enclave-storage-account
languages:
- bicep
- json
---
# Deploy a private Storage account for an Azure Enclave workload

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/azure-enclave-storage-account/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/azure-enclave-storage-account/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/azure-enclave-storage-account/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/azure-enclave-storage-account/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/azure-enclave-storage-account/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/azure-enclave-storage-account/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/azure-enclave-storage-account/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.mission%2Fenclave-storage-account%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.mission%2Fenclave-storage-account%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.mission%2Fazure-enclave-storage-account%2Fazuredeploy.json)

This subscription-scope template deploys a private Azure Storage account with private endpoints (blob, file, queue, table, and optional dfs) and customer-managed key encryption. The portal flow can associate deployment with an Azure Enclave workload, and the template also supports deployment without an enclave.

## Resources and configuration

- Azure Storage account with public network access disabled and HTTPS-only access.
- Private endpoints for blob, file, queue, table, and optional dfs services.
- Optional private DNS zone registration for each private endpoint.
- Customer-managed key encryption through Key Vault and a user-assigned managed identity.
- Optional workload association with an Azure Enclave virtual enclave.
- Optional anonymous deployment telemetry. Telemetry is disabled for MSISR tenants.

## Prerequisites

- Permissions to run subscription-scope deployments and create resource groups/resources.
- An existing virtual network and subnet for private endpoints.
- A Key Vault key and user-assigned managed identity with access to use the key, or permission to create them through the template flow.
- For enclave-associated deployment paths, permission to read/update the selected Azure Enclave resources.

## Deploy with Azure CLI

From this sample directory:

```azurecli
az deployment sub create \
  --name azure-enclave-storage-account \
  --location eastus \
  --template-file main.bicep \
  --parameters @azuredeploy.parameters.json
```

## Deploy with Azure PowerShell

From this sample directory:

```powershell
New-AzSubscriptionDeployment `
  -Name 'azure-enclave-storage-account' `
  -Location 'eastus' `
  -TemplateFile '.\main.bicep' `
  -TemplateParameterFile '.\azuredeploy.parameters.json'
```

`Tags: Azure Enclave, Microsoft.Mission, Storage Account, private endpoint, private DNS, customer-managed key, Bicep`
