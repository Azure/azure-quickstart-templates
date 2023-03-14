@description('Name of L3 domain')
param l3DomainName string

@description('Azure Region for deployment of the Network Fabric Controller and associated resources')
param location string

@description('List of L3 domain')
param ISDList object

@description('Array Index value')
param index int

@description('NetworkFabric Id')
param fabricId string

var value = [for item in items(ISDList): item.value]

var internalNetworkCount = length(value[index].internalNetwork)
var externalNetworkCount = length(value[index].externalNetwork)

resource l3IsolationDomains 'Microsoft.ManagedNetworkFabric/l3IsolationDomains@2023-02-01-preview' = {
  name: l3DomainName
  location: location
  properties: {
    networkFabricId: fabricId
    redistributeConnectedSubnets: value[index].properties.redistributeConnectedSubnets != '' ? value[index].properties.redistributeConnectedSubnets : null
    redistributeStaticRoutes: value[index].properties.redistributeStaticRoutes != '' ? value[index].properties.redistributeStaticRoutes : null
    aggregateRouteConfiguration: value[index].properties.aggregateRouteConfiguration != {} ? {
      ipv4Routes: value[index].properties.aggregateRouteConfiguration.ipv4Routes != [] ? value[index].properties.aggregateRouteConfiguration.ipv4Routes : null
      ipv6Routes: value[index].properties.aggregateRouteConfiguration.ipv6Routes != [] ? value[index].properties.aggregateRouteConfiguration.ipv6Routes : null
    } : null
    connectedSubnetRoutePolicy: value[index].properties.connectedSubnetRoutePolicy != {} ? {
      exportRoutePolicyId: value[index].properties.connectedSubnetRoutePolicy.exportRoutePolicyId
    } : null
  }
  resource internalNetwork 'internalNetworks' = [for i in range(0, internalNetworkCount): {
    name: value[index].internalNetwork[i].name
    properties: {
      vlanId: value[index].internalNetwork[i].properties.vlanId // Required
      mtu: value[index].internalNetwork[i].properties.mtu != '' ? value[index].internalNetwork[i].properties.mtu : null
      connectedIPv4Subnets: value[index].internalNetwork[i].properties.connectedIPv4Subnets != [] ? value[index].internalNetwork[i].properties.connectedIPv4Subnets : null
      connectedIPv6Subnets: value[index].internalNetwork[i].properties.connectedIPv6Subnets != [] ? value[index].internalNetwork[i].properties.connectedIPv6Subnets : null
      staticRouteConfiguration: value[index].internalNetwork[i].properties.staticRouteConfiguration != {} ? {
        ipv4Routes: value[index].internalNetwork[i].properties.staticRouteConfiguration.ipv4Routes != [] ? value[index].internalNetwork[i].properties.staticRouteConfiguration.ipv4Routes : null
        ipv6Routes: value[index].internalNetwork[i].properties.staticRouteConfiguration.ipv6Routes != [] ? value[index].internalNetwork[i].properties.staticRouteConfiguration.ipv6Routes : null
      } : null
      bgpConfiguration: value[index].internalNetwork[i].properties.bgpConfiguration != {} ? {
        defaultRouteOriginate: value[index].internalNetwork[i].properties.bgpConfiguration.defaultRouteOriginate != '' ? value[index].internalNetwork[i].properties.bgpConfiguration.defaultRouteOriginate : null
        allowAS: value[index].internalNetwork[i].properties.bgpConfiguration.allowAS
        allowASOverride: value[index].internalNetwork[i].properties.bgpConfiguration.allowASOverride != '' ? value[index].internalNetwork[i].properties.bgpConfiguration.allowASOverride : null
        peerASN: value[index].internalNetwork[i].properties.bgpConfiguration.peerASN // Required
        ipv4ListenRangePrefixes: value[index].internalNetwork[i].properties.bgpConfiguration.ipv4ListenRangePrefixes != [] ? value[index].internalNetwork[i].properties.bgpConfiguration.ipv4ListenRangePrefixes : null
        ipv6ListenRangePrefixes: value[index].internalNetwork[i].properties.bgpConfiguration.ipv6ListenRangePrefixes != [] ? value[index].internalNetwork[i].properties.bgpConfiguration.ipv6ListenRangePrefixes : null
        ipv4NeighborAddress: value[index].internalNetwork[i].properties.bgpConfiguration.ipv4NeighborAddress != [] ? value[index].internalNetwork[i].properties.bgpConfiguration.ipv4NeighborAddress : null
        ipv6NeighborAddress: value[index].internalNetwork[i].properties.bgpConfiguration.ipv6NeighborAddress != [] ? value[index].internalNetwork[i].properties.bgpConfiguration.ipv6NeighborAddress : null
      } : null
      importRoutePolicyId: value[index].internalNetwork[i].properties.importRoutePolicyId != '' ? value[index].internalNetwork[i].properties.importRoutePolicyId : null
      exportRoutePolicyId: value[index].internalNetwork[i].properties.exportRoutePolicyId != '' ? value[index].internalNetwork[i].properties.exportRoutePolicyId : null
    }
  }]
  resource externalNetwork 'externalNetworks' = [for i in range(0, externalNetworkCount): {
    name: value[index].externalNetwork[i].name
    properties: {
      peeringOption: value[index].externalNetwork[i].properties.peeringOption // Required
      optionAProperties: value[index].externalNetwork[i].properties.optionAProperties != {} ? {
        mtu: value[index].externalNetwork[i].properties.optionAProperties.mtu != '' ? value[index].externalNetwork[i].properties.optionAProperties.mtu : null
        vlanId: value[index].externalNetwork[i].properties.optionAProperties.vlanId // Required
        peerASN: value[index].externalNetwork[i].properties.optionAProperties.peerASN // Required
        primaryIpv4Prefix: value[index].externalNetwork[i].properties.optionAProperties.primaryIpv4Prefix != '' ? value[index].externalNetwork[i].properties.optionAProperties.primaryIpv4Prefix : null
        primaryIpv6Prefix: value[index].externalNetwork[i].properties.optionAProperties.primaryIpv6Prefix != '' ? value[index].externalNetwork[i].properties.optionAProperties.primaryIpv6Prefix : null
        secondaryIpv4Prefix: value[index].externalNetwork[i].properties.optionAProperties.secondaryIpv4Prefix != '' ? value[index].externalNetwork[i].properties.optionAProperties.secondaryIpv4Prefix : null
        secondaryIpv6Prefix: value[index].externalNetwork[i].properties.optionAProperties.secondaryIpv6Prefix != '' ? value[index].externalNetwork[i].properties.optionAProperties.secondaryIpv6Prefix : null
      } : null
      optionBProperties: value[index].externalNetwork[i].properties.optionBProperties != {} ? {
        importRouteTargets: value[index].externalNetwork[i].properties.optionBProperties.importRouteTargets != '' ? value[index].externalNetwork[i].properties.optionBProperties.importRouteTargets : null
        exportRouteTargets: value[index].externalNetwork[i].properties.optionBProperties.exportRouteTargets != '' ? value[index].externalNetwork[i].properties.optionBProperties.exportRouteTargets : null
      } : null
      importRoutePolicyId: value[index].externalNetwork[i].properties.importRoutePolicyId != '' ? value[index].externalNetwork[i].properties.importRoutePolicyId : null
      exportRoutePolicyId: value[index].externalNetwork[i].properties.exportRoutePolicyId != '' ? value[index].externalNetwork[i].properties.exportRoutePolicyId : null
    }
  }]
}
