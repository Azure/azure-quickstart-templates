# This template will create a SQL Server 2014 SP1 Enterprise edition with Auto Patching feature enabled.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-sql-full-autopatching%2Fazuredeploy.json" target="_blank">
  <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-sql-full-autopatching%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys a **SQL SERVER 2014 SP1 Virtual Machine** solution with all necessary components. It also enable Auto Patching feature.

`Tags: SQL Server, Auto Patching, SQL Server 2014 Enterprise`

## Solution overview and deployed resources

This is an overview of the solution

This template will create a SQL Server 2014 Enterprise edition with Auto Patching feature enabled:

+	A Virtual Network
+	Two Storage Accounts one is used for SQL Server VM, one for SQL Server VM Autobackup 
+ 	One public IP address
+	One network interface
+	One network security group

## SQL Server IaaS Agent

A component that will be installed on the VM when features are enabled and this component is called SQL Server IaaS Agent. It is built in the form of Azure VM Extension meaning all the Azure VM Extension concepts are applicable making it perfect tool for the management of SQL in Azure VMs on scale. You can push this IaaS Agent to a number of VMs at once, you can configure, and you can remove or disable it as well.

## Auto Patching

Many customers told us that they would like to move their patching schedules off business hours. This feature enables you to do exactly this – define the maintenance window that would keep your patch installs in the range you have specified.

When you look on the settings available for the Automated Patching you could find you are familiar with those, because they mimic settings available from the Windows Update Agent (service that drives patching of your Windows machine). Settings are simple and powerful at the same time. All that you need to define to make sure patches are applied when you want is: day of the week, start of the maintenance window, and duration of the maintenance window. It relies on the Windows Update and the Microsoft Update infrastructure and installs any update that matches the ‘Important’ category for the machine.

This feature allows you to patch your Azure Virtual Machines in effective and predictable way even when those VMs are not joined to any domain and not controlled by any patching infrastructure

## Notable Parameters

|Name|Description|Example|
|:---|:---------------------|:---------------|
|sqlAutopatchingDayOfWeek|Patches installed day. Sunday to Saturday for a specific day; Everyday for daily Patches or Never to disable Auto Patching|Monday|
|sqlAutopatchingStartHour|Begin updates hour|22|
|sqlAutopatchingWindowDuration|Patches must be installed within this duration minutes.|60|