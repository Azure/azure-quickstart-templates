# A template to install the Puppet Agent using a shell script in public storage using CustomScript Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpuppet-agent-linux%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpuppet-agent-linux%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

[CustomScript Extension](https://github.com/Azure/azure-linux-extensions/tree/master/CustomScript) allows the owner of the Azure Virtual Machines to run customized scripts in the VM.

This template installs the Puppet Agent in a Linux VM using a shell script that is stored in public storage(e.g. Github or a public container in Azure blob storage).

## Deploy

1. Using Azure CLI

  https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-azure-resource-manager/

2. Using PowerShell

  https://azure.microsoft.com/en-us/documentation/articles/powershell-azure-resource-manager/

3. Using Azure Portal
  Click the "Deploy to Azure" button.
