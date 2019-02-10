# Create System Center Configuration Manager Technical Preview Lab environment in Azure

## Description

This template deploys the latest System Center Configuration Manager (SCCM) Techical Preview with following configuration: 

* a new AD domain controller. 
* a standalone primary site with SQL Server, ADK and SCCM installed. SCCM is the latest Technical Preview release. 
* a remote site system server to host managemenent point and distribution point. 
* a remote site system server to host other site system roles. 

Each VM has its own public IP address and is added to a subnet protected with a Network Security Group, which only allows RDP port from Internet. 

Each VM has a private network IP which is for SCCM communication. 
