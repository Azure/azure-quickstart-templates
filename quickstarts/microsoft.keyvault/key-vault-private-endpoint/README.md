---
description: This sample shows how to use configure a virtual network and private DNS zone to access Key Vault via private endpoint.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: key-vault-private-endpoint
languages:
- json
---
# Connect to a Key Vault via private endpoint

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.keyvault/key-vault-private-endpoint/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.keyvault/key-vault-private-endpoint/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.keyvault/key-vault-private-endpoint/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.keyvault/key-vault-private-endpoint/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.keyvault/key-vault-private-endpoint/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.keyvault/key-vault-private-endpoint/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.keyvault%2Fkey-vault-private-endpoint%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.keyvault%2Fkey-vault-private-endpoint%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.keyvault%2Fkey-vault-private-endpoint%2Fazuredeploy.json)

This sample demonstrates how to create a Linux Virtual Machine in a virtual network that privately accesses a Key Vault and an ADLS Gen 2 blob storage account using two [Azure Private Endpoints](https://docs.microsoft.com/azure/private-link/private-endpoint-overview). Azure Private Endpoint is a network interface that connects you privately and securely to a service powered by Azure Private Link. Private Endpoint uses a private IP address from your virtual network, effectively bringing the service into your virtual network. The service could be an Azure service such as Azure Storage, Azure Cosmos DB, SQL, etc. or your own Private Link Service. For more information, see [What is Azure Private Link?](https://docs.microsoft.com/azure/private-link/private-link-overview). For more information on the DNS configuration of a private endpoint, see [Azure Private Endpoint DNS configuration](https://docs.microsoft.com/azure/private-link/private-endpoint-dns).

## Architecture ##

The following picture shows the architecture and network topology of the sample.

![Architecture](images/architecture.png)

The ARM template deploys the following resources:

- Virtual Network: this virtual network has a single subnet that hosts an Linux (Ubuntu) virtual machine
- Network Security Group: this resource contains an inbound rule to allow the access to the virtual machine on port 22 (SSH)
- The virtual machine is created with a managed identity which is assigned the contributor role at the resource group scope level
- A Public IP for the Linux virtual machine
- The NIC used by the Linux virtual machine that makes use of the Public IP
- A Linux virtual machine used for testing the connectivity to the storage account via a private endpoint
- A Log Analytics workspace used to monitor the health status of the Linux virtual machine
- A Key Vault with 3 sample secrets
- A blob storage account used to store the boot diagnostics logs of the virtual machine as blobs
- A Private DNS Zone for Key Vault private endpoints
- A Private DNS Zone for blob storage account private endpoints
- A Private Endpoint to let the virtual machine access Key Vault via a private address
- A Private Endpoint to let the virtual machine access the Blob Storage Account via a private address
- A Private DNS Zone Group for the Key Vault private endpoint
- A Private DNS Zone Group for the Blob Storage Account private endpoint

The [PrivateDnsZoneGroups](https://docs.microsoft.com/azure/templates/microsoft.network/privateendpoints/privateDnsZoneGroups) resource type establishes a relationship between the Private Endpoint and the Private the privatelink.* DNS zone for the name resolution of the fully qualified name of the resource referenced by the Private Endpoint.

- When creating a Private Endpoint, the related A record will automatically be created in the target Private DNS Zone with the private IP address of the network interface associated to the Private Endpoint and the name of the Azure resource referenced by the Private Endpoint
- When deleting a Private Endpoint, the related A record gets automatically deleted from the corresponding Private DNS Zone.

The ARM template uses the [Azure Custom Script Extension](https://docs.microsoft.com/azure/virtual-machines/extensions/custom-script-linux) to download and run the following [Bash script](scripts/test-key-vault-private-endpoint.sh) on the virtual machine. The script performs the following steps:

- Validates the parameters received by the Custom Script extension
- Updates the system and upgrades software packages
- Runs the nslookup command against the public URL of the Key Vault to verify that this gets resolved to a private address
- Runs the nslookup command against the public URL of the Storage Account namespace to verify that this gets resolved to a private address
- Installs Azure CLI
- Logins using the system-assigned managed identity of the virtual machine
- Retrieves secrets from Key Vault

## Deployment ##

The following figure shows the resources deployed by the ARM template in the target resource group.

![Resource Group](images/resourcegroup.png)

## Testing ##

If you open an ssh session to the Linux virtual machine and manually run the nslookup command, you should see an output like the following:

![Architecture](images/nslookup.png)

`Tags: Microsoft.KeyVault/vaults, Microsoft.KeyVault/vaults/secrets, Microsoft.Storage/storageAccounts, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, SystemAssigned, Microsoft.Compute/virtualMachines/extensions, CustomScript, OmsAgentForLinux, DependencyAgentLinux, Microsoft.OperationalInsights/workspaces, dataSources, Microsoft.Network/privateDnsZones, Microsoft.Network/privateDnsZones/virtualNetworkLinks, Microsoft.Network/privateEndpoints, Microsoft.Network/privateEndpoints/privateDnsZoneGroups`
