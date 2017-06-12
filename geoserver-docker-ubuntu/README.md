# Deploy an Ubuntu VM with a Docker container running GeoServer

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmarrobi%2Fazure-quickstart-templates%2Fgeoserver-docker-ubuntu%2Fgeoserver-docker-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to deploy an Ubuntu VM with a Docker container running GeoServer. the GeoServer GeoWebCache is redirected to an additional data disk.

This template uses the Azure Docker Extension to run the GeoServer image at  https://hub.docker.com/r/winsent/geoserver/ .

A 1GB data disk created and mounted to ```/geoserver_data``` within the container and the ```GEOSERVER_DATA_DIR``` variable set to this location.

The GeoServer web interface can be accessed at http://yourdnsname:8080/geoserver/

IMPORTANT: This is a default installation of GeoServer with no security configured.