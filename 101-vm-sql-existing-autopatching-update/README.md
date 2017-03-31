# Configure Automated Patching on any existing Azure virtual machine.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-sql-existing-autopatching-update%2Fazuredeploy.json" target="_blank">
  <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-sql-existing-autopatching-update%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Solution overview

This template can be used for any Azure virtual machine, whether it is running SQL Server or not. If your virtual machine is running SQL Server, it must be SQL Server 2012 or newer.

All resources used in this template must be ARM resources.

## Automated Patching

The Automated Patching feature can be used to schedule a patching window during which all Windows and SQL Server updates will take place. More information on this feature can be found [here](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-sql-automated-patching/).

This template can be used to enable or change the configuration of Automated Patching.

If you wish to disable Automated Patching, you must edit *azuredeploy.json* and change "Enable" to be false.

## Notable Parameters

|Name|Description|Example|
|:---|:---------------------|:---------------|
|sqlAutopatchingDayOfWeek|Scheduled day during which patching can take place. Allowed values: Sunday - Saturday, or Everyday or Never to disable Auto Patching|Monday|
|sqlAutopatchingStartHour|The hour during the specified day(s) that patching can begin. This is based on your virtual machine's local time. Allowed values (24 hour clock): 0-23|22|
|sqlAutopatchingWindowDuration|Length of time following the start hour during which patching and restarts are allowed to take place. When this window ends, patching will stop and will not continue until the next patching window. Allowed values (in minutes): 30, 60, 90, 120, 180|60|

## SQL Server IaaS Agent extension

Automated Patching is supported in your virtual machine through the SQL Server IaaS Agent extension. This extension must be installed on the VM to be able to use this feature. When you enable Automated Patching on your virtual machine, the extension will be automatically installed. This extension will also report back the latest status of this feature to you. More information on this extension can be found [here](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-sql-server-agent-extension/).
