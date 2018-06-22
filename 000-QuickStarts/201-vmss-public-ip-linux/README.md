# Simple VM scale set example which assigns public IPv4 addresses to each VM, and load balancer inbound NAT rules

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-public-ip-linux%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-public-ip-linux%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys a simple VM Scale Set of Ubuntu 16.04-LTS VMs and assigns a public IP address to each one. With this scale set you can connect directly to the public IP addresses, or indirectly to the scale set VM private IP addresses using the load balancer inbound NAT rules:

Direct connection: ssh {username}@{public-ip-address of VM}

Indirect connection via load balancer: ssh -p 50000 {username}@{load balancerpublic-ip-address}

To determine the public IP address of each VM using Azure CLI 2.0 (July 2017 version or later), using the _az vmss list-instance-public-ips_ command. See [Networking for Azure virtual machine scale sets](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-networking) for more details on Azure scale set networking features.


PARAMETER RESTRICTIONS
======================

vmssName must be 3-61 characters in length. It should also be globally unique across all of Azure. 

instanceCount must be 100 or less (you could adapt this template to deploy up to 1000 VMs, if you removed the load balancer and changed the singlePlacementGroup property to _false_. If you need a scale set of more than 100 VMs with load balancer, use the Application Gateway instead).
