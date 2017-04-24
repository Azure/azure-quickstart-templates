# Deployment of CKAN Containers with Docker Compose #


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdocker-ckan%2Fazuredeploy.json" target="_blank">
	<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdocker-ckan%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

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

[ext]: https://github.com/Azure/azure-docker-extension
[compose]: https://docs.docker.com/compose
[ckan_install_docs]: http://docs.ckan.org/en/latest/maintaining/installing/index.html?highlight=docker
