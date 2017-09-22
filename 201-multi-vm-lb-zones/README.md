# Create Multiple Virtual Machines in Different Availability Zones and Configure NAT Rules through the Standard Load balancer

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-multi-vm-lb-zones%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-multi-vm-lb-zones%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create 1 to 10 Virtual Machines in Availability Zones and configure NAT rules through the standard load balancer. This template also deploys a virtual network, public IP address and network interfaces.

In this template, we use the resource loops capability to create the network interfaces and virtual machines.

The virtual machines are spread out into differnt availability zones.