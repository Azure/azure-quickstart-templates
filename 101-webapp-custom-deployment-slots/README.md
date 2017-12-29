# Deploy a Web App with custom deployment slots

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-webapp-managed-postgresql%2Fazuredeploy.json" target="_blank">
  <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-webapp-managed-postgresql%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template provides an easy way to deploy web app with custom deployment slots on Azure Web Apps. The parameters can be used to specify different slot names, one for each environment, and a slot will be created for every item listed in the environments array.

Please note that different app service plans put different caps on the number of slots that can be created.
For example, at the time of this writing, a Standard plan has a max of 5 and a Premium plan has 20. The Free, Shared or Basic plans are not allowed to have any slots.
