# Create a Microsoft Endpoint Configuration Manager Technical Preview Lab environment in Azure

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sccm-technicalpreview/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sccm-technicalpreview/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sccm-technicalpreview/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sccm-technicalpreview/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sccm-technicalpreview/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/sccm-technicalpreview/CredScanResult.svg" />&nbsp;

## Description

This template deploys the latest Microsoft Endpoint Configuration Manager (ConfigMgr) Technical Preview with following configuration: 

* a new AD domain controller. 
* a standalone primary site with SQL Server, ADK and ConfigMgr installed. ConfigMgr is the latest Technical Preview release.
* a remote site system server to host managemenent point and distribution point. 

Each VM has its own public IP address and is added to a subnet protected with a Network Security Group, which only allows RDP from the Internet. 

Each VM has a private network IP which is for ConfigMgr communication. 

For more information, Visit [Create a Configuration Manager lab in Azure](https://docs.microsoft.com/en-us/configmgr/core/get-started/azure-template)
