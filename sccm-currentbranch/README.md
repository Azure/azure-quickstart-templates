# Create a System Center Configuration Manager Environment with the Latest General Release

## Description

This template deploys the latest System Center Configuration Manager (SCCM) general release with following configuration: 

* a standalone primary site with ADK and SCCM installed. SCCM is the latest general release. 
* a remote site database. 
* a remote site system server to host managemenent point and distribution point. 
* a remote site system server to host other site system roles. 

ExpressRoute is required to communicate with a corporate network. All virtual machines join to existing domains and do not have public IP addresses. 

After provisioning, the domain admin must manually add permissions to the primay site computer account on the "System Management" container. 
