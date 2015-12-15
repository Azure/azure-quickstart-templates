# Simple deployment of a VM Scale Set of Linux VMs behind a load balancer with NAT rules

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-linux-nat%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a><a  target="_blank">

This template allows you to deploy a simple VM Scale Set of Linux VMs using the latest patched version of Ubuntu Linux 15.10, 15.04, or 14.02.2-LTS. These VMs are behind a load balancer with NAT rules that let you connect to vm i by connecting via ssh on port 50000 + i of the public IP in the deployment. For example, to connect to the 0th VM, you could use the following command:

ssh -p 50000 {username}@{public-ip-address}

PARAMETER RESTRICTIONS
======================

vmssName must be 9 characters in length or shorter.
instanceCount must be 100 or less.
