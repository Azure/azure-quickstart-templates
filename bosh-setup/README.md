# Setup Bosh Deployment VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbosh-setup%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to setup Cloud Foundry development environment. It will create a vm with a dynamic public ip address, a storage account, a virtual network, 2 subnets and 2 reserved public ip addresses.

After the VM is created, you can logon to the VM and see ~/install.log to check whether the installation is finished. 
After the installation is finished, you can execute "./deploy_bosh.sh" in your home directory to deploy bosh and see ~/run.log to check whether bosh is deployed successfully.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| location | location where the resources will be deployed |
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. It can contain only lowercase letters and numbers. It has to be between 3 and 24 characters. |
| virtualNetworkName | name of the virtual network |
| subnetNameForBosh | name of the subnet for Bosh |
| subnetNameForCloudFoundry | name of the subnet for CloudFoundy |
| vmName | Name of Virtual Machine |
| vmSize | Size of the Virtual Machine |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| enableDNSOnDevbox | A default DNS will be setup in the devbox if it is true. If you enable it, you should reboot the dev-box manually after you logon to dev-box at the first time. If the dev-box reboots, its public IP address may change. You need to manually update it in /etc/bind/cf.com.wan. |

You can view our blog [here](http://azure.microsoft.com/blog/2015/08/21/cloud-foundry-on-azure-preview-2-now-available/), and follow the guide [here](https://github.com/Azure/bosh-azure-cpi-release/blob/master/docs/template-guide.md) to deploy Cloud Foundry on Azure.

If you have any question about this template or the deployment of Cloud Foundry on Azure, please feel free to give your feedback [here](https://github.com/Azure/bosh-azure-cpi-release/issues).
