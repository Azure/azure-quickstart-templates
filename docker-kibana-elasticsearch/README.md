# Deployment of Kibana+Elasticsearch Containers with Docker Compose

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/docker-kibana-elasticsearch/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/docker-kibana-elasticsearch/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/docker-kibana-elasticsearch/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/docker-kibana-elasticsearch/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/docker-kibana-elasticsearch/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/docker-kibana-elasticsearch/CredScanResult.svg" />&nbsp;


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdocker-kibana-elasticsearch%2Fazuredeploy.json" target="_blank">
	<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdocker-kibana-elasticsearch%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template allows you to deploy an Ubuntu Server 15.04 VM with Docker (using the [Docker Extension][ext])
and starts a Kibana container listening on port 5601 which uses Elasticsearch database running
in a separate but linked Docker container, which are created using [Docker Compose][compose]
capabilities of the [Azure Docker Extension][ext].

[ext]: https://github.com/Azure/azure-docker-extension
[compose]: https://docs.docker.com/compose

