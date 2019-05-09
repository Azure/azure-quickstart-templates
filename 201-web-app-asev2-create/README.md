# Create an App Service Environment v2

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-web-app-asev2-create%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-web-app-asev2-create%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

For more details on App Service Environments, see the [Introduction to App Service Environments](https://docs.microsoft.com/en-us/azure/app-service/app-service-environment/intro).

This template enables creation of an External or ILB ASE. An External ASE has a public address for application traffic and an ILB ASE has an address in your VNet for application traffic. Apps made in an External ASE will be accessible, by default, at the domain name *&lt;app name&gt;.&lt;ASE name&gt;.p.azurewebsites.net*   Apps made in an ILB ASE will be accesible, by default, at the domain name *&lt;app name&gt;.&lt;ASE name&gt;.appserviceenvironment.net* 
