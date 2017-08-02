# Multi-NIC Virtual Machine Creation using Two Subnets
<a href="https://portal.azure.cn/#create/Microsoft.Template/uri/https%3A%2F%raw.githubusercontent.com/HuangXiaojuan/azure-quickstart-templates/master/101-1vm-2nics-2subnets-1vnet/azuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%raw.githubusercontent.com/HuangXiaojuan/azure-quickstart-templates/master/101-1vm-2nics-2subnets-1vnet/azuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>


This template creates a new 2012r3 VM with standard_A2 and two NICs which connect to two different subnets within the same VNet.

## Tips
1. If running under PowerShell you may update the **azuredeploy.parameters** file with the **allowedValues** for the subnet name of the Primary NIC and Secondary NIC for a nice dropdown list.
2. Customize parameters in **azuredeploy.parameters** as you see appropriate, at the very least the **adminPassword**.

Feel free to post qeustions and enjoy!
