# Create a System Center Configuration Manager Technical Preview Lab environment in Azure

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sccm-technicalpreview/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sccm-technicalpreview/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sccm-technicalpreview/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sccm-technicalpreview/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sccm-technicalpreview/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sccm-technicalpreview/CredScanResult.svg" />&nbsp;

## Description

This template deploys the latest System Center Configuration Manager (SCCM) Technical Preview with following configuration: 

* a new AD domain controller. 
* a standalone primary site with SQL Server, ADK and SCCM installed. SCCM is the latest Technical Preview release.
* a remote site system server to host managemenent point and distribution point. 

Each VM has its own public IP address and is added to a subnet protected with a Network Security Group, which only allows RDP from the Internet. 

Each VM has a private network IP which is for SCCM communication. 

