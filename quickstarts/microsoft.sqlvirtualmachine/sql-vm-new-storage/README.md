# Create a SQL Server on Virtual Machines with performance optimized storage settings

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-new-storage/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-new-storage/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-new-storage/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-new-storage/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-new-storage/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-new-storage/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sqlvirtualmachine%2Fsql-vm-new-storage%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sqlvirtualmachine%2Fsql-vm-new-storage%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sqlvirtualmachine%2Fsql-vm-new-storage%2Fazuredeploy.json)

## Solution overview and deployed resources

Before deploying the template you must have the **Virtual Network** and **Subnet** in the same location. To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/azure-sql/virtual-machines/windows/create-sql-vm-resource-manager-template) article.

This deployment will create a VM running SQL Server with SQL Data, Log, and Temp DB file on
different drives. The user specifies the number of managed disks used for SQL Data and Log files.
Temp DB would use local SSD (`D:`) and a scheduled task would be created to create Temp DB folder
structure and start default SQL Instance if local SSD is reset during VM restart. SQL Server will
use Windows Authentication.

The following resources are created:

- A Network security group allowing RDP into VM.
- A Public IP address.
- A Virtual Machine joined the existing vNet.
- Managed Disks for SQL Data and Log.
- A SQL Virtual Machine resource attached to the VM.

`Tags: Azure, SQL, VirtualMachine, Performance, StorageConfiguration`
