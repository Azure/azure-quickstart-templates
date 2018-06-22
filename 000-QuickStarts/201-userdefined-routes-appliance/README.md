This template creates a VNet with 3 Subnets, Frontend, Backend and Appliance subnet. It deploys a VM into each of the subnets. It creates a route table containing routes to direct BE traffic to go through the VM in appliance subnet. The route gets associated to the front end subnet. 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-userdefined-routes-appliance%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-userdefined-routes-appliance%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>
