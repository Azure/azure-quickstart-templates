# Create Azure Netapp Files resource with NFSV3 or NFSv4.1 volume

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-nfs-volume/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-nfs-volume/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-nfs-volume/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-nfs-volume/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-nfs-volume/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-nfs-volume/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.netapp%2Fanf-nfs-volume%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.netapp%2Fanf-nfs-volume%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.netapp%2Fanf-nfs-volume%2Fazuredeploy.json)

This template creates Azure NetApp Files account along with setting up a capacity pool to enable you to create NFSv3/NFSv4.1 volume within it. Deployed together with Azure Virtual Network and delegated subnet.

## Sample overview and deployed resources

The following resources are deployed as part of the solution:

1. A Virtual Network with a delegated Subnet is deployed.
1. Azure NetApp Files account is deployed.
1. A Capacity Pool is created into the ANF account.
1. A Volume with protocol type (NFSv3 or NFSv4.1) is created into the Capacity Pool.

## Deployment steps

You can click the **Deploy to Azure** button at the beginning of this document. To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/azure-netapp-files/azure-netapp-files-quickstart-set-up-account-create-volumes) article.
