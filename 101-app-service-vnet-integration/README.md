# Deploy an App Service with VNET integration

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-app-service-vnet-integration%2Fazuredeploy.json" target="_blank">
  <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-app-service-vnet-integration%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template provides an easy way to deploy an App Service with VNET integration. This is a sample template to demonstrate how to set up successfully a VNET integration through ARM templating since it's a tricky use case.<br>
The `environment_name` parameter (string) is used as the base for resource naming.

At the time of writing this template, the resource SKU cannot be configured.