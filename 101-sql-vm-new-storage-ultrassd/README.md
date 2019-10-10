# Create a SQL Virtual Machines with Performance-Optimized Storage Settings using Ultra SSD For SQL Log Files

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-new-storage-ultrassd/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-new-storage-ultrassd/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-new-storage-ultrassd/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-new-storage-ultrassd/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-new-storage-ultrassd/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-new-storage-ultrassd/CredScanResult.svg" />&nbsp;

Before deploying the template you must have the following

1. **Virtual Network** and **Subnet** in same location
2. Follow this [this documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/disks-enable-ultra-ssd) to **determine your availability zone**.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-sql-vm-new-storage-ultrassd%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-sql-vm-new-storage-ultrassd%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

`Tags: Azure, SQL, VirtualMachine, Performance, StorageConfiguration, UltraSSD`

## Solution overview and deployed resources

This deployment will create a VM running SQL Server with SQL Data, Log and Temp DB file on different drives.
The user specifies the number of managed disks used for SQL Data files. Ultra SSD will be used for SQL Log files and the user will specify the disk size and expected maximum IOPS and throughput.
TempDb will use the local SSD and a scheduled task will be used to create the TempDB folder structure and start the default SQL Instance if the local SSD is reset during VM restart.

SQL Server will use Windows Authentication.

The following resources will be created

- A Network security group allowing RDP into VM
- A Public IP address
- A Virtual Machine joined the existing vNet
- Managed Disks for SQL Data
- An Ultra SSD Disk for SQL Log
- A Sql Virtual Machine resource attached to the VM

## Note

- *This VM will have Ultra SSD compatibility enabled and there will be a reservation charge if no Ultra SSD Disk is attached to the VM.*

