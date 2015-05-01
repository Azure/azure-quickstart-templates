# Creates a VM with an RDP port

This sample template demonstrates how to create a NAT rule in loadbalancer to allow RDP to a vm.

This template deploys the following resources:
<ul><li>storage account</li><li>vnet</li><li>public ip</li><li>load balancer with a NAT rule for RDP</li><li>a virtual machine</li></ul>

Public IP port for RDP is set to 50001, you can always make that a parameter if you need to.


Click the button below to deploy

<a href="https://azuredeploy.net" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Template parameters:

| Name   | Description    |
|:--- |:---|
| location  | Location where to deploy the resource <br><ul>**Allowed Values**<li>**West US (default)**</li><li>East US</li><li>West Europe</li><li>East Asia</li><li>Southeast Asia</li>|
| publicDnsName | The DNS prefix for the public IP address |
| storageAccountName  | Name of the storage account to create    |
| sourceImageName | Name of image to use for all the vm <br> <ul><li>a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201503.01-en.us-127GB.vhd **(default)**</li></ul>|
| adminUsername | Admin username |
| adminPassword | Admin password |



