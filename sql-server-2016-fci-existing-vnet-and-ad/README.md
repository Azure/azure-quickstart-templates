# Create a SQL Server 2016 Failover Cluster using Windows Server 2016 Storage Spaces Direct (S2D)
This template will create a SQL 2016 Failover Cluster using Windows Server 2016 Storage Spaces Direct (S2D) in an existing VNET and Active Directory environment.

This template creates the following resources by default:

+	A Premium Storage Account for storing VM disks for each storage node
+   A Standard Storage Account for a Cloud Witness
+	A SQL Server 2016 cluster for storage nodes provisioned on Storage Spaces Direct (S2D)
+	One Availability Set for the cluster nodes

## Requirements

+ 	The service account used by SQL Server should be created ahead of time in AD by an admin.  Use the standard SQL Server guidance for these accounts.

+	The default settings for storage are to deploy using **premium storage**, which is **strongly** recommended for S2D performance.  When using Premium Storage, be sure to select a VM size (DS-series, GS-series) that supports Premium Storage.

+   The default settings deploy 2 data disks per storage node, but can be increased to up to 32 data disks per node.  When increasing # of data disks, be sure to select a VM size that can support the # of data disks you specify.

+ 	The default settings for compute require that you have at least 4 cores of free quota to deploy.

+ 	The images used to create this deployment are
	+ 	SQL Server 2016 SP1 and Windows Server 2016 Datacenter Edition - Latest Image

+	To successfully deploy this template, be sure that the subnet to which the storage nodes are being deployed already exists on the specified Azure virtual network, AND this subnet should be defined in Active Directory Sites and Services for the appropriate AD site in which the closest domain controllers are configured.

+ SPECIAL THANKS to <a href="https://github.com/mmarch">@mmarch</a> on code contributions for dynamic data disk selection nested templates!
+ SPECIAL THANKS to <a href="https://github.com/robotechredmond">@robotechredmond</a> for the Windows S2D template this is based on!

## Deploying Sample Templates

To deploy the required Azure VNET and Active Directory infrastructure, if not already in place, you may use <a href="https://github.com/Azure/azure-quickstart-templates/tree/master/active-directory-new-domain-ha-2-dc">this template</a> to deploy the prerequisite infrastructure. 

Click the button below to deploy from the portal:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FMSBrett%2Fazure-quickstart-templates%2Fmaster%2Fsql-server-2016-fci-existing-vnet-and-ad%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FMSBrett%2Fazure-quickstart-templates%2Fmaster%2Fsql-server-2016-fci-existing-vnet-and-ad%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>



Tags: ``cluster, ha, storage spaces, storage spaces direct, S2D, windows server 2016, ws2016, sql server 2016, sql2016``
