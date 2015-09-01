# Simple deployment of an Ubuntu VM with VMAccess extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmaccess-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Built by: [Bin Xia](https://github.com/bingosummer)

This template uses the Azure Linux [VMAccess extension](https://github.com/Azure/azure-linux-extensions/tree/master/VMAccess) to deploy an Linux VM. Azure Linux VMAccess extension provides several ways to allow owner of the VM to get the SSH access back.

What you can do using the VMAccess extension:

1. Add a new user with a password or a public key.
2. Modify the password or public key of the existing user.
3. Remove the existing user.
4. Reset the ssh configuration.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| adminUsername  | Username for the Virtual Machine  |
| adminPassword  | Password for the Virtual Machine  |
| location | The location where the Virtual Machine will be deployed |
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed |
| ubuntuOSVersion  | The Ubuntu version for deploying the VMAccess extension |
| vmName | Name of the Virtual Machine |
| vmSize | Size of the Virtual Machine |
| userName | The user name whose password you want to change |
| password | The new password |
| sshKey | The new public key |
| resetSSH | Whether to reset ssh |
| userNameToRemove | The user name you want to remove |

How to deploy

Azure CLI or Powershell is recommended to deploy the template.

1. Using Azure CLI

  https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-azure-resource-manager/

2. Using Powershell

  https://azure.microsoft.com/en-us/documentation/articles/powershell-azure-resource-manager/


