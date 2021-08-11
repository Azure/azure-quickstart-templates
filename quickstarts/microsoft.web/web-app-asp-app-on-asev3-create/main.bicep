@description('Required. The Virtual Network (vNet) Name.')
param virtualNetworkName string = 'vnet-asev3'

@description('Required. Location for all resources.')
param location string = 'eastasia'

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param vNetAddressPrefixes array = [
  '172.16.0.0/16'
]

@description('Required. Name of the Network Security Group.')
@minLength(1)
param networkSecurityGroupName string = 'nsg-asev3-ilb'

@description('Required. The subnet Name of ASEv3.')
param subnetName string = 'snet-asev3-ilb'

@description('Required. An Array of subnets to deploy to the Virual Network.')
@minLength(1)
param subnets array = [
  {
    name: 'snet-asev3-ilb'
    addressPrefix: '172.16.0.0/24'
    // @description('Required. Delegation name of the ASEv3 subnet.')
    delegations: [
      {
        name: 'asev3'
        properties: {
          serviceName: 'Microsoft.Web/hostingEnvironments'
        }
      }
    ]
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    networkSecurityGroupName: 'nsg-asev3-ilb'
  }
]

@description('Required. Name of ASEv3.')
param aseNamePrefix string = 'asev3-ilb'
@description('Required. Dedicated host count of ASEv3.')
param dedicatedHostCount string = '0'
@description('Required. Zone redundant of ASEv3.')
@allowed([
  true
  false
])
param zoneRedundant bool = false
@description('Optional. Create a private DNS zone for ASEv3.')
param createPrivateDNS bool = true
@description('Required. Load balancer mode: 0-external load balancer, 3-internal load balancer for ASEv3.')
@allowed([
  0
  3
])
param internalLoadBalancingMode int = 3

@description('Optional. It is only for unique string generation base on timestamp.')
param timeStamp string = utcNow()

// Variable definitions
var uniStr = substring('${uniqueString(resourceGroup().id, timeStamp)}', 0, 4)
var aseName = '${aseNamePrefix}-${uniStr}'
var privateZoneName = '${aseName}.appserviceenvironment.net'
var virtualNetworkId = resourceId('Microsoft.Network/virtualNetworks', virtualNetworkName)
var subnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)

module virtualnetwork 'modules/virtualnetwork.bicep' = {
  name: '${virtualNetworkName}-${uniStr}'
  params: {
    virtualNetworkName: virtualNetworkName
    networkSecurityGroupName: networkSecurityGroupName
    vNetAddressPrefixes: vNetAddressPrefixes
    subnets: subnets
  }
}

resource asev3 'Microsoft.Web/hostingEnvironments@2020-12-01' = {
  name: aseName
  location: location
  kind: 'ASEV3'
  // @description('Required. Three key properties for ASEv3.')
  properties: {
    dedicatedHostCount: dedicatedHostCount
    zoneRedundant: zoneRedundant
    internalLoadBalancingMode: internalLoadBalancingMode
    virtualNetwork: {
      id: subnetId
    }
  }
  dependsOn: [
    virtualnetwork
  ]
}

resource privatezone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (createPrivateDNS && internalLoadBalancingMode == 3) {
  name: privateZoneName
  location: 'global'
  properties: {}
  dependsOn: [
    asev3
  ]
}

resource vnetlink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (createPrivateDNS && internalLoadBalancingMode == 3) {
  parent: privatezone
  name: 'vnetLink'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
    registrationEnabled: false
  }
}

resource webrecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = if (createPrivateDNS && internalLoadBalancingMode == 3) {
  parent: privatezone
  name: '*'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: reference('${asev3.id}/configurations/networking', '2020-06-01').internalInboundIpAddresses[0]
      }
    ]
  }
}

resource scmrecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = if (createPrivateDNS && internalLoadBalancingMode == 3) {
  parent: privatezone
  name: '*.scm'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: reference('${asev3.id}/configurations/networking', '2020-06-01').internalInboundIpAddresses[0]
      }
    ]
  }
}

resource atrecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = if (createPrivateDNS && internalLoadBalancingMode == 3) {
  parent: privatezone
  name: '@'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: reference('${asev3.id}/configurations/networking', '2020-06-01').internalInboundIpAddresses[0]
      }
    ]
  }
}
