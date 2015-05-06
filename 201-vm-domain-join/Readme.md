# Domain join sample

This template demonstrates domain join to a private AD domain up in cloud. 
It creates one DC VM, one other VM and joins it to the domain.

This template deploys the following resources:
<ul><li>storage account</li><li>vnet</li><li>public ip</li><li>load balancer</li><li>a DC virtual machine</li><li>and another virtual machine</li></ul>


Click the button below to deploy

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-domain-join%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Template parameters:

| Name   | Description    |
|:--- |:---|
| publicDnsName | The DNS prefix for the public IP address |
| storageAccountName  | Name of the storage account to create    |
| vmSize| The size of the virtual machines (default: Standard_A2) |
| imagePublisher | The name of the pulisher of the OS Image |
| imageOffer | The Image Offer |
| imageSKU | The Image SKU || domainName | Domain name (e.g. 'contoso.com') |
| adminUsername | Domain admin username |
| adminPassword | Domain admin password |



