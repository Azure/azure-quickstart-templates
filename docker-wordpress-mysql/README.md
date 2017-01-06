# Deployment of WordPress+MySQL Containers with Docker Compose


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdocker-wordpress-mysql%2Fazuredeploy.json" target="_blank">
	<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdocker-wordpress-mysql%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy an Ubuntu Server 16.04.0-LTS VM with Docker (using the [Docker Extension][ext])
and starts a WordPress container listening an port 80 which uses MySQL database running
in a separate but linked Docker container, which are created using [Docker Compose][compose]
capabilities of the [Azure Docker Extension][ext].


[ext]: https://github.com/Azure/azure-docker-extension
[compose]: https://docs.docker.com/compose
