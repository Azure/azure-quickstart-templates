# Create a Machine Learning Workspace

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/machine-learning-workspace/0.9/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/machine-learning-workspace/0.9/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/machine-learning-workspace/0.9/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/machine-learning-workspace/0.9/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/machine-learning-workspace/0.9/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/machine-learning-workspace/0.9/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2Fmachine-learning-workspace%2F0.9%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2Fmachine-learning-workspace%2F0.9%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2Fmachine-learning-workspace%2F0.9%2Fazuredeploy.json)

This module creates a new Azure Machine Learning Workspace, along with an encrypted Storage Account, KeyVault and Applications Insights Logging.

It is a simple module for creating a generic ML instance.

## Parameters

| Name | Type | Required | Description |
| :------------- | :----------: | :----------: | :------------- |
| workspaceName | string | No | Specifies the name of the Azure Machine Learning workspace.|
| storageAccountName | string | No | The name for the storage account to created and associated with the workspace.|
| keyVaultName | string | No | The name for the key vault to created and associated with the workspace.|
| applicationInsightsName | string | No | The name for the application insights to created and associated with the workspace.|
| location | string | No | Specifies the location for all resources.|

## Outputs

| Name | Type | Description |
| :------------- | :----------: | :------------- |
| workspaceName | string | Specifies the name of the Azure Machine Learning workspace.|
| storageAccountName | string | The name for the storage account to created and associated with the workspace.|
| keyVaultName | string | The name for the key vault to created and associated with the workspace.|
| applicationInsightsName | string | The name for the application insights to created and associated with the workspace.|
| location | string | Specifies the location for all resources.|

```apiVersion: n/a```
