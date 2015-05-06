# Creates a VM with an RDP port

This sample template demonstrates how to create a NAT rule in loadbalancer to allow RDP to a vm.

You can connect to the vm using:

* mstsc.exe /v:&lt;publicDnsName&gt;.&lt;location&gt;.cloudapp.azure.com:&lt;rdpPort&gt;


This template deploys the following resources:
<ul><li>storage account</li><li>vnet</li><li>public ip</li><li>load balancer with a NAT rule for RDP</li><li>a virtual machine</li></ul>


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-with-rdp-port%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Template parameters:

| Name   | Description    |
|:--- |:---|
| location  | Location where to deploy the resources |
| publicDnsName | The DNS prefix for the public IP address |
| storageAccountName  | Name of the storage account to create |
| vmName | The name of the VM |
| imagePublisher | The name of the pulisher of the OS Image |
| imageOffer | The Image Offer |
| imageSKU | The Image SKU |
| adminUsername | Admin username |
| adminPassword | Admin password |
| rdpPort | Public port number for RDP |



