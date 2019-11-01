# Create a SQL Server Virtual Machines with peformance optimized storage settings

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-new-storage/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-new-storage/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-new-storage/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-new-storage/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-new-storage/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-new-storage/CredScanResult.svg" />&nbsp;

Before deploying the template you must have the following

1. **Virtual Network** and **Subnet** Virtual Network and Subnet in same location

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-sql-vm-new-storage%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-sql-vm-new-storage%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

`Tags: Azure, SQL, VirtualMachine, Performance, StorageConfiguration`

## Solution overview and deployed resources

This deployment will create a VM running SQL Server with SQL Data, Log and Temp DB file on different drives.
The user specifies the number of managed disks used for SQL Data and Log files.
TempDb would use local SSD (D:) and a scheduled task would be created to create TempDB folder structure and start default SQL Instance if local SSD is reset during VM restart. 
SQL Server will use Windows Authentication.

The following resources will be created
 - A Network security group allowing RDP into VM
 - A Public IP address
 - A Virtual Machine joined the existing vNet
 - Managed Disks for Sql Data and Log 
 - A Sql Virtual Machine resource attached to the VM

