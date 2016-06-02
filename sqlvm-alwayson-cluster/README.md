# # Create an Always On Availability Group with SQL Server 2014 replica virtual machines

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
+	One internal load balancer
+	A load balancer rule for ILB for a SQL Listener
+ 	Four public IP addresses for Primary Domain Controller, Secondary Domain Controller, Primary SQL Server and Secondary SQL Server
+	Two VMs as Domain Controllers for a new Forest and Domain
+	Two VMs in a Windows Server Cluster running SQL Server 2014/2012 with an availability group, an additional VM acts as a File Share Witness for the Cluster
+	Two Availability Sets one for the AD VMs, one for the SQL and Witness VMs

## Notes

+ 	File Share Witness and SQL Server VMs are from the same Availability Set and currently there is a constrain for mixing DS-Series machine, DS_v2-Series machine and GS-Series machine into the same Availability Set. If you decide to have DS-Series SQL Server VMs you must also have a DS-Series File Share Witness; If you decide to have GS-Series SQL Server VMs you must also have a GS-Series File Share Witness; If you decide to have DS_v2-Series SQL Server VMs you must also have a DS_v2-Series File Share Witness.

+	The default settings for SQL Server storage are to deploy using **premium storage**, the AD witness uses a P10 Disk and the SQL VMs use P30 disks, these sizes can be changed by changing the relevant variables. In addition there is a P10 Disk used for each VMs OS Disk.

+ 	In default settings for compute require that you have at least 15 cores of free quota to deploy.

+ 	The images used to create this deployment are
	+ 	AD - Latest Windows Server 2012 R2 Image
	+ 	SQL Server - Latest SQL Server 2014 on Windows Server 2012 R2 Image or Latest SQL Server 2012SP1 on Windows Server 2012 R2 Image
	+ 	Witness - Latest Windows Server 2012 R2 Image

+ 	Once deployed access can be gained by the public IP address of Primary Domain Controller

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document.

|Name|Description|Example|
|:---|:---------------------|:---------------|
|adminUsername|The name of the Administrator of the new VMs and Domain|autohaadmin|
|adminPassword|The name of the Administrator of the new VMs and Domain|Password123|
|adVMSize|The size of the AD VMs |Standard_D1|
|sqlVMSize|The size of the SQL VMs |Standard_DS4|
|witnessVMSize|The size of the Witness VM |Standard_DS1|
|domainName|The FQDN of the AD Domain|contoso.local|
|sqlServerServiceAccountUserName|The SQL Server Service Account name|sqlservice|
|sqlServerServiceAccountPassword|The SQL Server Service Account password|Password123|
|sqlStorageAccountName|The name of Sql Server Storage Account|autohastorageaccountsql|
|sqlStorageAccountType|he type of the Sql Server Storage Account created|Premium_LRS|
|dcStorageAccountName|The name of  DC Storage Account|autohastorageaccountdc|
|dcStorageAccountType|The type of the DC Storage Account created|Standard_LRS|
|sqlAutopatchingDayOfWeek|Patches installed day. Sunday to Saturday for a specific day; Everyday for daily Patches or Never to disable Auto Patching|Monday|
|sqlAutopatchingStartHour|Begin updates hour|22|
|sqlAutopatchingWindowDuration|Patches must be installed within this duration minutes.|60|
|workloadType|The Sql VM work load type: GENERAL - general work load; DW - datawear house work load; OLTP - Transactional processing work load|GENERAL|
|numberOfSqlVMDisks|The Sql VM Disk Size : 1TB,2TB,3TB and 4TB|2|
|sqlServerVersion|The Sql Server Version|SQL2016-WS2012R2|

