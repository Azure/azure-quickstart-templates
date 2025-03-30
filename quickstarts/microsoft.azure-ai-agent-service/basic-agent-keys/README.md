---
description: This set of templates demonstrates how to set up Azure AI Agent Service with the basic setup using API keys authetication for the AI Service/AOAI connection. Agents use multi-tenant search and storage resources fully managed by Microsoft. You won’t have visibility or control over these underlying Azure resources.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: basic-agent-keys
languages:
- bicep
- json
---
# Basic Agent Setup API Keys

> [!IMPORTANT]
> All Agent templates in this repository are out of date and have been moved. [Please visit the updated repository.](https://github.com/Azure-Samples/azureai-samples/tree/main/scenarios/Agents/setup/basic-agent-keys)

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azure-ai-agent-service/basic-agent-keys/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azure-ai-agent-service/basic-agent-keys/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azure-ai-agent-service/basic-agent-keys/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azure-ai-agent-service/basic-agent-keys/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azure-ai-agent-service/basic-agent-keys/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azure-ai-agent-service/basic-agent-keys/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azure-ai-agent-service/basic-agent-keys/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azure-ai-agent-service%2Fbasic-agent-keys%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azure-ai-agent-service%2Fbasic-agent-keys%2Fazuredeploy.json)   

Resources for the hub, project, storage account, and AI Services will be created for you. The AI Services account will be connected to your project/hub and a gpt-4o-mini model will be deployed in the eastus region. A Microsoft-managed key vault will be used by default. 
## Resources

| Provider and type | Description |
| - | - |
| `Microsoft.Resources/resourceGroups` | The resource group all resources get deployed into |
| `Microsoft.Storage/storageAccounts` | An Azure Storage instance associated to the Azure Machine Learning workspace |
| `Microsoft.MachineLearningServices/workspaces` | An Azure AI hub (Azure Machine Learning RP workspace of kind 'hub') |
| `Microsoft.MachineLearningServices/workspaces` | An Azure AI project (Azure Machine Learning RP workspace of kind 'project') |
| `Microsoft.CognitiveServices/accounts` | An Azure AI Services as the model-as-a-service endpoint provider (allowed kinds: 'AIServices' and 'OpenAI') |
| `Microsoft.CognitiveServices/accounts/deployments` | A gpt-4o-mini model is deployed |`Tags: `
