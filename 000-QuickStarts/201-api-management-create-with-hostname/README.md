# Azure API Management Service

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-create-with-hostname%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-api-management-create-with-hostname%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template shows an example of how to deploy an Azure API Management service with custom hostnames.  This also demonstrates how to configure multile proxy (gateway) custom hostnames for API Mangement service.  This template creates API Management service in Premium tier since the feature to configure multiple custom hostnames in proxy in API Management is only available in Premium tier of API Management.  However, you can configure single proxy custom hostname in any API Management tier.