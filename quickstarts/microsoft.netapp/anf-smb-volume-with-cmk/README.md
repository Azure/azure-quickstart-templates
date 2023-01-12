---
description: This template allows you to create a new Azure NetApp Files resource with a single Capacity pool and single volume configured with SMB protocol.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: anf-smb-volume-with-cmk
languages:
- json
---
# Create new ANF resource with SMB volume

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-smb-volume-with-cmk/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-smb-volume-with-cmk/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-smb-volume-with-cmk/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-smb-volume-with-cmk/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-smb-volume-with-cmk/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-smb-volume-with-cmk/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.netapp%2Fanf-smb-volume-with-cmk%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.netapp%2Fanf-smb-volume-with-cmk%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.netapp%2Fanf-smb-volume-with-cmk%2Fazuredeploy.json)

This template creates everything you need for a new Azure NetApp Files SMB volume with customer-managed key encryption. This includes a Key Vault, Key, Key Vault Private Endpoint, NetApp Account, Capacity Pool, SMB Volume. The NetApp account will be configured for the Active Directory connection, and customer-managed key encryption with Key Vault.

## Prerequisites

Active Directory infrastructure setup with one or more DNS servers from the AD domain (usually the Domain Controllers) available in the same virtual network where you're setting up Azure NetApp Files. If you want to setup an Active Directory test environment, please refer to [Create a new Windows VM and create a new AD Forest, Domain and DC for a quick setup](https://github.com/Azure/azure-quickstart-templates/tree/master/active-directory-new-domain#create-a-new-windows-vm-and-create-a-new-ad-forest-domain-and-dc), then you can work on the vnet that gets created to setup the subnet requirements for ANF.

**Notes**

1. Due to QuickStart template CI requirements, we must provide a prereqs folder which can be ignored or deleted after cloning this repository.
2. Use the same admin username and password you choose in this deployment for next step.

## Sample overview and deployed resources

The following resources are deployed as part of the solution:
1. Key Vault is created 
2. An RSA key of length 4096 is created in the Key Vault
3. Add delegated subnet to the existing VNET (created in the previous prerequisites section).
4. Azure NetApp Files account is deployed with an Active Directory connection.
5. Customer-managed Key encryption is configured.
6. A Private Endpoint for the Key Vault is deployed into existing subnet in VNET.
7. A Capacity Pool is created into the ANF account.
8. A Volume with SMB protocol type is created into the Capacity Pool.

**Notes**: DNS server IP can be obtained from the overview tab in the VNET resource

## Deployment steps

You can click the "Deploy to Azure" button at the beginning of this document.

`Tags: Microsoft.Resources/deployments, Microsoft.Network/virtualNetworks/subnets, Microsoft.NetApp/netAppAccounts, Microsoft.NetApp/netAppAccounts/capacityPools, Microsoft.NetApp/netAppAccounts/capacityPools/volumes`
