# Cognitive Services Computer Vision API
![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/cognitive-services-Computer-vision-API/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/cognitive-services-Computer-vision-API/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/cognitive-services-Computer-vision-API/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/cognitive-services-Computer-vision-API/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/cognitive-services-Computer-vision-API/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/cognitive-services-Computer-vision-API/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cognitiveservices%2Fcognitive-services-Computer-vision-API%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cognitiveservices%2Fcognitive-services-Computer-vision-API%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cognitiveservices%2Fcognitive-services-Computer-vision-API%2Fazuredeploy.json)


This template deploys a Cognitive Services Computer Vision API.  This allows you to process visual data. Capabilities include image analytics, tagging, recognition celebrities, text extraction, and smart thumbnail generation. 

In the outputs section it will show the Keys and the Endpoint.

| SKU  | Transactions Per Second TPS | Features                                                     | Price                                                        |
| ---- | --------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| F0   | 20 per minute               |                                                              | 5,000 transactions free per month                            |
| S1   | 10 TPS                      | Tag<br/>Face<br/>GetThumbnail<br/>Color<br/>Image Type<br/>GetAreaOfInterest | 0-1M transactions — $1 per 1,000 transactions<br/>1M-5M transactions — $0.80 per 1,000 transactions<br/>5M-10M transactions — $0.65 per 1,000 transactions<br/>10M-100M transactions — $0.65 per 1,000 transactions<br/>100M+ transactions — $0.65 per 1,000 transactions |
|      |                             | OCR<br/>Adult<br/>Celebrity<br/>Landmark<br/>Detect, Objects<br/>Brand | 0-1M transactions — $1.50 per 1,000 transactions<br/>1M-5M transactions — $1 per 1,000 transactions<br/>5M-10M transactions — $0.65 per 1,000 transactions<br/>10M-100M transactions — $0.65 per 1,000 transactions<br/>100M+ transactions — $0.65 per 1,000 transactions |
|      |                             | Describe+<br/>Recognize Text *<br/>Read                      | $2.50 per 1,000 transactions                                 |
|      |                             |                                                              | $45,000/month<br/>Up to 10B chars per month<br/>Overage: $4.50 per million chars |

* If you are new to Azure Cognitive Services, or want to learn more about these services:
  * [Azure Cognitive Services](https://azure.microsoft.com/en-us/services/cognitive-services/).
  * [Azure Cognitive Services Computer Vision](https://azure.microsoft.com/en-us/services/cognitive-services/computer-vision)
  * [Whats is the Microsoft Cognitive Computer Vision](https://docs.microsoft.com/en-us/azure/cognitive-services/computer-vision/home)
  * [Template reference](https://azure.microsoft.com/en-us/resources/templates/?referenceType=Microsoft.Cognitiveservices)
  * [Quick Start templates](https://azure.microsoft.com/en-us/resources/templates/?resourceType=Microsoft.Cognitiveservices)
  * [Microsoft Learn Modules](https://docs.microsoft.com/en-us/learn/browse/?products=azure&term=cognitive)
