---
description: Deploy an Azure Container Linux cluster on Azure Kubernetes Service (AKS)
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: aks
languages:
- bicep
- json
---
# Azure Container Linux on AKS

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-azure-container-linux/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-azure-container-linux/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-azure-container-linux/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-azure-container-linux/FairfaxDeployment.svg)
![GovLastTestDate](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-azure-container-linux/FairfaxLastTestDate.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-azure-container-linux/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-azure-container-linux/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-azure-container-linux/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kubernetes%2Faks-azure-container-linux%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kubernetes%2Faks-azure-container-linux%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kubernetes%2Faks-azure-container-linux%2Fazuredeploy.json)

## Deployment

This template deploys an **Azure Container Linux AKS cluster**.

It creates an AKS managed cluster with:
- system-assigned managed identity
- a system node pool using `AzureContainerLinux`
- configurable node count, VM size, and OS disk size
- Linux admin username and SSH public key configuration

## Keys

To use keys stored in `keyVault`, replace `"value": ""` with a reference to `keyVault` in the parameters file. For example:

```json
"sshRSAPublicKey": {
  "reference": {
    "keyVault": {
      "id": "<specify Resource ID of the Key Vault you are using>"
    },
    "secretName": "<specify name of the secret in the Key Vault to get the SSH public key from>"
  }
}
```

`Tags: Microsoft.ContainerService/managedClusters, SystemAssigned`
