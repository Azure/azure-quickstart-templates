# Deployment of CKAN Containers with Docker Compose #


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdocker-ckan%2Fazuredeploy.json" target="_blank">
	<img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Built by: [rgardler](https://github.com/rgardler)

This template allows you to deploy an Ubuntu Server 15.04 VM with
Docker (using the [Docker Extension][ext]) and start a CKAN container
listening an port 80 alongside solr and postgresql containers that are
linked to the CKAN application.

NOTE: this template is currently unsuitable for production use as the
PostgreSQL container uses a default username and password.

The configuration is defined using the [Docker Compose][compose]
capabilities of the [Azure Docker Extension][ext].

See the [CKAN documentation](ckan_install_docs) for more information
about this deployment method.

Below are the parameters that the template expects:

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| location | The location where the Virtual Machine will be deployed  |
| adminUsername  | Username for the Virtual Machine  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |

[ext]: https://github.com/Azure/azure-docker-extension
[compose]: https://docs.docker.com/compose
[ckan_install_docs]: http://docs.ckan.org/en/latest/maintaining/installing/install-using-docker.html