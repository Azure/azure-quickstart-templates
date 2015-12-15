# A template to install the Puppet Agent using a shell script in public storage using CustomScript Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Flinux-puppet-agent%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

[CustomScript Extension](https://github.com/Azure/azure-linux-extensions/tree/master/CustomScript) allows the owner of the Azure Virtual Machines to run customized scripts in the VM.

This template installs the Puppet Agent in a Linux VM using a shell script that is stored in public storage(e.g. Github or a public container in Azure blob storage).

## Pre-Deployment Instructions

1. Copy the shell script (install_puppet_agent.sh) into a publicly accessible location, such as Github or a public container in Azure blob storage.

2. If you want to use Azure CLI or PowerShell deployment, you may want to edit the parameters file for convenience.

## Deploy

1. Using Azure CLI

  https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-azure-resource-manager/

2. Using PowerShell

  https://azure.microsoft.com/en-us/documentation/articles/powershell-azure-resource-manager/

3. Using Azure Portal
  Click the "Deploy to Azure" button.
