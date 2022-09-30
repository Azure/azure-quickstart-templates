param name string

@allowed([
  'Basic'
  'Standard'
])
param sku string = 'Standard'

@allowed([
  'Dynamic'
  'Static'
])
param publicIPAllocationMethod string = 'Static'

@allowed([
  'Regional'
  'Global'
])
param tier string = 'Regional'

@allowed([
  'VirtualNetworkInherited'
  'Enabled'
  'Disabled'
])
param ddosProtectionMode string = 'Enabled'

@description('Specify a location for the resources.')
param location string = resourceGroup().location

resource name_resource 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: name
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