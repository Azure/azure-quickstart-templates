---
description: This template deploys an Azure AI Translator resource to bring AI within reach of every developer without requiring machine learning expertise.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: cognitive-services-translate
languages:
- bicep
- json
---
# Deploy an Azure AI Translator resource

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/cognitive-services-translate/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/cognitive-services-translate/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/cognitive-services-translate/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/cognitive-services-translate/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/cognitive-services-translate/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/cognitive-services-translate/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.cognitiveservices/cognitive-services-translate/BicepVersion.svg)
[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cognitiveservices%2Fcognitive-services-translate%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cognitiveservices%2Fcognitive-services-translate%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.cognitiveservices%2Fcognitive-services-translate%2Fazuredeploy.json)

This template deploys an Azure AI Translator resource. see  https://azure.microsoft.com/services/cognitive-services/translator-text-api/

| SKU  | Feature                                                      | Price                                                        |
| ---- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| F0   | Standard Translation  <br />Text Translation <br />Language Detection <br />Bilingual Dictionary Transliteration <br />Custom Translation Training | Free - 2M chars of any combination of standard translation and custom training free per month |
| S1   | Standard Translation  <br />Text Translation <br />Language Detection <br />Bilingual Dictionary Transliteration<br />Custom Translation  <br />Translation Training <br />Custom model hosting | $10 per million chars of standard translation                |
| S2   | Standard Translation <br />Custom Translation                | $2,055.001/month<br/>250M chars per month included<br/>Overage: $8.22 per million chars |
| S3   | Standard Translation <br />Custom Translation                | $6,000/month Up to 1B chars per month Overage: $6 per million chars |
| S4   | Standard Translation <br />Custom Translation                | $45,000/month<br/>Up to 10B chars per month<br/>Overage: $4.50 per million chars |


If you are new to Azure AI services, see:

- [Azure AI services](https://learn.microsoft.com/azure/ai-services/)
- [Template reference](https://learn.microsoft.com/azure/templates/microsoft.cognitiveservices/2017-04-18/accounts)
- [Microsoft Learn training - AI Services](https://learn.microsoft.com/learn/browse/?term=ai%20services)

If you are new to template deployment, see:

- [Azure Resource Manager documentation](https://learn.microsoft.com/azure/azure-resource-manager/)
- [Azure AI services quickstart article](https://learn.microsoft.com/azure/cognitive-services/resource-manager-template)

`Tags: Microsoft.CognitiveServices/accounts`
