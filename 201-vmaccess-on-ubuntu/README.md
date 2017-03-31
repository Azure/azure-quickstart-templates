# Simple deployment of an Ubuntu VM with VMAccess extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmaccess-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmaccess-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template uses the Azure Linux [VMAccess extension](https://github.com/Azure/azure-linux-extensions/tree/master/VMAccess) to deploy an Linux VM. Azure Linux VMAccess extension provides several ways to allow owner of the VM to get the SSH access back.

What you can do using the VMAccess extension:

1. Add a new user with a password or a public key.
2. Modify the password or public key of the existing user.
3. Remove the existing user.
4. Reset the ssh configuration.

How to deploy

Azure CLI or Powershell is recommended to deploy the template.

1. Using Azure CLI

  https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-azure-resource-manager/

2. Using Powershell

  https://azure.microsoft.com/en-us/documentation/articles/powershell-azure-resource-manager/
