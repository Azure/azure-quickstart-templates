# Create a SQL Server Virtual Machines with peformance optimized storage settings


Before deploying the template you must have the following

1. **Virtual Network** and **Subnet** a Virtual Network within the same resource group and a subnet must exist

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-sql-vm-new-storage%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-sql-vm-new-storage%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

`Tags: Azure, SQL, VirtualMachine, Performance, StorageConfiguration`

## Solution overview and deployed resources

This deployment will create a VM running SQL Server with SQL Data, Log and Temp DB file seperate into different drive. User specified the amount of managed disks for SQL Data and Log and SQL TempDb would use local SSD. SQL Server Authentication would use Windows Authentication

Following resources will be created
 - A Network security group allowing RDP into VM
 - A Public IP address
 - A Virtual Machine joined the exisiting vNet
 - Managed Disks for Sql Data and Log 
 - A Sql Virtual Machine resource attached to the VM
