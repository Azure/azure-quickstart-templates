# Deploy a Check Point Security Gateway with a single Network Interface

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcheckpoint-single-nic%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcheckpoint-single-nic%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates a VNET with 2 subnets (external and internal) and deploys a single interface Check Point Security Gateway into the external subnet. The internal subnet has 3 routes all pointing to the Check Point Security Gateway: A default route, a route to the external subnet and a route to an on premise network.
