@description('Name of L3 domain')
param l3DomainName string

@description('List of L3 domain')
param ISDList object

@description('Array Index value')
param index int

@description('NetworkFabric Id')
param fabricId string

var value = [for item in items(ISDList): item.value]

var internalNetworkCount = length(value[0].internalNetwork)
var externalNetworkCount = length(value[0].externalNetwork)

resource l3IsolationDomains 'Microsoft.ManagedNetworkFabric/l3IsolationDomains@2022-01-15-privatepreview' = {
  name: l3DomainName
  location: resourceGroup().location
  properties: {
    networkFabricId: fabricId
    internal: {
      importRoutePolicyIds: value[index].properties.importRoutePolicyIds
      exportRoutePolicyIds: value[index].properties.exportRoutePolicyIds
    }
    external: {
      importRoutePolicyIds: value[index].properties.importRoutePolicyIds
      exportRoutePolicyIds: value[index].properties.exportRoutePolicyIds
      optionBConfiguration: value[index].properties.optionBConfiguration
    }
  }
  resource internalNetwork 'internalNetworks' = [for i in range(0, internalNetworkCount): {
    name: 'in-${i}'
    properties: {
      vlanId: value[i].internalNetwork[i].properties.vlanId
      mtu: value[i].internalNetwork[i].properties.mtu
      connectedIPv4Subnets: value[i].internalNetwork[i].properties.connectedIPv4Subnets
      connectedIPv6Subnets: value[i].internalNetwork[i].properties.connectedIPv6Subnets
      staticRouteConfiguration: {
        bfdConfiguration: value[i].internalNetwork[i].properties.staticRouteConfiguration.bfdConfiguration
        ipv4Routes: value[i].internalNetwork[i].properties.staticRouteConfiguration.ipv4Routes
        ipv6Routes: value[i].internalNetwork[i].properties.staticRouteConfiguration.ipv6Routes
      }
      bgpConfiguration: {
        bfdConfiguration: value[i].internalNetwork[i].properties.bgpConfiguration.bfdConfiguration
        fabricASN: value[i].internalNetwork[i].properties.bgpConfiguration.fabricASN
        peerASN: value[i].internalNetwork[i].properties.bgpConfiguration.peerASN
        ipv4Prefix: value[i].internalNetwork[i].properties.bgpConfiguration.ipv4Prefix
        ipv6Prefix: value[i].internalNetwork[i].properties.bgpConfiguration.ipv6Prefix
        ipv4NeighborAddress: value[i].internalNetwork[i].properties.bgpConfiguration.ipv4NeighborAddress
        ipv6NeighborAddress: value[i].internalNetwork[i].properties.bgpConfiguration.ipv6NeighborAddress
      }
    }
  }]
  resource externalNetwork 'externalNetworks' = [for i in range(0, externalNetworkCount): {
    name: 'ex-${i}'
    properties: {
      vlanId: value[i].externalNetwork[i].properties.vlanId
      mtu: value[i].externalNetwork[i].properties.mtu
      fabricASN: value[i].externalNetwork[i].properties.fabricASN
      peerASN: value[i].externalNetwork[i].properties.peerASN
      bfdConfiguration: {
        interval: value[i].externalNetwork[i].properties.bfdConfiguration.interval
        multiplier: value[i].externalNetwork[i].properties.bfdConfiguration.multiplier
      }
      primaryIpv4Prefix: value[i].externalNetwork[i].properties.primaryIpv4Prefix
      primaryIpv6Prefix: value[i].externalNetwork[i].properties.primaryIpv6Prefix
      secondaryIpv4Prefix: value[i].externalNetwork[i].properties.secondaryIpv4Prefix
      secondaryIpv6Prefix: value[i].externalNetwork[i].properties.secondaryIpv6Prefix
    }
  }]
}
