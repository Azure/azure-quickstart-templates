# 5 Node secure ubuntu Service Fabric Cluster with Azure Diagnostics enabled

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/5-VM-Ubuntu-1-NodeTypes-Secure/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/5-VM-Ubuntu-1-NodeTypes-Secure/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/5-VM-Ubuntu-1-NodeTypes-Secure/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/5-VM-Ubuntu-1-NodeTypes-Secure/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/5-VM-Ubuntu-1-NodeTypes-Secure/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/5-VM-Ubuntu-1-NodeTypes-Secure/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2f5-VM-Ubuntu-1-NodeTypes-Secure%2fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2f5-VM-Ubuntu-1-NodeTypes-Secure%2fazuredeploy.json)

This template allows you to deploy a secure 5 node, Single Node Type Service Fabric Cluster running Ubuntu Server on a Standard_D2_v2 Size Virtual Machine Scale set with Azure Diagnostics turned on. 

This template assumes that you already have certificates uploaded to your keyvault.  If you want to create a new certificate run the **New-ServiceFabricClusterCertificate.ps1** file in this sample.  

You can download the cert from the keyvault from the portal 
- Got to the keyvalut resource
- navigate to the secrets tab and download the cert

![DownloadCert]

## Creating a custom ARM template

If you are wanting to create a custom ARM template for your cluster, then you have two choices.

1. You can acquire this sample template make changes to it. 
2. Log into the azure portal and use the service fabric portal pages to generate the template for you to customize.
  1. Log on to the Azure Portal [http://aka.ms/servicefabricportal](http://aka.ms/servicefabricportal).

  2. Go through the process of creating the cluster as described in [Creating Service Fabric Cluster via portal](https://docs.microsoft.com/azure/service-fabric/service-fabric-cluster-creation-via-portal) , but do not click on ***create**, instead go to Summary and download the template and parameters.

 ![DownloadTemplate]

Unzip the downloaded .zip on your local machine, make any changes to template or the parameter file as you need.

<!--Image references-->
[DownloadTemplate]: ./DownloadTemplate.png
[DownloadCert]: ./DownloadCert.PNG


