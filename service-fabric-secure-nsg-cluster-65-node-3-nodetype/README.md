# Deployment of a 65 Node, 3 Nodetype secure Service Fabric Cluster

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fservice-fabric-secure-cluster-65-node-3-nodetype%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fservice-fabric-secure-cluster-65-node-3-nodetype%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Use this template as a sample for setting a dedicated Nodetype for service fabric system services. Having a dedicated Nodetype for System services is a best practice when running clusters that are over 50 nodes and are packed for maximum utilization of VM resources.

This template allows you to deploy a secure 65 node, Three Node Type Service fabric Cluster running Windows server 2012 R2 Data center on Standard_D2 Size VMs with Windows Azure diagnostics turned on. In this template, SF is the primary node type and the systems services will be running in it. 

If you want to use this template for a generic 3 node type service fabric Cluster, you can do that as well. you just need to adjust the instance counts for each of the Nodetypes.

The template also adds a Network Security Group for each of the VMSS to control the traffic in and out of the VMSS. As a default, the rules are set up to allow all the traffic needed by the system services and the application ports specified in the template. Review those rules and make changes to fit your needs, including add any new ones for your applications.

This template assumes that you already have certificates uploaded to your keyvault, else I strongly suggest you follow the links below on how to. The document linked to below also has instrcutions on how to use Azure Active Directory for securing client operations on the cluster. 

![Picture of the cluster resources][NSG]

## Deploying the ARM template to Azure using resource manager PS 

Refer to [Deploying ARM templates using ARM PS ](https://azure.microsoft.com/documentation/articles/service-fabric-cluster-creation-via-arm/) for detailed guidance on how to. There is detailed guidance on how to set up your certificates and Azure Active Directory for clients as well. For a successful setup of a secure cluster, make sure to read that document thoroughly. 


<!--Image references-->
[DownloadTemplate]: ./DownloadTemplate.png
[NSG]: ./NSG.PNG



