# Simple deployment of an Ubuntu VM with DSC for Linux Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-dscforlinux-extension-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template uses the Azure [DSC for Linux Extension](https://github.com/Azure/azure-linux-extensions/tree/master/DSC) to deploy an Linux VM. Azure DSC for Linux Extension allows the owner of the Azure VMs to configure the VM using Windows PowerShell Desired State Configuration (DSC) for Linux.

What you can do using the DSC for Linux Extension:

1. Push MOF configurations to the Linux VM
2. Distribute MOF configurations to the Linux VM with Pull Servers
3. Install custom DSC modules to the Linux VM
4. Remove custom DSC modules to the Linux VM

How to deploy

Azure CLI or Powershell is recommended to deploy the template.

1. Using Azure CLI

  https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-azure-resource-manager/

2. Using Powershell

  https://azure.microsoft.com/en-us/documentation/articles/powershell-azure-resource-manager/
