# Create a Web App protected by Application Gateway v2

<IMG SRC="https://azbotstorage.blob.core.windows.net/badges/201-web-app-with-app-gateway-v2/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azbotstorage.blob.core.windows.net/badges/201-web-app-with-app-gateway-v2/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azbotstorage.blob.core.windows.net/badges/201-web-app-with-app-gateway-v2/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azbotstorage.blob.core.windows.net/badges/201-web-app-with-app-gateway-v2/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azbotstorage.blob.core.windows.net/badges/201-web-app-with-app-gateway-v2/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azbotstorage.blob.core.windows.net/badges/201-web-app-with-app-gateway-v2/CredScanResult.svg" />&nbsp;

This template creates an Azure Web App with Access Restriction for an Application Gateway v2.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-web-app-with-app-gateway-v2%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-web-app-with-app-gateway-v2%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

The Application Gateway is deployed in a vNet (subnet) which has the 'Microsoft.Web' Service Endpoint enabled. The Web App restricts access to traffic from a subnet. By default, everything is created with generated names, however, you can easily modify the template to use other default values or parameterize values. You can also 'bring your own' subnet, web app, application gateway or public ip, if you have any of the items already created.

`Tags: web-app, application-gateway, service-endpoint`
