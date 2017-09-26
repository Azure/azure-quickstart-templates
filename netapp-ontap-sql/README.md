# NetApp ONTAP Cloud on Azure with SQL 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fnetapp-ontap-sql%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fnetapp-ontap-sql%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a> 
<br><br>

<!-- TOC -->

1. [Solution Overview](#solution-overview)
2. [Template Solution Architecture ](#template-solution-architecture)
3. [Licenses and Costs ](#licenses-and-costs)
4. [Prerequisites](#prerequisites)
5. [Deployment Steps](#deployment-steps)
6. [Deployment Guide](#deployment-guide)
7. [Deployment Time](#deployment-time)
8. [Support](#support)


<!-- /TOC -->

## Solution Overview 

NetApp ONTAP Cloud, the leading enterprise storage operating system, is deployed using OnCommand Cloud Manager to deliver secure, proven NFS, CIFS and iSCSI data management for Azure cloud storage. A software-only storage service running the ONTAP storage operating system, ONTAP Cloud combines data control with enterprise-class storage features—such as data deduplication and compression—to minimize your Azure storage footprint. Take snapshots of your data without requiring additional storage or impacting your application’s performance. ONTAP Cloud can tie your cloud storage to your data center using the leading NetApp replication protocol, SnapMirror technology. OnCommand Cloud Manager handles deployment and management of ONTAP Cloud, giving you a simple point-and-click environment to manage your storage and ease control of your data.

The features of ONTAP Cloud include:

- Storage efficiencies that enable you to use less underlying storage capacity for your data needs
- Instant backup and recovery for data of all sizes
- Space-efficient, intuitive, bi-directional data transfer
- Instant, writable data clones that consume no additional storage capacity
- Ability to use multiple protocols (NFS, CIFS, and iSCSI) from the same storage system, at the same time  

This Quickstart deploys a production ready and secure environment which includes NetApp ONTAP Cloud, OnCommand Manager, backend SQL Server and Jump Server for accessing systems via RDP(Remote Desktop). SQL Server is configured with NetApp ONTAP Cloud volumes to store its databases and logs. The overall environment is built using ARM templates and follows standard recommended architecture and security best practices.

## Template Solution Architecture 

This template will deploy: 

-	5 Storage Accounts
-	One Virtual Network with two subnets
-	2 Public IP’s, one for OnCommand Manager and one for the Jump VM
-	One OnCommand Cloud Manager (BYOL)(for ONTAP Cloud)
-	One Windows Server 2012 R2 VM.
-	One SQL Server 2014 SP2 Enterprise on Windows Server 2012 R2 VM.
-	One NetApp ONTAP Cloud VM
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/netapp-ontap-sql/Images/netapp-architecture.png"/>

## Licenses and Costs 

This NetApp ONTAP Cloud is the PAYGO model and doesn't require the user to license it, it will be licensed automatically after the instance is launched first time and user will be charged hourly. Click [here]( https://azuremarketplace.microsoft.com/en-us/marketplace/apps/netapp.netapp-ontap-cloud?tab=Overview) for pricing details.

## Prerequisites 

Azure Subscription with specified payment method (NetApp ONTAP cloud is a market place product and requires payment method to be specified in Azure Subscription)

You also need to create an Azure AD Application with required permissions in your Azure subscription before deploying this template. Please see [deployment guide]( https://github.com/Azure/azure-quickstart-templates/blob/master/netapp-ontap-sql/Images/NetApp-ONTAP-Cloud-on-Azure.pdf) for more details.

## Deployment Steps  

Build your NetApp ONTAP environment on Azure in a few simple steps:
- Create an Active Directory Application.
- Create an Application Key
- Assigning the Cloud Manager role to AD application
- Enable programmatic deployment for NetApp ONTAP Cloud for Azure – (PAYGo)
- Launch the Template by click on Deploy to Azure button.  
- Fill in all the required parameter values. Accept the terms and condition and click on Purchase. 

## Deployment Guide

For the detailed steps of deployment please refer the deployment guide from  [here]( https://github.com/Azure/azure-quickstart-templates/blob/master/netapp-ontap-sql/Images/NetApp-ONTAP-Cloud-on-Azure.pdf)

## Deployment Time  

The deployment takes around 40 to 45 minutes. 

## Support 

For any support related questions, issues or customization requirements, please contact ng-azure-quickstarts@netapp.com
