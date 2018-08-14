# Azure Container Instances

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-aci-linuxcontainer-healthprobe%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-aci-linuxcontainer-healthprobe%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template demonstrates a simple use case for health probe of [Azure Container Instances](https://docs.microsoft.com/en-us/azure/container-instances/). The container will be restarted after it runs for 30 seconds, because the file /tmp/healthy is deleted.
