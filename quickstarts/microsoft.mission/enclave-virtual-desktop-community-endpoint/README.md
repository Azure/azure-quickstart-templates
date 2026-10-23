---
description: Deploy an Azure Virtual Desktop community endpoint for an existing Azure Enclave community.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: enclave-virtual-desktop-community-endpoint
languages:
- bicep
- json
---
# Deploy an Azure Virtual Desktop community endpoint for Azure Enclave

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/enclave-virtual-desktop-community-endpoint/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/enclave-virtual-desktop-community-endpoint/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/enclave-virtual-desktop-community-endpoint/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/enclave-virtual-desktop-community-endpoint/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/enclave-virtual-desktop-community-endpoint/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/enclave-virtual-desktop-community-endpoint/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.mission/enclave-virtual-desktop-community-endpoint/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.mission%2Fenclave-virtual-desktop-community-endpoint%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.mission%2Fenclave-virtual-desktop-community-endpoint%2FcreateUiDefinition.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.mission%2Fenclave-virtual-desktop-community-endpoint%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.mission%2Fenclave-virtual-desktop-community-endpoint%2FcreateUiDefinition.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.mission%2Fenclave-virtual-desktop-community-endpoint%2Fazuredeploy.json)

This subscription-scope sample deploys a `Microsoft.Mission/communities/communityEndpoints` resource into an existing Azure Enclave community for Azure Virtual Desktop connectivity.

It also supports optional anonymous deployment telemetry; telemetry is skipped for MSISR tenants.

## Prerequisites

- An existing Azure Enclave community (`Microsoft.Mission/communities`) in the target subscription.
- Permissions to run subscription-scope deployments and to write resources in the community resource group.

## Deploy with Azure CLI

From this sample directory:

```azurecli
az deployment sub create \
  --name azure-enclave-avd-community-endpoint \
  --location eastus \
  --template-file main.bicep \
  --parameters @azuredeploy.parameters.json
```

## Deploy with Azure PowerShell

From this sample directory:

```powershell
New-AzSubscriptionDeployment `
  -Name 'azure-enclave-avd-community-endpoint' `
  -Location 'eastus' `
  -TemplateFile '.\main.bicep' `
  -TemplateParameterFile '.\azuredeploy.parameters.json'
```

`Tags: Azure Enclave, Microsoft.Mission, Azure Virtual Desktop, community endpoint, Bicep`
