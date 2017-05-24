# Create Multiple Virtual Machines(Windows/Ubuntu) with 2 NIC cards connecting to exisitng VNET Subnet's.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-multiple-vm-existing-vnet-storage%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-multiple-vm-existing-vnet-storage%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you create multiple virtual machines with a single template with following configurations :
+ In an Availablity Set 
+ In Existing Virtual Network Subnet's
+ In Existing Storage Account
+ 2 NIC per VM , each connecting to diffrent existing subnet in VNET
+ VM OS Disk Name , NIC Name generialized with vmname to enable re-use of template in existing subscription with modifying template



## Special Notes

For successful deployment, pay particular attention to these special items:

+ Ensure Storage account , Virtual Network and Subnet's are already created and available in Subscription. Use exact same name while defining parameters during deployment
+ This template deploys VM's without any Public IP or NSG association , Use Azure Portal to configure if required

## Template Parameters

Modify parameters file to change default values.