@description('This is the name of the ExpressRoute circuit')
param circuitName string

@description('This is the name of the ExpressRoute Service Provider. It must exactly match one of the Service Providers from List ExpressRoute Service Providers API call.')
param serviceProviderName string

@description('This is the name of the peering location and not the ARM resource location. It must exactly match one of the available peering locations from List ExpressRoute Service Providers API call.')
param peeringLocation string

@description('This is the bandwidth in Mbps of the circuit being created. It must exactly match one of the available bandwidth offers List ExpressRoute Service Providers API call.')
param bandwidthInMbps int

@description('Chosen SKU Tier of ExpressRoute circuit. Choose from Premium or Standard SKU tiers.')
@allowed([
  'Standard'
  'Premium'
])
param skuTier string = 'Standard'

@description('Chosen SKU family of ExpressRoute circuit. Choose from MeteredData or UnlimitedData SKU families.')
@allowed([
  'MeteredData'
  'UnlimitedData'
])
param skuFamily string = 'MeteredData'

@description('Location for all resources.')
param location string = resourceGroup().location

resource circuit 'Microsoft.Network/expressRouteCircuits@2021-02-01' = {
  name: circuitName
  location: location
  sku: {
    name: '${skuTier}_${skuFamily}'
    tier: skuTier
    family: skuFamily
  }
  properties: {
    serviceProviderProperties: {
      serviceProviderName: serviceProviderName
      peeringLocation: peeringLocation
      bandwidthInMbps: bandwidthInMbps
    }
  }
}
