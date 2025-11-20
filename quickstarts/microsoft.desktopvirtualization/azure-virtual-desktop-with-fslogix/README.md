---
description: This template allows you to create Azure Virtual Desktop resources such as host pool, application group, workspace, FSLogix storage account, file share, recovery service vault for file share backup a test session host, its extensions with Microsoft Entra ID join pr Active directory domain join.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: azure-virtual-desktop-with-fslogix
languages:
- bicep
- json
---
# Create AVD with FSLogix and AD DS Join

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/azure-virtual-desktop-with-fslogix/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/azure-virtual-desktop-with-fslogix/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/azure-virtual-desktop-with-fslogix/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/azure-virtual-desktop-with-fslogix/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/azure-virtual-desktop-with-fslogix/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/azure-virtual-desktop-with-fslogix/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/azure-virtual-desktop-with-fslogix/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.desktopvirtualization%2Fazure-virtual-desktop-with-fslogix%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.desktopvirtualization%2Fazure-virtual-desktop-with-fslogix%2Fazuredeploy.json)


## Overview

This template allows you to create Azure Virtual Desktop resources such as host pool, application group, workspace, FSLogix storage account, file share, recovery service vault for file share backup a test session host, its extensions with Microsoft Entra ID join pr Active directory domain join. This is tested with a new azure azure Vnet/subnet.

[**Azure Virtual Desktop**](https://learn.microsoft.com/en-us/azure/virtual-desktop/overview)

## Description

This template allows you to create Azure Virtual Desktop resources such as host pool, application group, workspace, FSLogix storage account, file share, recovery service vault for file share backup a test session host, its extensions with Microsoft Entra ID join pr Active directory domain join. This is tested with a new azure azure Vnet/subnet.

## Prerequisite

Inside your Active directory domain controller server, run the powershell script '***preconfiguration.ps1***' for creating Active directory parent OU and child OUs for Azure virtual desktop.

> [!NOTE] Ignore this step if you will be leveraging on the existing OUs in your AD DS.

## Deployment steps
### Steps
1. Run az cli command from the root of the ***microsoft.desktopvirtualization\azure-virtual-desktop-with-fslogix directory***.
2. Modify the '***azuredeploy.parameters.json***' as needed and then modify '**// Required parameters**' inside the '***main.bicep***' file
3. Run az command to test deployment of the required resources (***az deployment group create --resource-group 'deployment resource group name' --template-file .\main.bicep --parameters .\azuredeploy.parameters.json --what-if***)
4. If comfortable with the outcome of step 2, run az command to deploy the required resources (***az deployment group create --resource-group 'deployment resource group name' --template-file .\main.bicep --parameters .\azuredeploy.parameters.json***)

## Post deployment configuration

### Steps
1. Install AZ PowerShell module inside your domain controller server. Click the link for the installation steps. [**Install Azure PowerShell on Windows**](https://learn.microsoft.com/en-us/powershell/azure/install-azps-windows?view=azps-12.4.0&tabs=windowspowershell&pivots=windows-psgallery)
2. Once deployment is completed, run the '***postconfiguration.ps1***' inside your domain controller server. Please follow the instruction in the file and provide the appropriate parameters before the script is executed.
3. Please restart all the virtual machine session hosts for FSLogix to take effect with profile container.

## Architecture


For more information on **Azure Virtual Desktop** with FSLogix see article [**Create a profile container for a host pool using a file share**](https://learn.microsoft.com/en-us/azure/virtual-desktop/create-host-pools-user-profile)

### Deployed Resources

The following resource types will be created as part of this template deployment:

- [**Microsoft.Network/virtualNetworks**](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview)
- [**Microsoft.Network/virtualNetworks/subnets**](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview)
- [**Microsoft.Authorization/roleAssignments**](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments)
- [**Microsoft.DesktopVirtualization/hostPools**](https://learn.microsoft.com/en-us/azure/virtual-desktop/deploy-azure-virtual-desktop?tabs=portal)
- [**Microsoft.DesktopVirtualization/applicationGroups**](https://learn.microsoft.com/en-us/azure/virtual-desktop/deploy-azure-virtual-desktop?tabs=portal)
- [**Microsoft.DesktopVirtualization/workspaces**](https://learn.microsoft.com/en-us/azure/virtual-desktop/deploy-azure-virtual-desktop?tabs=portal)
- [**Microsoft.Network/networkInterfaces**](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface?tabs=azure-portal)
- [**Microsoft.Compute/virtualMachines**](https://learn.microsoft.com/en-us/azure/virtual-machines/overview)
- [**Microsoft.Compute/virtualMachines/extensions**](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/overview)
- [**Microsoft.Storage/storageAccounts**](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview)
- [**Microsoft.Storage/storageAccounts/fileServices**](https://learn.microsoft.com/en-us/azure/storage/files/storage-how-to-create-file-share?tabs=azure-portal)
- [**Microsoft.Storage/storageAccounts/fileServices/shares**](https://learn.microsoft.com/en-us/azure/storage/files/storage-how-to-create-file-share?tabs=azure-portal)
- [**Microsoft.RecoveryServices/vaults**](https://learn.microsoft.com/en-us/azure/backup/backup-azure-recovery-services-vault-overview)
- [**Microsoft.RecoveryServices/vaults/backupPolicies**](https://learn.microsoft.com/en-us/azure/backup/backup-azure-vms-enhanced-policy?tabs=azure-portal)
- [**Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers**](https://learn.microsoft.com/en-us/azure/backup/backup-azure-files?tabs=backup-center)
- [**Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems**](https://learn.microsoft.com/en-us/azure/backup/backup-azure-files?tabs=backup-center)
- [**Microsoft.Network/privateDnsZones**](https://learn.microsoft.com/en-us/azure/dns/private-dns-privatednszone)
- [**Microsoft.Network/privateDnsZones/virtualNetworkLinks**](https://learn.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links)
- [**Microsoft.Network/privateEndpoints**](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview)
- [**Microsoft.Network/privateEndpoints/privateDnsZoneGroups**](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview)


`Tags: network, virtual network, subnet, host pool, application group, workspace, virtual machine network interface, virtual machine, virtual machine extensions, Microsoft.Network/virtualNetworks, Microsoft.Network/virtualNetworks/subnets, Microsoft.Authorization/roleAssignments, Microsoft.DesktopVirtualization/hostPools, Microsoft.DesktopVirtualization/applicationGroups, Microsoft.DesktopVirtualization/workspaces, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, Microsoft.Storage/storageAccounts, Microsoft.Storage/storageAccounts/fileServices, Microsoft.Storage/storageAccounts/fileServices/shares, Microsoft.RecoveryServices/vaults, Microsoft.RecoveryServices/vaults/backupPolicies, Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers, Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems, Microsoft.Network/privateDnsZones, Microsoft.Network/privateDnsZones/virtualNetworkLinks, Microsoft.Network/privateEndpoints, Microsoft.Network/privateEndpoints/privateDnsZoneGroups`