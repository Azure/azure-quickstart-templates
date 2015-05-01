# Domain join sample

This template demonstrates domain join to a private AD domain up in cloud. 
It creates one DC VM, one other VM and joins it to the domain.

This template deploys the following resources:
<ul><li>storage account</li><li>vnet</li><li>public ip</li><li>load balancer</li><li>a DC virtual machine</li><li>and another virtual machine</li></ul>


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
| domainName | Domain name (e.g. 'contoso.com') |
| adminUsername | Domain admin username |
| adminPassword | Domain admin password |



