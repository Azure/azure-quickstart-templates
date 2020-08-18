# Sample name

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpath-to-sample%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpath-to-sample%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpath-to-sample%2Fazuredeploy.json)

This template creates Azure NetApp Files account along with setting up a capacity pool to enable you to create NFSv3/NFSv4.1 volume within it. Deployed together with Azure Virtual Network and delegated subnet.

## Sample overview and deployed resources

The following resources are deployed as part of the solution:
1. A Virtual Network is deployed.
1. A delegated Subnet is added to the VNET.
1. Azure NetApp Files account is deployed.
1. A Capacity Pool is created into the ANF account.
1. A Volume with protocol type (NFSv3 or NFSv4.1) is created into the Capacity Pool.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document.