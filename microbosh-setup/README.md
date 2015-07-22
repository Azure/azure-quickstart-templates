# Setup Micro Bosh Deployment VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fbingosummer%2Fazure-quickstart-templates%2Fmicrobosh-setup-for-beta%2Fmicrobosh-setup%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to setup cloud foundry development environment. It will create a vm with a dynamic public ip address, a storage account, a virtual network, 2 subnets and 2 reserved public ip addresses.

After the VM is created, you can logon to the VM and see ~/install.log to check whether the installation is finished. 
After the installation is finished, you can execute "./deploy_bosh.sh" in your home directory to deploy bosh.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| location | location where the resources will be deployed |
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| virtualNetworkName | name of the virtual network |
| subnetNameForBosh | name of the subnet for Bosh |
| subnetNameForCloudFoundry | name of the subnet for CloudFoundy |
| vmName | Name of Virtual Machine |
| vmSize | Size of the Virtual Machine |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| enableDNSOnDevbox | A default DNS will be setup in the devbox if it is true |
