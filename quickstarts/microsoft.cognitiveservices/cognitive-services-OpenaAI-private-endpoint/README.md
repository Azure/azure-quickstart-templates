---
description: This template deploys an Azure OpenAI resource with embeddings and GPT model deployments. It ensures private network access through a private endpoint and private DNS zone linked to a VNET, while also deploying a virtual machine and a Bastion host for internal endpoint connectivity testing.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: openai-private-endpoint
languages:
- json
- bicep
---
# Create an Azure OpenAI resource with a private endpoint

**Important:** for deployment to be successful, the resource group selected or created in the wizard and deployment models specified must be in a supported region. Please be sure to check the [Model summary table and region availability](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models#model-summary-table-and-region-availability) for the latest status.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cognitiveservices%2Fcognitive-services-OpenAI-private-endpoint%2Fazuredeploy.json)

This template deploys an Azure OpenAI resource with embeddings and GPT model deployments. It ensures private network access through a private endpoint and private DNS zone linked to a VNET, while also deploying a Bastion host and a virtual machine for secure internal endpoint connectivity testing.

## Architecture Diagram
![img](/images/architecture.png)

Below are the parameters which can be user configured in the parameters file including:

- **customSubDomainName:** Enter a custom subdomain name for the Azure OpenaI resource.
- **embeddingsDeploymentCapacity:** Enter the Tokens per Minute Rate Limit (thousands) for the embeddings model deployment.
- **embeddingsModelName:** Enter the name of the embeddings model to deploy.
- **gptDeploymentCapacity:** Enter the Tokens per Minute Rate Limit (thousands) for the gpt model deployment.
- **chatGptModelName:** Enter the name of the gpt model to deploy.
- **adminUsername:** Enter the name of the amin account for virtual machine login.
- **adminPassword:** Enter password for the virtual machine admin account.

Once deployment is complete, navigate to the virtual machine and select Connect. When presented with connection options select the Bastion tab and provide the username and password. From there you will be able to successfully connect to the Azure OpenAI resource endpoint, including using the chat features in the Azure OpenAI Studio.

`Tags: Azure OpenAI, Private Endpoint, Microsoft.CognitiveServices/accounts, Microsoft.Network/virtualNetworks, Microsoft.Network/privateEndpoints, Microsoft.Network/privateDnsZones, Microsoft.Network/privateDnsZones/virtualNetworkLinks, Microsoft.Network/privateEndpoints/privateDnsZoneGroups`