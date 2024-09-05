using 'main.bicep'

param privateLinkResourceName = 'GEN-KEYVAULT-NAME'
param targetSubResource = ['vault']
param requestMessage = 'Please approve my private endpoint request'
param virtualNetworkRG = 'GEN-VNET-RESOURCEGROUP-NAME'
param virtualNetworkName = 'GEN-VNET-NAME'
param subnetName = 'GEN-VNET-SUBNET-NAME'
param privateDnsZoneName = 'privatelink.vaultcore.azure.net'
