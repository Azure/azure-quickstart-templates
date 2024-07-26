---
description: This template deploys an Azure AI Vision resource to bring AI within reach of every developer without requiring machine learning expertise.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: cognitive-services-Computer-vision-API
languages:
- bicep
- json
---
# Deploy an Azure AI Vision resource

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/cognitive-services-Computer-vision-API/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/cognitive-services-Computer-vision-API/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/cognitive-services-Computer-vision-API/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/cognitive-services-Computer-vision-API/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/cognitive-services-Computer-vision-API/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/cognitive-services-Computer-vision-API/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/cognitive-services-Computer-vision-API/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cognitiveservices%2Fcognitive-services-Computer-vision-API%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cognitiveservices%2Fcognitive-services-Computer-vision-API%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cognitiveservices%2Fcognitive-services-Computer-vision-API%2Fazuredeploy.json)

This template deploys an Azure AI Vision resource. This allows you to process visual data. Capabilities include image analytics, tagging, recognition celebrities, text extraction, and smart thumbnail generation.

In the outputs section it will show the Keys and the Endpoint.

| SKU  | Transactions Per Second TPS | Features                                                     | Price                                                        |
| ---- | --------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| F0   | 20 per minute               |                                                              | 5,000 transactions free per month                            |
| S1   | 10 TPS                      | Tag<br/>Face<br/>GetThumbnail<br/>Color<br/>Image Type<br/>GetAreaOfInterest | 0-1M transactions — $1 per 1,000 transactions<br/>1M-5M transactions — $0.80 per 1,000 transactions<br/>5M-10M transactions — $0.65 per 1,000 transactions<br/>10M-100M transactions — $0.65 per 1,000 transactions<br/>100M+ transactions — $0.65 per 1,000 transactions |
|      |                             | OCR<br/>Adult<br/>Celebrity<br/>Landmark<br/>Detect, Objects<br/>Brand | 0-1M transactions — $1.50 per 1,000 transactions<br/>1M-5M transactions — $1 per 1,000 transactions<br/>5M-10M transactions — $0.65 per 1,000 transactions<br/>10M-100M transactions — $0.65 per 1,000 transactions<br/>100M+ transactions — $0.65 per 1,000 transactions |
|      |                             | Describe+<br/>Recognize Text *<br/>Read                      | $2.50 per 1,000 transactions                                 |
|      |                             |                                                              | $45,000/month<br/>Up to 10B chars per month<br/>Overage: $4.50 per million chars |

If you are new to Azure AI services, see:

- [Azure AI services](https://learn.microsoft.com/azure/ai-services/)
- [Template reference](https://learn.microsoft.com/azure/templates/microsoft.cognitiveservices/2017-04-18/accounts)
- [Microsoft Learn training - AI Services](https://learn.microsoft.com/learn/browse/?term=ai%20services)

If you are new to template deployment, see:

- [Azure Resource Manager documentation](https://learn.microsoft.com/azure/azure-resource-manager/)
- [Azure AI services quickstart article](https://learn.microsoft.com/azure/cognitive-services/resource-manager-template)

`Tags: Microsoft.CognitiveServices/accounts`
