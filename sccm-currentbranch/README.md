# Create a System Center Configuration Manager Environment with the Latest General Release

## Description

This template deploys the latest System Center Configuration Manager (SCCM) general release with following configuration: 

* a new AD domain controller. 
* a standalone primary site with SQL Server, ADK and SCCM installed. SCCM is the latest general release. 
* a remote site system server to host managemenent point and distribution point. 
* a sccm client.

Each VM has its own public IP address and is added to a subnet protected with a Network Security Group, which only allows RDP port from Internet. 

Each VM has a private network IP which is for SCCM communication. 