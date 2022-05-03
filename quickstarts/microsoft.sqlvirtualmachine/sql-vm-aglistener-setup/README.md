# Configure ILB and create listener for an existing Always On availability group on SQL Server VMs in Azure

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-aglistener-setup/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-aglistener-setup/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-aglistener-setup/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-aglistener-setup/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-aglistener-setup/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-aglistener-setup/CredScanResult.svg)

Before deploying the template you must have the following

1. **AlwaysON setup** Always ON setup must exist as created by azure-quickstart-templates/101-sql-vm-ag-setup. This will include the VMs over which the setup was done.
2. **SQL Availability Group** SQL Availability Group must have been created over the Always ON setup. No existing listener should be present for the SQL Availability Group.
3. **LoadBalancer** Internal load balancer in same location as VMs.
4. **CNO permissions** The CNO (COmputer object for Cluster name) should have Create Computer object permissions in the OU it is placed in.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sqlvirtualmachine%2Fsql-vm-aglistener-setup%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sqlvirtualmachine%2Fsql-vm-aglistener-setup%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sqlvirtualmachine%2Fsql-vm-aglistener-setup%2Fazuredeploy.json)

`Tags: Azure, SQL, VirtualMachine, AlwaysON, Listener`

## Solution overview and deployed resources

This deployment will create an AG listener for a SQL Availability Group. This will also setup Load balancer rules corresponding to the Listener.
 Following resources will be created
 - SQL Availability Group Listener for the provided AG.
 - Load balancer rules that will enable Listner to work in Azure.
 - Resource of type "AvailabilityGroupListener" in Microsoft.SqlVirtualMachine resource provider.
 



