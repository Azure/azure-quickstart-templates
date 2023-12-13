---
description: Deploy a single Windows container with a fully featured self-contained Microsoft Dynamics 365 Business Central environment on Azure Container Instances.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: aci-bc
languages:
- bicep
- json
---
# Azure Container Instances - BC with SQL Server and IIS

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/aci-bc/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/aci-bc/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/aci-bc/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/aci-bc/FairfaxDeployment.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/demos/aci-bc/BicepVersion.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/aci-bc/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/aci-bc/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Faci-bc%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Faci-bc%2FcreateUiDefinition.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Faci-bc%2Fazuredeploy.json)

This template demonstrates how you can run MS Dynamics 365 Business Central in [Azure Container Instances](https://docs.microsoft.com/azure/container-instances/). To find out more about Business Central inside a Windows Container visit [GitHub](https://github.com/microsoft/nav-docker)

To start the instance, you need to accept the [end user license agreement](https://go.microsoft.com/fwlink/?linkid=861843) by setting the param acceptEula to Y. This instance automatically will download a [LetsEncrypt](https://letsencrypt.org/) certificate, so you will also need to specify the email address to be used with LetsEncrypt and the dns prefix (the first part of the URL), which you can freely choose as long as it is not already taken.

Be aware that this is downloading a rather large image and then installs BC, so downloading, extracting and initializing takes about 20 minutes. After it has started, look into the logs to see when it has finished initializing or just wait for a minute. After that you can access BC at https://< dns name >/BC.

`Tags: Microsoft.ContainerInstance/containerGroups, Public`
