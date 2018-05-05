# Azure Container Instances

This template demonstrates how you can run MS Dynamics NAV or a Sandbox of MS Dynamics 365 Business Central in [Azure Container Instances](https://docs.microsoft.com/en-us/azure/container-instances/). To find out more about Dynamics NAV / Business Central inside a Windows Container visit [Github](https://github.com/microsoft/nav-docker)

To start the instance, you need to accept the [end user license agreement](https://go.microsoft.com/fwlink/?linkid=861843) by setting the param acceptEula to Y. You also need to enter which version of NAV you want to use by setting navRelease (see [this list](https://hub.docker.com/r/microsoft/dynamics-nav/tags/) for possible values for NAV and [this list](https://hub.docker.com/r/microsoft/bcsandbox/tags/) for BC. Also see [this blog post](https://blogs.msdn.microsoft.com/freddyk/2018/04/16/which-docker-image-is-the-right-for-you/) by Freddy Kristiansen to understand which image is right for you). Be aware that this is downloading a rather large image (about 15GB), so downloading and extracting it takes about 20 minutes. After it has started, look into the logs to see when it has finished initializing or just wait for a minute. After that you can access Dynamics NAV at https://< ip >/NAV/WebClient or Business Central at https://< ip >/nav

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-aci-dynamicsnav%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
