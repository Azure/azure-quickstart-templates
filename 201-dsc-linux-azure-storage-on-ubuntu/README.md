# Simple deployment of an Ubuntu VM with DSC Linux Extension, configuration files are placed in Azure Storage

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-dsc-linux-azure-storage-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-dsc-linux-azure-storage-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template uses the Azure [DSC for Linux Extension](https://github.com/Azure/azure-linux-extensions/tree/master/DSC) to deploy an Linux VM. Azure DSC for Linux Extension allows the owner of the Azure VMs to configure the VM using Windows PowerShell Desired State Configuration (DSC) for Linux.

With this template, you could:

1. Push MOF configurations to the Linux VM, the MOF files should be placed in Azure Storage
2. Distribute MOF configurations to the Linux VM with Pull Servers, the meta MOF files should be placed in Azure Storage
3. Install custom DSC modules to the Linux VM, the resource module files should be placed in Azure Storage
4. Register Linux VM to Azure Automation


How to deploy

Azure CLI or Powershell is recommended to deploy the template.

1. Using Azure CLI

  https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-azure-resource-manager/

2. Using Powershell

  https://azure.microsoft.com/en-us/documentation/articles/powershell-azure-resource-manager/
