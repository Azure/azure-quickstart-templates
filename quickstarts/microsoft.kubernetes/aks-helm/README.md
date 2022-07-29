---
description: Deploy a managed cluster with Azure Container Service (AKS) with Helm
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: aks-helm
languages:
- json
- bicep
---
# Azure Container Service (AKS) with Helm

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-helm/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-helm/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-helm/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-helm/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-helm/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-helm/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.kubernetes/aks-helm/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kubernetes%2Faks-helm%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kubernetes%2Faks-helm%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.kubernetes%2Faks-helm%2Fazuredeploy.json)

## Deployment

This template deploys an **AKS cluster**. To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/aks/kubernetes-walkthrough-rm-template) article.

For information about how to deploy an AKS cluster using Azure CLI, see the [quickstart](https://docs.microsoft.com/azure/aks/kubernetes-walkthrough) article.

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
