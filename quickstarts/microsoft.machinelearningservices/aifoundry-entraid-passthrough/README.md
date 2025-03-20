---
description: This set of templates demonstrates how to set up Azure AI Foundry with Microsoft Entra ID authentication for dependent resources, such as Azure AI Services and Azure Storage.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: aifoundry-entraid-passthrough
languages:
- bicep
- json
---
# Azure AI Foundry with Microsoft Entra ID Authentication

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aifoundry-entraid-passthrough/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aifoundry-entraid-passthrough/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aifoundry-entraid-passthrough/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aifoundry-entraid-passthrough/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aifoundry-entraid-passthrough/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aifoundry-entraid-passthrough/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aifoundry-entraid-passthrough/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.machinelearningservices%2Faifoundry-entraid-passthrough%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.machinelearningservices%2Faifoundry-entraid-passthrough%2Fazuredeploy.json)

This set of templates demonstrates how to set up Azure AI Foundry with Microsoft Entra ID authentication for dependent resources, such as Azure AI Service and Azure Storage. This example shows public internet access enabled, Microsoft-managed keys for encryption and _Microsoft_-managed identity configuration for the Azure AI Hub resource.

Azure AI Foundry is built on Azure Machine Learning as the primary resource provider and takes a dependency on the Azure AI Services resource provider to surface model-as-a-service endpoints for all Azure AI capabilities including Azure OpenAI service, Azure Content Safety, Azure AI Document Intelligence, and Azure Speech.

An 'Azure AI Hub' is a special kind of 'Azure Machine Learning workspace', that is kind = "hub".

## Resources

| Provider and type                              | Description                                                                                                 |
| ---------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `Microsoft.Resources/resourceGroups`           | The resource group all resources get deployed into                                                          |
| `Microsoft.Insights/components`                | An Azure Application Insights instance associated to the Azure Machine Learning workspace                   |
| `Microsoft.KeyVault/vaults`                    | An Azure Key Vault instance associated to the Azure Machine Learning workspace                              |
| `Microsoft.Storage/storageAccounts`            | An Azure Storage instance associated to the Azure Machine Learning workspace                                |
| `Microsoft.ContainerRegistry/registries`       | An Azure Container Registry instance associated to the Azure Machine Learning workspace                     |
| `Microsoft.MachineLearningServices/workspaces` | An Azure AI Hub (Azure Machine Learning RP workspace of kind 'hub')                                         |
| `Microsoft.CognitiveServices/accounts`         | An Azure AI Services as the model-as-a-service endpoint provider (allowed kinds: 'AIServices' and 'OpenAI') |

When assigning the `userObjectId` parameter for a Microsoft Entra ID user, the following Azure role assignments are made:

- `Microsoft.Storage/storageAccounts`:
  - [Storage Account Contributor](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/storage#storage-account-contributor)
  - [Storage Blob Data Contributor](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/storage#storage-blob-data-contributor)
  - [Storage File Data Privileged Contributor](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/storage#storage-file-data-privileged-contributor)
  - [Storage Table Data Contributor](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/storage#storage-table-data-contributor)
- `Microsoft.MachineLearningServices/workspaces`:
  - [AzureML Data Scientist](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/ai-machine-learning#azureml-data-scientist)
- `Microsoft.CognitiveServices/accounts`:
  - [Azure AI Developer](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/ai-machine-learning#azure-ai-developer)

## Learn more

If you are new to Azure AI Foundry, see:

- [Azure AI Foundry](https://aka.ms/aistudio/docs)

`Tags: Microsoft.MachineLearningServices/workspaces, Microsoft.CognitiveServices/accounts, Microsoft.Storage/storageAccounts, Microsoft.KeyVault/vaults, Microsoft.Insights/components, Microsoft.ContainerRegistry/registries, SystemAssigned`
