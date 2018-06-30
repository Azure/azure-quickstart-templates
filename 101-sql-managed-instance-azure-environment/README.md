# SQL Managed Instance Virtual Network Environment

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjovanpop-msft%2Fazure-quickstart-templates%2Fmaster%2F101-sql-managed-instance-azure-environment%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fjovanpop-msft%2Fazure-quickstart-templates%2Fmaster%2F101-sql-managed-instance-azure-environment%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create an Azure networking environment required to deploy Azure SQL Database Managed Instances.
It will create configured Azure Virtual Network with two subnets - one that will be dedicated to your SQL Managed Instances,
and the another one where you can place other resources (for example VMs, App Service environments, etc.) This is a properly
configured networking environment where you can deploy Azure SQL Database Managed Instances.

Once you run this template, you should populate the following inputs:
 - Name of the Azure VNet that will be created and configured, including the address range that will be associated to this VNet (default - 10.0.0.0/16)
 - Name of the default subnet where you can place the resources other than Managed Instances. The name will be "Default", if you don't want to change it.
   This is the place where you will place VMs that should access Managed Instances in your VNet. You should also enter address range that
   should be associated to this network. If you don't need any other resources in your VNet you can put **NONE** in this field, or delete this subnet later. 
 - Name of the subnet that will be dedicated to Managed Instances placed in your VNet including the subnet address range. Choose carefully the subnet 
   address range because it depends on the number of instances that you would like to place in the subnet.
 - Name of the route table that will enable ManagedInstance subnet to communicate with the Azure Management service.
