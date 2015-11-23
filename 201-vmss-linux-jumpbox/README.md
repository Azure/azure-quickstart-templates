# Simple deployment of a VM Scale Set of Linux VMs with a jumpbox

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-linux-jumpbox%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a><a  target="_blank">

This template allows you to deploy a simple VM Scale Set of Linux VMs using the latest patched version of Ubuntu Linux 15.10, 15.04, or 14.02.2-LTS. This template also deploys a jumpbox with a public IP address in the same virtual network. You can connect to the jumpbox via this public IP address, then connect from there to VMs in the scale set via private IP addresses. To ssh into the jumpbox, you could use the following command:

ssh {username}@{jumpbox-public-ip-address}

To ssh into one of the VMs in the scale set, go to resources.azure.com to find the private IP address of the VM, make sure you are ssh'ed into the jumpbox, then execute the following command:

ssh {username}@{vm-private-ip-address}

PARAMETER RESTRICTIONS
======================

vmssName must be 9 characters in length or shorter.
instanceCount must be 100 or less.
