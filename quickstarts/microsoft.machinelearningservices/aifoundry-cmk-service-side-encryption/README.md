---
description: This set of templates demonstrates how to set up Azure AI Foundry with the basic setup, meaning with public internet access enabled, Microsoft-managed keys for encryption and Microsoft-managed identity configuration for the AI resource.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: aifoundry-cmk-service-side-encryption
languages:
- bicep
- json
---
# Azure AI Foundry basic setup

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aifoundry-cmk-service-side-encryption/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aifoundry-cmk-service-side-encryption/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aifoundry-cmk-service-side-encryption/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aifoundry-cmk-service-side-encryption/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aifoundry-cmk-service-side-encryption/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aifoundry-cmk-service-side-encryption/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.machinelearningservices/aifoundry-cmk-service-side-encryption/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.machinelearningservices%2Faifoundry-cmk-service-side-encryption%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.machinelearningservices%2Faifoundry-cmk-service-side-encryption%2Fazuredeploy.json)

This set of templates demonstrates how to create a hub workspace with customer-managed keys for encryption, and its data stored service-side. In this setup, public internet access is enabled, and _Microsoft_-managed identity is used. This preview capability overcomes the previous requirement for creating additional Azure Storage, Azure CosmosDB and Azure Search resources in your subscription when using customer-managed key encryption.

> [!IMPORTANT]
> This preview is provided without a service-level agreement, and we don't recommend it for production workloads. 
> Certain features might not be supported or might have constrained capabilities. 

This configuration describes the set of resources required to:

1. (prerequisite) Create and configure an Azure Key vault resource to host an encryption key for Azure Machine Learning.
1. Create an Azure Machine Learning workspace of kind 'hub' and dependent resources, and then configure it for encryption with the above encryption key.

> [!NOTE]
> Previously, when using a customer-managed key, Azure Machine Learning creates a secondary resource group in your 
> subscription which contains additonal resources. With this preview, this is no longer needed and all service metadata
> will be encrypted service-side. This preview does not support Azure Key Vault that have public network access set as 'Disabled'.


**Preview:** 

Azure AI Foundry is built on Azure Machine Learning as the primary resource provider and takes a dependency on the Cognitive Services (Azure AI Services) resource provider to surface model endpoints for Azure Speech, Azure Content Safety, And Azure OpenAI service.

An 'Azure AI hub' is a special kind of 'Azure Machine Learning workspace', that is of kind = "hub".

For AI services CMK configuration the following constraints hold on your encryption key:
- The selected key must be an RSA (Supported JSON Web Key Types are ['RSA', 'RSA-HSM']) 2048 bit key.
- No other key-size/asymmetric key-type is supported.
- Only Azure Key vault 'access policies' permission model is supported, not Azure RBAC.
- Encryption cannot be enforced on AI services at first template execution if AI services does not yet exist, because the system-assigned managed identity that will be created will need to be granted access to your key vault.
- Assign wrap/unwrap permissions on the AI services managed identity after creation. Then uncomment the encryption settings to enable encryption for AI services.

## Resources

| Provider and type | Description |
| - | - |
| `Microsoft.Resources/resourceGroups` | The resource group all resources get deployed into |
| `Microsoft.Insights/components` | An Azure Application Insights instance associated to the Azure Machine Learning workspace |
| `Microsoft.KeyVault/vaults` | An Azure Key Vault instance associated to the Azure Machine Learning workspace |
| `Microsoft.Storage/storageAccounts` | An Azure Storage instance associated to the Azure Machine Learning workspace |
| `Microsoft.ContainerRegistry/registries` | An Azure Container Registry instance associated to the Azure Machine Learning workspace |
| `Microsoft.MachineLearningServices/workspaces` | An Azure AI hub (Azure Machine Learning RP workspace of kind 'hub') |
| `Microsoft.CognitiveServices/accounts` | An Azure AI Services as the model-as-a-service endpoint provider (allowed kinds: 'AIServices' and 'OpenAI') |

## Learn more

If you are new to Azure AI Foundry, see:

- [Azure AI Foundry](https://learn.microsoft.com/azure/ai-foundry)
- [AI Foundry architecture](https://learn.microsoft.com/en-us/azure/ai-foundry/concepts/architecture)
- [Customer-managed key encryption for Azure AI Foundry](https://learn.microsoft.com/en-us/azure/ai-services/encryption/cognitive-services-encryption-keys-portal?context=%2Fazure%2Fai-foundry%2Fcontext%2Fcontext)

`Tags: `