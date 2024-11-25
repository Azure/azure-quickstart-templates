---
description: This set of templates demonstrates how to set up Azure AI Agent Service with the standard setup, meaning with managed identity authetication, public internet access enabled. Agents use customer-owned, single-tenant search and storage resources. With this setup, you have full control and visibility over these resources, but you will incur costs based on your usage. 

page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: aistudio-basics
languages:
- bicep
- json
---
# Standard Agent Setup

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azure-ai-agent-service/standard-agent/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azure-ai-agent-service/standard-agent/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azure-ai-agent-service/standard-agent/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azure-ai-agent-service/standard-agent/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azure-ai-agent-service/standard-agent/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azure-ai-agent-service/standard-agent/CredScanResult.svg)

Resources for the hub, project, storage account, key vault, AI Services, and Azure AI Search will be created for you. The AI Services, AI Search, and Azure Blob Storage account will be connected to your project/hub and a gpt-4o-mini model will be deployed in the eastus region.

## Resources

| Provider and type | Description |
| - | - |
| `Microsoft.Resources/resourceGroups` | The resource group all resources get deployed into |
| `Microsoft.KeyVault/vaults` | An Azure Key Vault instance associated to the Azure Machine Learning workspace |
| `Microsoft.Storage/storageAccounts` | An Azure Storage instance associated to the Azure Machine Learning workspace |
| `Microsoft.MachineLearningServices/workspaces` | An Azure AI hub (Azure Machine Learning RP workspace of kind 'hub') |
| `Microsoft.MachineLearningServices/workspaces` | An Azure AI project (Azure Machine Learning RP workspace of kind 'project') |
| `Microsoft.CognitiveServices/accounts` | An Azure AI Services as the model-as-a-service endpoint provider (allowed kinds: 'AIServices' and 'OpenAI') |
| `Microsoft.CognitiveServices/accounts/deployments` | A gpt-4o-mini model is deployed |
| `Microsoft.Search/searchServices` | An Azure AI Search account  |
