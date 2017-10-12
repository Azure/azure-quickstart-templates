# Azure Container Instances

This template demonstrates how you can run MS Dynnamics NAV in [Azure Container Instances](https://docs.microsoft.com/en-us/azure/container-instances/). To find out more about Dynamics NAV inside a Windows Container visit [Github](https://github.com/microsoft/nav-docker)

To start the instance, you currently need to provide the password for the private Docker registry where the Dynamics NAV images are stored. That should change to Docker Hub soon. You also need to accept the end user license agreement by setting the param acceptEula to Y

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Ftfenster%2Fazure-quickstart-templates%2FDynNAV%2F101-aci-dynamicsnav%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>