---
description: Deploy a Azure Linux with OS Guard cluster on Azure Container Service (AKS) 
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: aks
languages:
- bicep
- json
---
# Azure Linux with OS Guard

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-azure-linux-os-guard/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-azure-linux-os-guard/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-azure-linux-os-guard/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-azure-linux-os-guard/FairfaxDeployment.svg)
![GovLastTestDate](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-azure-linux-os-guard/FairfaxLastTestDate.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-azure-linux-os-guard/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-azure-linux-os-guard/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-azure-linux-os-guard/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kubernetes%2Faks-azure-linux-os-guard%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kubernetes%2Faks-azure-linux-os-guard%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kubernetes%2Faks-azure-linux-os-guard%2Fazuredeploy.json)


## Deployment

This template deploys an **Azure Linux with OS Guard AKS cluster**. To learn more about how to deploy the template, see the [quickstart](https://learn.microsoft.com/en-us/azure/azure-linux/quickstart-os-guard-arm-template) article.

For information about how to deploy an AKS cluster using Azure CLI, see the [quickstart](https://learn.microsoft.com/en-us/azure/azure-linux/quickstart-os-guard-azure-cli) article.

## Keys

To use keys stored in `keyVault`, replace `"value":""` with a reference to `keyVault` in the parameters file. For example:

```json
"servicePrincipalClientSecret": {
  "reference": {
    "keyVault": {
      "id": "<specify Resource ID of the Key Vault you are using>"
    },
    "secretName": "<specify name of the secret in the Key Vault to get the service principal password from>"
  }
}
```

`Tags: Microsoft.ContainerService/managedClusters, SystemAssigned`
