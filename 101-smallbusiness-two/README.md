# Create a 2 new Windows VMs, create a new AD Forest, Domain and 2 DCs in an availability set

NOTE: This template is STILL in development and should not be used for production until it is stabalized

This template will deploy 2 new VMs with Managed Disks for both the OS and Data (along with a new VNet, Storage Account and Load Balancer) and create a new  AD forest and domain, each VM will be created as a DC for the new domain and will be placed in an availability set. Each VM will also have an RDP endpoint added with a public load balanced IP address. Eventually this template will also include VPN connectivity and Azure Backup if it becomes possible to create a true small business solution.

Click the button below to deploy

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%raw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Ftree%2F101-smallbusiness-two%2F101-smallbusiness-two%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F101-smallbusiness-two%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

# Known Issues

<<<<<<< HEAD

# Changelog

0.1 3-27-2017 Initial code release with two DCs only as AD servers
=======
+	This template is entirely serial due to some concurrency issues between the platform agent and the DSC extension which cause problems when multiple VM and\or extension resources are deployed concurrently, this will be fixed in the near future
>>>>>>> e84967006d4aa8cbd84f515e6105e29c3b1b2111
