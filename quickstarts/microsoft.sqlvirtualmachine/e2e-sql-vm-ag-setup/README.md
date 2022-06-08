# Create SQL VMs, failover cluster, availability group and availabiity group listener in Azure

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sqlvirtualmachine%2Fe2e-sql-vm-ag-setup%2Fazuredeploy.json)  

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sqlvirtualmachine%2Fe2e-sql-vm-ag-setup%2Fazuredeploy.json)

`Tags: Azure, SQL, VirtualMachine, AlwaysON, Listener`

## Solution overview and deployed resources

This is an overview of the solution

Create multiple SQL VMs
Join the domain
Storage account (if it doesn't exist already)
Failover cluster
Create Availability Group
Create Availability Group Listener

The following resources are deployed as part of the solution:

AvailabilitySet
Virtual machine 
SQL virtual machine 
Network interface 
Network security group 
Disk 
Storage account 
Failovercluster - Microsoft.sqlvirtualmachine/sqlvirtualmachinegroups 

## Prerequisites

Before deploying the template you must have the following

1. A Virtual Network 
2. A domain controller VM
3. Accounts 
    SQL service
    DomainAdmin - This should have Create Computer object permissions.
4. Subnets for VMs

## Deployment Steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

Template can be deployed with multiple clients : Portal, CLI, Powershell, Rest API, Cloud Shell.

Please refer https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-portal
