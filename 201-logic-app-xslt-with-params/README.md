# Azure Logic Apps - XSLT with parameters

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-logic-app-xslt-with-params%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-logic-app-with-params%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates a request-response Logic App which performs XSLT based transformation. The XSLT map takes primitives (integer, string etc.) as input parameters as uses them during XML transformation.

## Deployment steps

You can click the "Deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

Once the deployment is completed, you can perform below steps to test your Logic App:
- Open the Logic App in the designer to get the HTTP Request endpoint url.
![Image of HTTP request trigger](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-logic-app-xslt-with-params/images/http-request-trigger.png "HTTP request trigger")
- (Optional) Modify the values for parameters X and Y in the Transform XML action.
![Image of Transform XML action](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-logic-app-xslt-with-params/images/transform-xml-action.png "Transform XML action")
- Perform HTTP POST operation on the http endpoint obtained from #1 using your favorite HTTP client.
    - Set content-type header to application/xml.
    - Set request body to the content of sample-input.xml (it is present under artifacts folder in this template).
- On successful execution, the logic app will respond with the transformed message in response body.
![Image of sample request-response](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-logic-app-xslt-with-params/images/request-response.png "Sample request-response")

## Notes

Learn more about: Azure Logic Apps
* **Azure Logic Apps** - https://azure.microsoft.com/documentation/articles/app-service-logic-what-are-logic-apps/
* **Logic Apps Enterprise Integration Pack** - https://blogs.msdn.microsoft.com/logicapps/2016/06/30/public-preview-of-logic-apps-enteprise-integration-pack/
* **XML Processing capabilities in Logic Apps** - https://azure.microsoft.com/documentation/articles/app-service-logic-enterprise-integration-xml/

`Tags: Logic Apps, Enterprise Integration, XSLT, XML Transform