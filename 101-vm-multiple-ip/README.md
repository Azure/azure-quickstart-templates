# Create a Linux VM with multiple IPs

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-simple-linux%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-simple-linux%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>


This template allows you to deploy a simple Linux VM. This template will deploy a Linux Ubuntu 16.04 VM called *myVM1* with 3 IP configurations: *IPConfig-1*, *IPConfig-2* and *IPConfig-3*. This is based on a scenario outlined here:

https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-multiple-ip-addresses-cli
