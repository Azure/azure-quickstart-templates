# Deploy a single VM with a new or exsiting Virtual Network, Storage and Public IP using Conditions

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-new-or-existing-conditions%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-new-or-existing-conditions%2Fazuredeploy.json" target="_blank"></a>


This template allows deploying a linux VM using new or existing resources for the Virtual Network, Storage and Public IP Address.  It also allows for choosing between SSH and Password authenticate.  The templates uses conditions and logic function to remove the need for nested deployments. 

