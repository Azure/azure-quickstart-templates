# Create SQL VMs, failover cluster, availability group and availabiity group listener in Azure


Before deploying the template you must have the following

1. A Virtual Network 
2. A domain controller VM
3. Accounts 
    SQL service
    DomainAdmin - This should have Create Computer object permissions.
4. Subnets for VMs

[![Deploy To Azure](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sqlvirtualmachine%2Fe2e-sql-vm-ag-setup%2Fazuredeploy.json)  


`Tags: Azure, SQL, VirtualMachine, AlwaysON, Listener`

## Solution overview and deployed resources

Create multiple SQL VMs
Join the domain
Storage account (if it doesn't exist already)
Failover cluster
Create Availability Group
Create Availability Group Listener




