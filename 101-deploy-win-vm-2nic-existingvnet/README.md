# Create Windows Virtual Machines with 2 NIC cards connecting to exisitng VNET Subnet's and VM to be stored in existing storage account

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-deploy-win-vm-2nic-existingvnet%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-deploy-win-vm-2nic-existingvnet%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you create Windows virtual machines  with following configurations :
+ 2 NIC Card
+ In Existing Virtual Network Subnet's
+ In Existing Storage Account



## Special Notes

For successful deployment, pay particular attention to these special items:

+ Ensure Storage account , Virtual Network and Subnet's are already created and available in Subscription. Use exact same name while defining parameters during deployment
+ NIC 1 of VM will be associated with Public IP

## Template Parameters

Modify parameters file to change default values.