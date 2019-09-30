# Configure ILB and create listener for an existing Always On availability group on SQL Server VMs in Azure

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-aglistener-setup/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-aglistener-setup/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-aglistener-setup/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-aglistener-setup/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-aglistener-setup/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-sql-vm-aglistener-setup/CredScanResult.svg" />&nbsp;

Before deploying the template you must have the following

1. **AlwaysON setup** Always ON setup must exist as created by azure-quickstart-templates/101-sql-vm-ag-setup. This will include the VMs over which the setup was done.
2. **SQL Availability Group** SQL Availability Group must have been created over the Always ON setup. No existing listener should be present for the SQL Availability Group.
3. **LoadBalancer** Internal load balancer in same location as VMs.
4. **CNO permissions** The CNO (COmputer object for Cluster name) should have Create Computer object permissions in the OU it is placed in.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-sql-vm-aglistener-setup%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-sql-vm-aglistener-setup%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

`Tags: Azure, SQL, VirtualMachine, AlwaysON, Listener`

## Solution overview and deployed resources

This deployment will create an AG listener for a SQL Availability Group. This will also setup Load balancer rules corresponding to the Listener.
 Following resources will be created
 - SQL Availability Group Listener for the provided AG.
 - Load balancer rules that will enable Listner to work in Azure.
 - Resource of type "AvailabilityGroupListener" in Microsoft.SqlVirtualMachine resource provider.
 


