# Setup Micro Bosh Deployment VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmicrobosh-setup%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to setup cloud foundry development environment. It will create a vm with public ip address, storage account, virtual network, 3 reserved public ip 

After the VM is created, you can logon to the VM and see ~/install.log to check whether the installation is finished. 
After the installation is finished, you can execute "./deploy_micro_bosh.sh ~/stemcell.tgz" in your home directory to deploy microbosh.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| location | location where the resources will be deployed |
| vmSize | Size of the Virtual Machine |
| vmName | Name of Virtual Machine |