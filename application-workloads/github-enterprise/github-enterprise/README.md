# GitHub Enterprise on Azure

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/github-enterprise/github-enterprise/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/github-enterprise/github-enterprise/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/github-enterprise/github-enterprise/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/github-enterprise/github-enterprise/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/github-enterprise/github-enterprise/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/github-enterprise/github-enterprise/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fgithub-enterprise%2Fgithub-enterprise%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fgithub-enterprise%2Fgithub-enterprise%2Fazuredeploy.json) 
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fgithub-enterprise%2Fgithub-enterprise%2Fazuredeploy.json)

This template deploys GitHub Enterprise Server. GitHub Enterprise Server leverages Premium Storage, and attaches a replicated 512 GB data disk by default.

You can configure GitHub Enterprise Server by visiting the public IP address assigned to the VM. To find your IP address, visit the [portal](https://portal.azure.com).

### Notes

- The certificate used in the deployment is a self signed certificate that will create a browser warning. You can follow the instructions provided by GitHub Enterprise Server to continue setup.
- An inactive, placeholder account is created for machine boot. Admin users and SSH keys will be configured during setup.

### Learn More

[GitHub Enterprise](https://enterprise.github.com)
