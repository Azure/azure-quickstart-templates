---
description: Deploys a Microsoft Foundry account with a default project and a model deployment - the recommended starting point for building agents and applications with large language models on Azure.
page_type: sample
products:
- azure
- azure-resource-manager
- azure-ai-foundry
urlFragment: foundry-getting-started
languages:
- bicep
- json
---
# Deploy a Microsoft Foundry account (basic)

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/foundry-getting-started/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/foundry-getting-started/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/foundry-getting-started/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/foundry-getting-started/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/foundry-getting-started/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/foundry-getting-started/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/foundry-getting-started/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cognitiveservices%2Ffoundry-getting-started%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cognitiveservices%2Ffoundry-getting-started%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cognitiveservices%2Ffoundry-getting-started%2Fazuredeploy.json)

## Microsoft Foundry as a service

Microsoft Foundry is Azure's unified platform for building, evaluating, and operating AI agents and applications. As an agent developer platform it lets you:

- **Build with large language models from many providers** - choose from a broad model catalog (OpenAI, Meta, Mistral, Black Forest Labs, and more) through a single account and endpoint.
- **Build and evaluate agents** - create agents, run evaluations, and use tracing and observability to measure and improve quality.
- **Integrate with tools** - connect agents to external tools and data as well as first-party Microsoft tools such as Azure AI Search and Bing.

> **Microsoft Foundry is the successor to several previously standalone Azure services** and includes their capabilities, among them the multi-service Azure AI services (`CognitiveServices` kind, also known as the "universal key" resource), **Azure OpenAI**, **Azure Speech**, and **Azure Language**. For any new workload, provisioning a Foundry account (`Microsoft.CognitiveServices/accounts` with kind `AIServices`) is **strongly recommended** over those standalone resource types. Foundry gives you the latest model releases and capabilities plus developer scenarios that span across all of these services from one account.

## What this template deploys

This template deploys a complete, working starting point for Microsoft Foundry - a Foundry account with its default project.

> **The account and the project play different roles.** The **account** is where common, security-sensitive settings live - networking, compute, and customer-managed key encryption - and these apply to everything inside it. A **project** is a more lightweight organizational folder: every account has one default project and more can be added, each acting as a folder that organizes a piece of work and isolates its state from other projects. A project can have its own RBAC and identity, but it inherits the account's security settings rather than defining its own.

| Resource | Purpose |
| --- | --- |
| `Microsoft.CognitiveServices/accounts` (kind `AIServices`) | The Microsoft Foundry account. Holds the account-wide security settings (networking, compute, customer-managed key encryption) and surfaces model-as-a-service endpoints and Foundry capabilities such as agents, evaluations, and tracing. |
| `Microsoft.CognitiveServices/accounts/projects` | The default project - every account has one, and you can add more. A lightweight folder that organizes a use case, isolates its state, and can hold its own identity and RBAC while inheriting the account's security settings. |
| `Microsoft.CognitiveServices/accounts/deployments` | A model deployment (`gpt-4.1-mini` by default) so you can start using the playground, agents, and other tools immediately. |

## Parameters

| Parameter | Description |
| --- | --- |
| `foundryName` | Name of the Foundry account; also used as the developer API subdomain. |
| `projectName` | Name of the default project. |
| `location` | Location for all resources. Defaults to the resource group location. |
| `modelDeploymentName` | Name of the model deployment. |
| `modelName` / `modelFormat` / `modelVersion` | Model to deploy from the catalog. Defaults to `gpt-4.1-mini` (`OpenAI`, `2025-04-14`). |
| `modelCapacity` | Capacity (in thousands of tokens per minute) for the deployment. |

## More Foundry samples (Bicep and Terraform)

This is the starter sample. For more scenario-specific templates - such as network isolation, customer-managed keys, bringing your own resources, and standard agent setups - in both **Bicep and Terraform**, see the Microsoft Foundry samples repository:

- [microsoft-foundry/foundry-samples - infrastructure setup (Bicep)](https://github.com/microsoft-foundry/foundry-samples/tree/main/infrastructure/infrastructure-setup-bicep)
- [microsoft-foundry/foundry-samples](https://github.com/microsoft-foundry/foundry-samples)

If you are new to Microsoft Foundry, see:

- [Microsoft Foundry](https://learn.microsoft.com/azure/ai-foundry/)
- [Template reference - Microsoft.CognitiveServices/accounts](https://learn.microsoft.com/azure/templates/microsoft.cognitiveservices/accounts)

If you are new to template deployment, see:

- [Azure Resource Manager documentation](https://learn.microsoft.com/azure/azure-resource-manager/)
- [Azure AI services quickstart article](https://learn.microsoft.com/azure/cognitive-services/resource-manager-template)

`Tags: Microsoft.CognitiveServices/accounts, Microsoft.CognitiveServices/accounts/projects, Microsoft.CognitiveServices/accounts/deployments, Microsoft Foundry`
