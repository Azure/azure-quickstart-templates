# Very simple deployment of a 5 Node secure Service Fabric Cluster with Azure Diagnostics enabled

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fservice-fabric-secure-cluster-5-node-1-nodetype%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fservice-fabric-secure-cluster-5-node-1-nodetype%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy a secure 5 node, Single Node Type Service fabric Cluster running Windows server 2012 R2 Data center on Standard_D2 Size VMs with Windows Azure diagnostics turned on. This template assumes that you already have certificates uploaded to your keyvault, else I strongly suggest you follow one of the two links below.

## Creating a custom ARM template

If you are wanting to create a custom ARM template for your cluster, then you have to choices.

1. You can acquire this sample template make changes to it. 
2. Log into the azure portal and use the service fabric portal pages to generate the template for you to customize.
3. Log on to the Azure Portal [http://aka.ms/servicefabricportal](http://aka.ms/servicefabricportal).
4. Go through the process of creating the cluster as described in [Creating Service Fabric Cluster via portal](https://docs.microsoft.com/azure/service-fabric/service-fabric-cluster-creation-via-portal) , but do not click on ***create**, instead go to Summary and download the template and parameters.


 ![DownloadTemplate][DownloadTemplate]


Unzip the downloaded .zip on your local machine, make any changes to template or the parameter file as you need.


## Deploying the ARM template to Azure using resource manager PS 

Refer to [Deploying ARM templates using ARM PS ](https://azure.microsoft.com/documentation/articles/service-fabric-cluster-creation-via-arm/) for detailed guidance on how to. There is detailed guidance on how to set up your certificates as well. For a successful setup of a secure cluster, make sure to read that document thoroughly. 

<!--Image references-->
[DownloadTemplate]: ./DownloadTemplate.png



