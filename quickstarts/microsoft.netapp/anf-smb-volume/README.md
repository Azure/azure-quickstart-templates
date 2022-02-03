# Create Azure Netapp Files resource with SMB volume

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-smb-volume/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-smb-volume/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-smb-volume/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-smb-volume/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-smb-volume/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.netapp/anf-smb-volume/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.netapp%2Fanf-smb-volume%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.netapp%2Fanf-smb-volume%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.netapp%2Fanf-smb-volume%2Fazuredeploy.json)

This template creates Azure NetApp Files account along with setting up a capacity pool to enable you to create SMB volume within it, deployed together with Active Directory connection.

## Prerequisites

Active Directory infrastructure setup with one or more DNS servers from the AD domain (usually the Domain Controllers) available in the same virtual network where you're setting up Azure NetApp Files. If you want to setup an Active Directory test environment, please refer to [Create a new Windows VM and create a new AD Forest, Domain and DC for a quick setup](https://github.com/Azure/azure-quickstart-templates/tree/master/active-directory-new-domain#create-a-new-windows-vm-and-create-a-new-ad-forest-domain-and-dc), then you can work on the vnet that gets created to setup the subnet requirements for ANF.

**Notes**

1. Due to QuickStart template CI requirements, we must provide a prereqs folder which can be ignored or deleted after cloning this repository.
1. Use the same admin username and password you choose in this deployment for next step.

## Sample overview and deployed resources

The following resources are deployed as part of the solution:
1. Add delegated subnet to the existing VNET (created in the previous prerequisites section).
1. Azure NetApp Files account is deployed.
1. Active Directory connection is created.
1. A Capacity Pool is created into the ANF account.
1. A Volume with SMB protocol type is created into the Capacity Pool.

**Notes**: DNS server IP can be obtained from the overview tab in the VNET resource

## Deployment steps

You can click the "Deploy to Azure" button at the beginning of this document.
