# Azure Logic Apps - VETER Pipeline

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-veter-pipeline/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-veter-pipeline/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-veter-pipeline/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-veter-pipeline/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-veter-pipeline/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logic-app-veter-pipeline/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.logic%2Flogic-app-veter-pipeline%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)]( https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.logic%2Flogic-app-veter-pipeline%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.logic%2Flogic-app-veter-pipeline%2Fazuredeploy.json)

This template creates a VETER pipeline using Logic Apps. It creates an integration account, adds schema/map into it, creates a logic app and associates it with the integration account. The logic app implements a VETER pipeline using Xml Validation, XPath Extract and Transform Xml operations.
`Tags: VETER, Logic Apps, Integration Account, Enterprise Integration`

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

Once the deployment is completed, you can perform below steps to test your Logic App:
- Open the Logic App in the designer to get the HTTP Request endpoint url.
![Image of HTTP request trigger](images/http-request-trigger.png"HTTP request trigger")
- Perform HTTP POST operation on the http endpoint obtained from #1 using your favorite HTTP client.
    - Set content-type header to application/xml.
    - Set request body to the content of sample-order.xml (it is present under artifacts folder in this template).
- On successful execution, the logic app will respond with the transformed message (an SAP order) in response body.
![Image of sample request-response](images/request-response.png"Sample request-response")

## Notes

Learn more about: Azure Logic Apps
* **Azure Logic Apps** - https://azure.microsoft.com/documentation/articles/app-service-logic-what-are-logic-apps/
* **Logic Apps Enterprise Integration Pack** - https://blogs.msdn.microsoft.com/logicapps/2016/06/30/public-preview-of-logic-apps-enteprise-integration-pack/
* **XML Processing capabilities in Logic Apps** - https://azure.microsoft.com/documentation/articles/app-service-logic-enterprise-integration-xml/


