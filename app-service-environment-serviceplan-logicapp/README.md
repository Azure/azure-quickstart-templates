# Deploy an App Service Environment with an AppService Plan and Logic App onto an existing Virtual Network

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapp-service-environment-serviceplan-logicapp%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapp-service-environment-serviceplan-logicapp%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates a new AppService Environment on a specified Subnet in a pre-existing Virtual Netowrk.
It proceeds to create an AppService hosting plan preparing the environment to recieve Web, API and Logic apps.
Finally - it deploys a sample Logic app that calls http://www.example.com on a schedule

The template assumes a network was created using the ClassicNetwork provider (or using V1 network on the portal) and that it includes a subnet onto which to deploy the environment.

##Known Issues and Limitations
- At present only API and Logic Apps add support for AppService Environment this should just work for these too
- At present the template expects a ClassNetwork
