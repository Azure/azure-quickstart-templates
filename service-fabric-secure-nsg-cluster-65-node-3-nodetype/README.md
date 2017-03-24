# Deployment of a 3 Nodetype Service Fabric secure Cluster with NSG enabled.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fservice-fabric-secure-cluster-65-node-3-nodetype%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fservice-fabric-secure-cluster-65-node-3-nodetype%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Use this template as a sample for setting up a three nodetype secure cluster and to  control the inbound and outbound network traffic using Network Security Groups. 

The template has a Network Security Group for each of the VMSS to control the traffic in and out of the VMSS. As a default, the rules are set up to allow all the traffic needed by the system services and the application ports specified in the template. Review those rules and make changes to fit your needs, including add any new ones for your applications.

Although, as a default, the parameter file is set to create 65 node cluster. So, make sure to adjust the instance counts for each of the Nodetypes in the parameter file to suit your needs.

In this template, 'SF' is the primary node type and the systems services will be running in it. When deploying applications to the cluster, Having a dedicated Nodetype for System services is a best practice when running clusters that are over 50 nodes and are packed for maximum utilization of VM resources.

This template assumes that you already have certificates uploaded to your keyvault, else I strongly suggest you follow the links below on how to. The document linked to below also has instructions on how to use Azure Active Directory for securing client operations on the cluster. 

![Picture of the cluster resources][NSG]

## Deploying the ARM template to Azure using resource manager PS 

Refer to [Deploying ARM templates using ARM PS ](https://azure.microsoft.com/documentation/articles/service-fabric-cluster-creation-via-arm/) for detailed guidance on how to. There is detailed guidance on how to set up your certificates and Azure Active Directory for clients as well. For a successful setup of a secure cluster, make sure to read that document thoroughly. 


<!--Image references-->
[DownloadTemplate]: ./DownloadTemplate.png
[NSG]: ./NSG1.PNG


