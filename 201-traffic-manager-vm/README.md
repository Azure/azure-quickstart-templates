# Azure Traffic Manager with virtual machines

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-traffic-manager-vm%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-traffic-manager-vm%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template shows how to create an Azure Traffic Manager profile to load-balance across a couple of Azure virtual machines.  Each endpoint has an equal weight but different weights can be specified to distribute load non-uniformly.

The accompanying PowerShell script shows how to create a resource group from the template and read back the Traffic Manager profile details.  Before running the script, edit *azuredeploy.parameters.json* and replace the values marked with *'#####'*.


See also:

- <a href="https://azure.microsoft.com/en-us/documentation/articles/traffic-manager-routing-methods/">Traffic Manager routing methods</a> for details of the different routing methods available.
- <a href="https://msdn.microsoft.com/en-us/library/azure/mt163581.aspx">Create or update a Traffic Manager profile</a> for details of the JSON elements relating to a Traffic Manager profile.

