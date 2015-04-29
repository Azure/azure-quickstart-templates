# Deploy a single-VM WordPress to Azure

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://azuredeploy.net/)

This template deploys a complete LAMP stack, then installs and initializes WordPress.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Name of the Storage Account where the User Image disk is placed. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| vmDnsName  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| vmSize | Size of the Virtual Machine |
| mySqlPassword | Password for your mySQL account |


Once the deployment is finished, you need to go to http://fqdn.of.your.vm/wordpress/ to finish the configuration, create an account, and get started with WordPress.

