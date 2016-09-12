# VNET to VNET connection

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vnet-transitive-bgp%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vnet-transitive-bgp%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates three VNETs in the same location, each containing a subnet and Gateway subnet. It creates three public IPs which are used to create a VPN Gateway in each VNET, all BGP enabled using private ASNs. 

It then establishes a BGP enabled connection between vNet 1 and 2, and vNet 2 and 3.

To demonstrate the transitive routing capabilities, deploy VMs in vNets 1 and 3, connect to the VM in vNet 1 and try to connect (ping/SSH) to the internal IP of the VM in vNet 3.

Notes:
- The Autonomous System Numbers (ASNs) can be private or public (if you do use a public one, you must be able to prove ownership of it)
- Enter the Pre-shared Key as a parameter