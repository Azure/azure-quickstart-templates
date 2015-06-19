# Deployment of WordPress+MySQL Containers with Docker Compose


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdocker-wordpress-mysql%2Fazuredeploy.json" target="_blank">
	<img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Built by: [ahmetalpbalkan](https://github.com/ahmetalpbalkan)

This template allows you to deploy an Ubuntu Server 15.04 VM with Docker (using the [Docker Extension][ext])
and starts a WordPress container listening an port 80 which uses MySQL database running
in a separate but linked Docker container, which are created using [Docker Compose][compose]
capabilities of the [Azure Docker Extension][ext].

Below are the parameters that the template expects:

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| location | The location where the Virtual Machine will be deployed  |
| mysqlPassword | Password for the MySQL database |
| adminUsername  | Username for the Virtual Machine  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |

[ext]: https://github.com/Azure/azure-docker-extension
[compose]: https://docs.docker.com/compose
