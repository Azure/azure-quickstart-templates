# Create a SQL Server 2016 Failover Cluster using Windows Server 2016 Storage Spaces Direct (S2D)
This template will create a SQL 2016 Failover Cluster using Windows Server 2016 Storage Spaces Direct (S2D) in an existing VNET and Active Directory environment.

This template creates the following resources:

+	One SQL Server 2016 failover cluster 
    +    Windows Server 2016 
    +    Storage Spaces Direct (S2D)
    +    Premium Managed Disks
+	One Availability Set for the cluster nodes
+   One internal load balancer
+   One Standard Storage Account for the Cloud Witness

## Deploying Sample Templates

If not already in place, you may use <a href="https://github.com/Azure/azure-quickstart-templates/tree/master/active-directory-new-domain-ha-2-dc">this template</a> to deploy a prerequisite infrastructure. 

Click the button below to deploy from the portal:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FMSBrett%2Fazure-quickstart-templates%2Fmaster%2Fsql-server-2016-fci-existing-vnet-and-ad%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>


To deploy via the cli:
```bash
az group deployment create --name deployfci --resource-group sqlfci01 --template-file azuredeploy.json --parameters @azuredeploy.parameters.json
```

## Requirements

+ 	The AD service account used by SQL Server should be created ahead of time by an admin.  
    +    Use the standard SQL Server guidance for these accounts.
+	The VMs are deployed using **premium storage**, which is **strongly** recommended for S2D performance.  
    +    Be sure to select a VM size (DS-series, GS-series) that supports Premium Storage.
+   The default settings deploy 2 data disks per storage node, but this may be increased to up to 64 data disks per node.  
    +    When increasing the # of data disks, be sure to select a VM size that can support the # of data disks you specify.
+ 	The default VM sizes require that you have at least 4 cores of free quota to deploy.
+ 	The image used to create this deployment is:
	+    SQL Server 2016 SP1 and Windows Server 2016 Datacenter Edition - Latest Image
+	To successfully deploy this template ensure:
    +    the subnet the SQL nodes are being deployed to already exists on the specified Azure virtual network
    +    this subnet is defined in Active Directory Sites and Services and bound to a nearby AD site in which Domain Controllers reside.
    +    the DNS settings for the specified virtual network are configured to allow name resolution of the specified AD domain.




SPECIAL THANKS to <a href="https://github.com/robotechredmond">@robotechredmond</a> for the Windows S2D template this is based on!


Tags: ``cluster, ha, storage spaces, storage spaces direct, S2D, windows server 2016, ws2016, sql server 2016, sql2016``
