---
description: This set of templates demonstrates how to set up Azure AI Agent Service with the standard setup and bing, meaning with managed identity authentication of each project connection and public internet access enabled. The bing project connection uses api keys for authentication. Agents use customer-owned, single-tenant search and storage resources. With this setup, you have full control and visibility over these resources, but you will incur costs based on your usage.
page_type: sample
products:
- azure
- azure-resource-manager
- azure-ai-agent-service
urlFragment: standard-agent-bing
languages:
- bicep
- json
---
# Standard Agent Setup with Bing

Resources for the hub, project, storage account, key vault, AI Services, and Azure AI Search will be created for you. The AI Services, AI Search, and Azure Blob Storage account will be connected to your project/hub using managed identity for authentication and a gpt-4o-mini model will be deployed in the eastus region. A bing resource will be created and connected to your hub/project using an api key for authentication.

Optional use an existing AI Services, AI Search, Azure Blob Storage, and/or Bing resource by providing the full arm resource id in the parameters file:

- aiServiceAccountResourceId
- aiSearchServiceResourceId
- aiStorageAccountResourceId
- bingSearchResourceID

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
| `Microsoft.Bing/accounts` | A Bing Resource |
