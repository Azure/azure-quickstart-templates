# Very simple deployment of a 5 Node secure Service Fabric Cluster with Azure Diagnostics enabled

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.servicefabric/service-fabric-secure-cluster-5-node-1-nodetype/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.servicefabric/service-fabric-secure-cluster-5-node-1-nodetype/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.servicefabric/service-fabric-secure-cluster-5-node-1-nodetype/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.servicefabric/service-fabric-secure-cluster-5-node-1-nodetype/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.servicefabric/service-fabric-secure-cluster-5-node-1-nodetype/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.servicefabric/service-fabric-secure-cluster-5-node-1-nodetype/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.servicefabric%2Fservice-fabric-secure-cluster-5-node-1-nodetype%2Fazuredeploy.json)
[![Deploy To Azure Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.servicefabric%2Fservice-fabric-secure-cluster-5-node-1-nodetype%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.servicefabric%2Fservice-fabric-secure-cluster-5-node-1-nodetype%2Fazuredeploy.json)

This template allows you to deploy a secure 5 node, Single Node Type Service Fabric Cluster running Windows Server 2019 Datacenter on a Standard_D2_v2 Size VMSS with Azure Diagnostics turned on. This template assumes that you already have certificates uploaded to your key vault. If you want to create a new certificate run the `New-ServiceFabricClusterCertificate.ps1` file in this sample. That script will output the values necessary for deployment via the parameters file. The certificate that is created by this script is self-signed and should only be used for testing purposes.

## Creating a custom ARM template

If you want to create a custom ARM template for your cluster, then you have two choices:

1. You can acquire this sample template make changes to it.
2. Log into the azure portal and use the service fabric portal pages to generate the template for you to customize.
   1. Log on to the Azure Portal [http://aka.ms/servicefabricportal](http://aka.ms/servicefabricportal).

   1. Go through the process of creating the cluster as described in [Creating Service Fabric Cluster via portal](https://docs.microsoft.com/azure/service-fabric/service-fabric-cluster-creation-via-portal) , but don't click on **create**, instead go to Summary and download the template and parameters.

   ![DownloadTemplate][DownloadTemplate]

   1. Unzip the downloaded `.zip` on your local machine, make any changes to template or the parameter file as you need.

<!--Image references-->
[DownloadTemplate]: ./DownloadTemplate.png

## Learn more

To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/service-fabric/quickstart-cluster-template) article.
