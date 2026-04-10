using 'main.bicep'

param privateLinkResourceName = 'GEN-KEYVAULT-NAME'
param targetSubResource = ['vault']
param requestMessage = 'Please approve my private endpoint request'
param virtualNetworkName = 'GEN-VNET-NAME'
param virtualNetworkAddressSpace = '10.0.0.0/16'
param subnetName = 'GEN-VNET-SUBNET-NAME'
param subnetAddressPrefix = '10.0.0.0/24'
