---
description: This template simplifies the deployment of GitLab Omnibus on a Virtual Machine with a public DNS, leveraging the public IP's DNS. It utilizes the Standard_F8s_v2 instance size, which aligns with reference architecture and supports up to 1000 users (20 RPS). The instance is pre-configured to use HTTPS with a Let's Encrypt certificate for secure connections.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vm-linux-gitlab-omnibus
languages:
- bicep
- json
---
# GitLab Omnibus

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-linux-gitlab-omnibus/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-linux-gitlab-omnibus/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-linux-gitlab-omnibus/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-linux-gitlab-omnibus/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-linux-gitlab-omnibus/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-linux-gitlab-omnibus/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-linux-gitlab-omnibus/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-linux-gitlab-omnibus%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-linux-gitlab-omnibus%2Fazuredeploy.json)

This template simplifies the deployment of GitLab Omnibus on a Virtual Machine with a public DNS, leveraging the public IP's DNS. It utilizes the Standard_F8s_v2 instance size, which aligns with [reference architecture](https://docs.gitlab.com/ee/administration/reference_architectures/1k_users.html) and supports up to 1000 users (20 RPS). The instance is pre-configured to use HTTPS with a Let's Encrypt certificate for secure connections. It is possible to define GitLab version and Edition prior installation. Installation of GitLab is done through `runCommands` resource.

`Tags: Azure Virtual Machine, DevSecOps`