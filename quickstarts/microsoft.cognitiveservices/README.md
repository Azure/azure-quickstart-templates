# Microsoft.CognitiveServices

`Microsoft.CognitiveServices` is the Azure resource provider that hosts **Microsoft Foundry** and its sub-variants of subset capabilities, including **Azure OpenAI**, **Azure Speech**, **Azure Language**, **Azure Vision**, and more.

Every service under this provider is a variant of the same `Microsoft.CognitiveServices/accounts` resource type, distinguished by its `kind` (for example `AIServices`, `OpenAI`, `SpeechServices`, `TextAnalytics`, `ComputerVision`). Because they share the same **control plane**, they are all supported by the same management (ARM) APIs for provisioning, networking, identity, keys, and RBAC. What differs between them is the available **data plane** APIs - the runtime endpoints each variant exposes.

## Use Microsoft Foundry for new workloads

Microsoft Foundry (kind `AIServices`) is the successor to the standalone services above - including the multi-service Azure AI services resource (kind `CognitiveServices`, also known as the "universal key" resource) - and includes their capabilities in a single account. **New workloads should use Microsoft Foundry as the default choice** to benefit from the greatest feature set and the latest developments - a unified model catalog across many providers, agents, evaluations, tracing, and tool integrations - plus developer scenarios that span across all services from one resource.

## Samples in this folder

| Sample | Description |
| --- | --- |
| [foundry-getting-started](./foundry-getting-started/README.md) | **Recommended starting point.** Deploys a Microsoft Foundry account (kind `AIServices`) with a default project and a model deployment - a complete, working setup for building agents and applications with large language models. |
| [cognitive-services-universalkey](./cognitive-services-universalkey/README.md) | Deploys a multi-service Azure AI services resource accessible through a single key. |
| [cognitive-services-translate](./cognitive-services-translate/README.md) | Deploys an Azure AI Translator (Azure Language) resource. |
| [cognitive-services-Computer-vision-API](./cognitive-services-Computer-vision-API/README.md) | Deploys an Azure AI Vision resource. |

## Advanced configuration samples

For more scenario-specific templates - such as network isolation, customer-managed keys, bring-your-own-resources, connections, deployment variants or bring-your-own resources - in both **Bicep and Terraform**, see the Microsoft Foundry samples repository:

- [microsoft-foundry/foundry-samples - infrastructure setup (Bicep)](https://github.com/microsoft-foundry/foundry-samples/tree/main/infrastructure/infrastructure-setup-bicep)
- [microsoft-foundry/foundry-samples](https://github.com/microsoft-foundry/foundry-samples)

## Learn more

- [Microsoft Foundry documentation](https://learn.microsoft.com/azure/ai-foundry/)
- [Microsoft Foundry portal - ai.azure.com](https://ai.azure.com/)
- [Microsoft.CognitiveServices/accounts template reference](https://learn.microsoft.com/azure/templates/microsoft.cognitiveservices/accounts)
