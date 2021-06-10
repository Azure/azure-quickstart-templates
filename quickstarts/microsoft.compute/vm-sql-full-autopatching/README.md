# Create an Azure virtual machine running SQL Server 2014 SP1 Enterprise edition with Automated Patching feature enabled.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-sql-full-autopatching/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-sql-full-autopatching/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-sql-full-autopatching/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-sql-full-autopatching/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-sql-full-autopatching/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-sql-full-autopatching/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-sql-full-autopatching%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-sql-full-autopatching%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-sql-full-autopatching%2Fazuredeploy.json)
  

  

## Solution overview

This template provisions a virtual machine with **SQL Server 2014 SP1 running on Windows Server 2012 R2**. It also enable Automated Patching feature.

`Tags: SQL Server, Auto Patching, SQL Server 2014 Enterprise`

This template will also create the following resources:

+	A Virtual Network
+	Two Storage Accounts one is used for SQL Server VM, one for SQL Server VM Autobackup
+ 	One public IP address
+	One network interface
+	One network security group

## Auto Patching

The Automated Patching feature can be used to schedule a patching window during which all Windows and SQL Server updates will take place. More information on this feature can be found [here](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-sql-automated-patching/).

This template can be used to enable or change the configuration of Automated Patching.

If you wish to disable Automated Patching, you must edit *azuredeploy.json* and change "Enable" to be false.

## Notable Parameters

|Name|Description|Example|
|:---|:---------------------|:---------------|
|sqlAutopatchingDayOfWeek|Patches installed day. Sunday to Saturday for a specific day; Everyday for daily Patches or Never to disable Auto Patching|Monday|
|sqlAutopatchingStartHour|Begin updates hour|22|
|sqlAutopatchingWindowDuration|Patches must be installed within this duration minutes.|60|

## SQL Server IaaS Agent extension

Automated Patching is supported in your virtual machine through the SQL Server IaaS Agent extension. This extension must be installed on the VM to be able to use this feature. When you enable Automated Patching on your virtual machine, the extension will be automatically installed. This extension will also report back the latest status of this feature to you. More information on this extension can be found [here](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-sql-server-agent-extension/).


