# Create a Web App protected by Application Gateway v2

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-with-app-gateway-v2/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-with-app-gateway-v2/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-with-app-gateway-v2/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-with-app-gateway-v2/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-with-app-gateway-v2/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-with-app-gateway-v2/CredScanResult.svg)

This template creates an Azure Web App with Access Restriction for an Application Gateway v2.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fweb-app-with-app-gateway-v2%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fweb-app-with-app-gateway-v2%2Fazuredeploy.json)



The Application Gateway is deployed in a vNet (subnet) which has the 'Microsoft.Web' Service Endpoint enabled. The Web App restricts access to traffic from a subnet. By default, everything is created with generated names, however, you can easily modify the template to use other default values or parameterize values. You can also 'bring your own' subnet, web app, application gateway or public ip, if you have any of the items already created.

`Tags: web-app, application-gateway, service-endpoint`


