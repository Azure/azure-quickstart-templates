# Create an Internet-facing load-balancer with a Public IPv6 address

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-application-gateway-create%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-application-gateway-create%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

**This template provides to and example for how to deploy a Load Balancer with an IPv6 public IP address.**

The template creates and configures the following Azure resources:

- a virtual network interface for each VM with both IPv4 and IPv6 addresses assigned
- an Internet-facing Load Balancer with an IPv4 and an IPv6 Public IP address
- two load balancing rules to map the public VIPs to the private endpoints
- an Availability Set that contains the two VMs
- two virtual machines

For a more information about this template, see [Deploy an Internet-facing load-balancer solution with IPv6 using a template](https://azure.microsoft.com/documentation/articles/load-balancer-ipv6-internet-template/)