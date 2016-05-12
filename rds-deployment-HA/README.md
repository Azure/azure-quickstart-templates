# Provide High Availability to RDG and RDWA Server on top of Remote Desktop Sesson Collection deployment

This template deploys the following resources:

<ul><li>a number of RD Gateway/RD Web Access vm (number defined by 'numberOfWebGwInstances' parameter)</li></ul>

The template will join all new vms to the domain.
Deploy RDS roles in the deployment.
Join new VM's to the exisitng web and Gateway farm of basic RDS deplyment.
Post configurations for web/Gateway VM's such as defining the Machine keys for IIS modules.

Click the button below to deploy

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Frds-deployment-HA%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Frds-deployment-HA%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

