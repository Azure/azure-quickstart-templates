# Create a System Center Configuration Manager environment with the latest general release

## Description

This template deploys the latest System Center Configuration Manager (SCCM) general release with following configuration: 

* a standalone primary site with ADK and SCCM installed. SCCM is the latest general release. 
* a remote site database. 
* a remote site system server to host managemenent point and distribution point. 
* a remote site system server to host other site system roles. 

ExpressRoute is must to have to communicate to corp network. All virtual machines join to existing domains. Virtual machines aren't associated with public IP address. 

After provision, in domain controller, admin need manually add permissions to the primay site computer account on "System Management" container. 

