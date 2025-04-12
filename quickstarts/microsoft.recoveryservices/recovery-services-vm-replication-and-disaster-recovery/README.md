---
description: This template allows you to create Azure Virtual machine site replication disaster recovery.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: recovery-services-vm-replication-and-disaster-recovery
languages:
- bicep
- json
---
# Create Azure VM Replication and Disaster Recovery

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-vm-replication-and-disaster-recovery/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-vm-replication-and-disaster-recovery/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-vm-replication-and-disaster-recovery/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-vm-replication-and-disaster-recovery/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-vm-replication-and-disaster-recovery/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-vm-replication-and-disaster-recovery/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-vm-replication-and-disaster-recovery/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-vm-replication-and-disaster-recovery%2Fazuredeploy.json)

[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-vm-replication-and-disaster-recovery%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-vm-replication-and-disaster-recovery%2Fazuredeploy.json)


## Overview

This template allows you to create Azure Virtual machine replication disaster recovery.

[**Azure Disaster Recovery**](https://learn.microsoft.com/en-us/azure/site-recovery/azure-to-azure-how-to-enable-replication)

## Description

This template allows you to create Azure Virtual machine replication disaster recovery.

## Prerequisite


## Deployment steps
### Steps
1. Run az cli command from the root of the ***microsoft.recoveryservices\recovery-services-vm-replication-and-disaster-recovery directory***.
2. Modify the '***azuredeploy.parameters.json***' as needed and then modify '**// Required parameters**' inside the '***main.bicep***' file
3. Run az command to test deployment of the required resources (***az deployment group create --resource-group 'deployment resource group name' --template-file .\main.bicep --parameters .\azuredeploy.parameters.json --what-if***)
4. If comfortable with the outcome of step 2, run az command to deploy the required resources (***az deployment group create --resource-group 'deployment resource group name' --template-file .\main.bicep --parameters .\azuredeploy.parameters.json***)

## Post deployment configuration

## Architecture

For more information on [**Azure Disaster Recovery**](https://learn.microsoft.com/en-us/azure/site-recovery/azure-to-azure-how-to-enable-replication)

### Deployed Resources

The following resource types will be created as part of this template deployment:

- [**Microsoft.Network/virtualNetworks**](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview)
- [**Microsoft.Network/virtualNetworks/subnets**](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview)
- [**Microsoft.Authorization/roleAssignments**](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments)
- [**Microsoft.Storage/storageAccounts**](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview)
- [**Microsoft.RecoveryServices/vaults**](https://learn.microsoft.com/en-us/azure/site-recovery/site-recovery-overview)
- [**Microsoft.RecoveryServices/vaults/replicationPolicies**](https://learn.microsoft.com/en-us/azure/site-recovery/azure-to-azure-tutorial-enable-replication)
- [**Microsoft.RecoveryServices/vaults/replicationFabrics**](https://learn.microsoft.com/en-us/azure/site-recovery/azure-to-azure-tutorial-enable-replication)
- [**Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers**](https://learn.microsoft.com/en-us/azure/site-recovery/azure-to-azure-tutorial-enable-replication)
- [**Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers/replicationProtectionContainerMappings**](https://learn.microsoft.com/en-us/azure/site-recovery/azure-to-azure-tutorial-enable-replication)
- [**Microsoft.RecoveryServices/vaults/replicationFabrics/replicationNetworks/replicationNetworkMappings**](https://learn.microsoft.com/en-us/azure/site-recovery/azure-to-azure-tutorial-enable-replication)
- [**Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers/replicationProtectedItems**](https://learn.microsoft.com/en-us/azure/site-recovery/azure-to-azure-tutorial-enable-replication)
- [**Microsoft.Network/privateDnsZones**](https://learn.microsoft.com/en-us/azure/dns/private-dns-privatednszone)
- [**Microsoft.Network/privateDnsZones/virtualNetworkLinks**](https://learn.microsoft.com/en-us/azure/dns/private-dns-virtual-network-links)
- [**Microsoft.Network/privateEndpoints**](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview)
- [**Microsoft.Network/privateEndpoints/privateDnsZoneGroups**](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview)


`Tags: network, virtual network, subnet, recovery service vault Microsoft.Network/virtualNetworks, Microsoft.Network/virtualNetworks/subnets, Microsoft.Authorization/roleAssignments, Microsoft.Storage/storageAccounts, Microsoft.RecoveryServices/vaults, Microsoft.RecoveryServices/vaults/replicationPolicies, Microsoft.RecoveryServices/vaults/replicationFabrics, Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers, Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers/replicationProtectionContainerMappings, Microsoft.RecoveryServices/vaults/replicationFabrics/replicationNetworks/replicationNetworkMappings, Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers/replicationProtectedItems, Microsoft.Network/privateDnsZones, Microsoft.Network/privateDnsZones/virtualNetworkLinks, Microsoft.Network/privateEndpoints, Microsoft.Network/privateEndpoints/privateDnsZoneGroups`