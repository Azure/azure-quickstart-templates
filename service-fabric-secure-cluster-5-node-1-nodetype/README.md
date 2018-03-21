# 5 Node secure Windows Service Fabric Cluster 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure-Samples%2Fservice-fabric-cluster-templates%2Fmaster%2F5-VM-Windows-1-NodeTypes-Secure%2FAzureDeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure-Samples%2Fservice-fabric-cluster-templates%2Fmaster%2F5-VM-Windows-1-NodeTypes-Secure%2FAzureDeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy a secure 5 node, Single Node Type Service Fabric Cluster running Windows Server 2016 Datacenter with containers on a Standard_D2_v2 Size Virtual Machine Scale set with Azure Diagnostics turned on. 

## Certificate needed for the template if using the 'Deploy to Azure' button above
This template assumes that you already have certificates uploaded to your keyvault.  If you want to create a new certificate run the **New-ServiceFabricClusterCertificate.ps1** file in this sample.  That script will output the values necessary for deployment via the parameters file. 

You can download the .PFX from the keyvault from the portal 
- Got to the keyvalut resource
- navigate to the secrets tab and download the .pfx

![DownloadCert]

## Use Powershell to deploy your cluster

Go through the process of creating the cluster as described in [Creating Service Fabric Cluster via arm](https://docs.microsoft.com/azure/service-fabric/service-fabric-cluster-creation-via-arm)


## Creating a custom ARM template

If you are wanting to create a custom ARM template for your cluster, then you have two choices.

1. You can acquire this sample template make changes to it. 
2. Log into the azure portal and use the service fabric portal pages to generate the template for you to customize.
  1. Log on to the Azure Portal [http://aka.ms/servicefabricportal](http://aka.ms/servicefabricportal).

  2. Go through the process of creating the cluster as described in [Creating Service Fabric Cluster via portal](https://docs.microsoft.com/azure/service-fabric/service-fabric-cluster-creation-via-portal) , but do not click on ***create**, instead go to Summary and download the template and parameters.


 ![DownloadTemplate][DownloadTemplate]


Unzip the downloaded .zip on your local machine, make any changes to template or the parameter file as you need.

This template is provided by [Azure-Samples/service-fabric-cluster-templates/5-VM-Windows-1-NodeTypes-Secure](https://github.com/Azure-Samples/service-fabric-cluster-templates/tree/master/5-VM-Windows-1-NodeTypes-Secure)

<!--Image references-->
[DownloadTemplate]: ./DownloadTemplate.png
[DownloadCert]: ./DownloadCert.PNG



