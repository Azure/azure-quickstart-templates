# Simple VM scale set example which assigns public IPv4 and IPv6 addresses to each VM

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-dualstack-ilpip%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-dualstack-ilpip%2Fazuredeploy.json)

This template deploys a simple VM Scale Set of Ubuntu 18.04-LTS VMs and assigns a public IPv4 and a public IPv6 address to each instance. This is useful for applications that require many ports to be opened to the public Internet on both IPv4 and IPv6, like video and media applications.

Direct connection: ssh {username}@{public-ip-address of VM}

To determine the public IP address of each VM using Azure CLI 2.0 (July 2017 version or later), using the _az vmss list-instance-public-ips_ command. See these links for further reference:

* [Networking for Azure virtual machine scale sets](https://docs.microsoft.com/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-networking) for more details on Azure scale set networking features.
* [What is IPv6 for Azure Virtual Network?](https://docs.microsoft.com/azure/virtual-network/ipv6-overview) for more details on IPv6 in Azure

## Parameter restrictions

virtualMachineScaleSetName must be 3-61 characters in length.

instanceCount must be 100 or less (you could adapt this template to deploy up to 1000 VMs, if you removed the load balancer and changed the singlePlacementGroup property to _false_. If you need a scale set of more than 100 VMs with load balancer, use the Application Gateway instead).
