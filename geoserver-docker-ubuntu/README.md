# Deploy GeoServer using Docker inside an Ubuntu VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmarrobi%2Fazure-quickstart-templates%2Fgeoserver-docker-ubuntu%2Fgeoserver-docker-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to deploy an Ubuntu VM with a Docker container running GeoServer. The GeoServer GeoWebCache is redirected to an additional data disk.

This template uses the Azure Docker Extension to run the GeoServer image at  https://hub.docker.com/r/winsent/geoserver/ .

A 1GB data disk created and mounted to ```/geoserver_data``` within the container and the ```GEOSERVER_DATA_DIR``` variable set to this location.

The GeoServer web interface can be accessed at http://yourdnsname:8080/geoserver/, this address is provided as an output of the template.

IMPORTANT: This is a default installation of GeoServer with no security configured.

### Future work:

1. Move GeoServer data to Azure Files and configure GeoWebCache to use local disk.
2. Work on blob storage plugin https://github.com/jjcollinge/geoserver/tree/jjcollinge/gwc-azure, and https://github.com/jjcollinge/geowebcache/tree/jjcollinge/gwc-azure-blob and integrate.
3. Configure VM scale set for HA.