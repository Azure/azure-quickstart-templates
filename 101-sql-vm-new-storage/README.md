# Create a SQL Server Virtual Machines with peformance optimized storage settings

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-new-storage/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-new-storage/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-new-storage/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-new-storage/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-new-storage/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-new-storage/CredScanResult.svg)

Before deploying the template you must have the following

1. **Virtual Network** and **Subnet** Virtual Network and Subnet in same location

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-sql-vm-new-storage%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-sql-vm-new-storage%2Fazuredeploy.json)

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


