# Solution name

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsqlvm-alwayson-cluster%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsqlvm-alwayson-cluster%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>


This template deploys a **SQL SERVER AlwaysOn Cluster**. The **SQL SERVER AlwaysOn Cluster** is a **SQL Server AlwaysOn Availability Group for high availability of SQL Server. It provisions 2 SQL Server replicas (primary and secondary) and 1 witness file share in a Windows Cluster. It also provisions 2 Domain Controller replicas (primary and secondary). In addition, it configures an Availability Group Internal Listener for clients to connect to the primary SQL Server replica. The diagram below shows the deployment according to the default settings of this feature. The deployment will look slightly different depending on the settings specified by the user.
This template deploys an AlwaysOn Availability Group such that after deployment is complete, the user has a fully available AG. The template implements performance, security, and availability best practices.**

`Tags: SQL Server, AlwaysOn, High Availability, Cluster `

## Solution overview and deployed resources

This is an overview of the solution

This template will create a SQL Server 2014/2012 Always On Availability Group using the PowerShell DSC Extension it creates the following resources:

+	A Virtual Network
+	Four Storage Accounts one is used for AD VMs, one for SQL Server VMs , one for Failover Cluster File Share Witness and one for Deployment diagnostics
+	one external and one internal load balancers
+	A NAT Rule to allow RDP to one VM which can be used as a jumpbox, a load balancer rule for ILB for a SQL Listener
+ 	One public IP addresses for RDP access
+	Two VMs as Domain Controllers for a new Forest and Domain
+	Two VMs in a Windows Server Cluster running SQL Server 2014/2012 with an availability group, an additional VM acts as a File Share Witness for the Cluster
+	Two Availability Sets one for the AD VMs, one for the SQL and Witness VMs

## Notes

+	The default settings for SQL Server storage are to deploy using **premium storage**, the AD witness uses a P10 Disk and the SQL VMs use P30 disks, these sizes can be changed by changing the relevant variables. In addition there is a P10 Disk used for each VMs OS Disk.

+ 	In default settings for compute require that you have at least 15 cores of free quota to deploy.

+ 	The images used to create this deployment are
	+ 	AD - Latest Windows Server 2012 R2 Image
	+ 	SQL Server - Latest SQL Server 2014 on Windows Server 2012 R2 Image or Latest SQL Server 2012SP1 on Windows Server 2012 R2 Image
	+ 	Witness - Latest Windows Server 2012 R2 Image

+ 	Once deployed access can be gained by the public IP address of Primary Domain Controller

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document.
