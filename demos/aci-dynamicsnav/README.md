# MS Dynamics NAV / MS Dynamics 365 Business Central including SQL Server in Azure Container Instances

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/aci-dynamicsnav/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/aci-dynamicsnav/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/aci-dynamicsnav/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/aci-dynamicsnav/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/aci-dynamicsnav/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/aci-dynamicsnav/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Faci-dynamicsnav%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Faci-dynamicsnav%2Fazuredeploy.json)

This template demonstrates how you can run MS Dynamics NAV or a Sandbox of MS Dynamics 365 Business Central in [Azure Container Instances](https://docs.microsoft.com/en-us/azure/container-instances/). To find out more about Dynamics NAV / Business Central inside a Windows Container visit [Github](https://github.com/microsoft/nav-docker)

To start the instance, you need to accept the [end user license agreement](https://go.microsoft.com/fwlink/?linkid=861843) by setting the param acceptEula to Y. You also need to enter which version of NAV you want to use by setting navRelease (see [this list](https://hub.docker.com/r/microsoft/dynamics-nav/tags/) for possible values for NAV and [this list](https://hub.docker.com/r/microsoft/bcsandbox/tags/) for BC. Also see [this blog post](https://blogs.msdn.microsoft.com/freddyk/2018/04/16/which-docker-image-is-the-right-for-you/) by Freddy Kristiansen to understand which image is right for you). This instance automatically will download a [LetsEncrypt](https://letsencrypt.org/) certificate, so you will also need to specify the email address to be used with LetsEncrypt and the dns prefix (the first part of the URL), which you can freely choose as long as it is not already taken.

Be aware that this is downloading a rather large image (about 15GB), so downloading and extracting it takes about 20 minutes. After it has started, look into the logs to see when it has finished initializing or just wait for a minute. After that you can access Dynamics NAV at https://< dns name >/NAV/WebClient or Business Central at https://< dns name >/nav
