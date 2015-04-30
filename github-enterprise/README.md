# GitHub Enterprise on Azure

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fgithub-enterprise%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys GitHub Enterprise on an Ubuntu virtual machine. GitHub Enterprise leverages Premium Storage, and attaches a replicated 512 GB data disk by default. 

The GitHub Enterprise template expects the following parameters:

| Name   | Description    |
|:--- |:---|
| storageAccountPrefix  | Unique prefix for your Storage Account and DNS name. Must be all lower case letters or numbers. No spaces or special characters.|
| location | Deployment region. Choose a region with Premium Storage support. Allowed values: "West US", "East US 2", "West Europe", "East China", "Southeast Asia", "West Japan".|
| vmSize | VM size. Select a DS Series VM with at least 14 GB of RAM. Default value: **"Standard_DS3"**|
| storageDiskSizeGB | Select a Premium Storage disk capacity for your source code, in GB. Default value: **512**.|

You can configure GitHub Enterprise by visiting the public IP address assigned to the VM. To find your IP address, visit the [portal](https://portal.azure.com).

### Notes

- The certificate used in the deployment is a self signed certificate that will create a browser warning. You can follow the instructions provided by GitHub Enterprise to continue setup.
- An inactive, placeholder account is created for machine boot. Admin users and SSH keys will be configured during setup.

### Learn More

[GitHub Enterprise](https://enterprise.github.com)
