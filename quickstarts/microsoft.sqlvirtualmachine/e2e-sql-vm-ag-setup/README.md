# End-to-End provision of Multi Subnet Availability Group for SQL Servers running on Azure Virtual Machines. 

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-ag-setup/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-ag-setup/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-ag-setup/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-ag-setup/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-ag-setup/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-ag-setup/CredScanResult.svg)

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sqlvirtualmachine%2Fe2e-sql-vm-ag-setup%2Fazuredeploy.json)  

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sqlvirtualmachine%2Fe2e-sql-vm-ag-setup%2Fazuredeploy.json)

`Tags: Azure, SQL, VirtualMachine, AlwaysON, Listener`

## Solution overview and deployed resources

This is an overview of the solution
1. Creates availability set
2. Creates multiple SQL VMs in availability set, each vm in a different subnet (Maximum number of VMs for this solution is 9, we recommend VM count > 2)
3. Join SQL VMs to the domain 
4. Creates Storage account (if it doesn't exist already) which will act as Witness for Failover Cluster
5. Creates Windows server Failover cluster
6. Runs necessary checks such as TEST Cluster to ensure the health of creation of cluster 
7. Creates Availability Group 
8. Creates Availability Group Listener

Best practices that were considered for this solution:
1. This solution deploys SQL Server VMs to multiple subnets,thereby avoiding the dependency on an Azure Load Balancer or a distributed network name (DNN) to route traffic to your HADR solution.
2. Use a single NIC per cluster node.

The following resources are deployed as part of the solution:
1. AvailabilitySet
2. Virtual machine 
3. SQL virtual machine 
4. Network interface 
5. Network security group 
6. Disk 
7. Storage account 
8. Failovercluster - Microsoft.sqlvirtualmachine/sqlvirtualmachinegroups 

## Prerequisites

RBAC permissions required to deploy ARM template: Virtual machine contributor

Before deploying the template you must have the following:
1. A Virtual Network 
2. A domain controller VM in the same virtual network
3. Accounts 
    SQL service
    DomainAdmin - This should have Create Computer object permissions.
4. Subnets for VMs. Refer https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-subnet#add-a-subnet

Notes: 
1. This [template] (https://github.com/Azure/azure-quickstart-templates/tree/master/application-workloads/active-directory/active-directory-new-domain) is helpful for above steps 1,2,3
2. New resources should be in the same region as virtual network
3. Tutorial for a manual solution of this [template] (https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/availability-group-manually-configure-prerequisites-tutorial-multi-subnet?msclkid=7c862b87b6c711ecae6e6866d0d72ae8&view=azuresql)

## Deployment Steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

Template can be deployed with multiple clients : Portal, CLI, Powershell, Rest API, Cloud Shell.
Please refer https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-portal
