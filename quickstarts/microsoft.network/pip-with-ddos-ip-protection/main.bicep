@description('Name of the Public IP Address resource')
param publicIpName string = 'publicIp'

@description('SKU of the Public IP Address')
@allowed([
  'Basic'
  'Standard'
])
param sku string = 'Standard'

@description('The Allocation Method used for the Public IP Address')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAllocationMethod string = 'Static'

@description('SKU Tier of the Public IP Address')
@allowed([
  'Regional'
  'Global'
])
param tier string = 'Regional'

@description('DDoS Protection Mode of the Public IP Address, use Enabled for DDoS IP Protection')
@allowed([
  'VirtualNetworkInherited'
  'Enabled'
  'Disabled'
])
param ddosProtectionMode string = 'Enabled'

@description('Specify a location for the resources.')
param location string = resourceGroup().location

resource publicIp 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: publicIpName
  location: location
  sku: {
    name: sku
    tier: tier
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    ddosSettings: {
      protectionMode: ddosProtectionMode
    }
  }
}
