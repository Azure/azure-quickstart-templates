# This template disables data disk encryption of a Linux VM with no AAD

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-decrypt-running-linux-vm-without-aad%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-decrypt-running-linux-vm-without-aad%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template disables encryption of data disks on a running Linux VM with no AAD if only data disks were encrypted.   If the OS disk was also encrypted, this scenario is not supported and is expected to fail. 

Tags: AzureDiskEncryption

References:
White paper - https://azure.microsoft.com/en-us/documentation/articles/azure-security-disk-encryption/

