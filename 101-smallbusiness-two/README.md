# Create a 2 new Windows VMs, create a new AD Forest, Domain and 2 DCs in an availability set


This template will deploy 2 new VMs with Managed Disks for both the OS and Data (along with a new VNet, Storage Account and Load Balancer) and create a new  AD forest and domain, each VM will be created as a DC for the new domain and will be placed in an availability set. Each VM will also have an RDP endpoint added with a public load balanced IP address. 
In addition this template will create a Backup Vault and a Backup Policy based on inputs provided. Once the template deploys succesfully, you will need to manually add the VMs into the backup vault as protected items.

Click the button below to deploy

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%raw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F101-smallbusiness-two%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F101-smallbusiness-two%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

# Known Issues


# Changelog

0.1 3-27-2017 Initial code release with two DCs only as AD servers
1.0 4-05-2017 Initial submission to GitHub for publishing with all functionality working.