# Create WS Failover Cluster and join existing SQL Server Virtual Machines for setting up an Always On availability group

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-ag-setup/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-ag-setup/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-ag-setup/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-ag-setup/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-ag-setup/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-ag-setup/CredScanResult.svg" />&nbsp;

Before deploying the template you must have the following

1. **Domain** Domain must exist in which the underlying Windows Server Failover Cluster will be created
2. **VM** Virtual Machines in same location, joined to the existing domain

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-sql-vm-ag-setup%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-sql-vm-ag-setup%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

`Tags: Azure, SQL, VirtualMachine, AlwaysON, Cluster`

## Solution overview and deployed resources

This deployment will create a WS failover cluster with cloud witness on the provided VMs (in same region) and enable SQL Always ON them. This will enable creating SQL Availability Groups over the created Always ON setup.
Following resources will be created
 - Storage Account to be used as Cloud Witness for failover cluster
 - Resource of type "SqlVirtualMachine" in Microsoft.SqlVirtualMachine resource provider. This corresponds to the existing VirtualMachine
 - Resource of type "SqlVirtualMachineGroup" in Microsoft.SqlVirtualMachine resource provider. This captures details of WS failover cluster setup
 


