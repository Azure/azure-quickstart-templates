using 'main.bicep'

param privateEndpointName = 'GEN-PRIVATE-ENDPOINT-NAME'
param privateLinkResourceName = 'GEN-KEYVAULT-NAME'
param targetSubResource = ['vault']
param requestMessage = 'Please approve my private endpoint request'
param virtualNetworkRG = 'GEN-VIRTUAL-NETWORK-RESOURCE-GROUP-NAME'
param virtualNetworkName = 'GEN-VIRTUAL-NETWORK-RESOURCE-NAME'
param subnetName = 'GEN-SUBNET-RESOURCE-NAME'
param privateDnsZoneName = 'privatelink.vaultcore.azure.net'
