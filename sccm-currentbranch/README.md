# Create a System Center Configuration Manager Environment with the Latest General Release

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sccm-currentbranch/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sccm-currentbranch/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sccm-currentbranch/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sccm-currentbranch/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sccm-currentbranch/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sccm-currentbranch/CredScanResult.svg" />&nbsp;

## Description

This template deploys the latest Microsoft Endpoint Configuration Manager (ConfigMgr) general release with following configuration: 

* a new AD domain controller
* a standalone primary site with SQL Server, ADK and ConfigMgr installed. ConfigMgr is the latest general release
* a remote site system server to host managemenent point and distribution point
* a sccm client

Each VM has its own public IP address and is added to a subnet protected with a Network Security Group, which only allows RDP port from Internet. 

Each VM has a private network IP which is for ConfigMgr communication. 

For more information, Visit [Create a Configuration Manager lab in Azure](https://docs.microsoft.com/en-us/configmgr/core/get-started/azure-template)
