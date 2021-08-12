@description('Required. The Virtual Network (vNet) Name.')
param virtualNetworkName string = 'vnet-asev3'

@description('Required. Location for all resources.')
param location string = resourceGroup().location

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param vNetAddressPrefixes array = [
  '172.16.0.0/16'
]

@description('Required. The subnet Name of ASEv3.')
param subnetName string = 'snet-asev3-ilb'

@description('Required. The subnet properties.')
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

@description('Required. Name of the Network Security Group.')
@minLength(1)
param networkSecurityGroupName string = 'nsg-asev3-ilb'

@description('Required. Array of Security Rules to deploy to the Network Security Group.')
param networkSecurityGroupSecurityRules array

@description('Optional. It is only for unique string generation base on timestamp.')
param timeStamp string = utcNow()

// Variable definitions
var uniStr = substring('${uniqueString(resourceGroup().id, timeStamp)}', 0, 4)
var aseName = '${aseNamePrefix}-${uniStr}'
var privateZoneName = '${aseName}.appserviceenvironment.net'
var virtualNetworkId = resourceId('Microsoft.Network/virtualNetworks', virtualNetworkName)
var subnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
var aseNetworkConfiguration = '${asev3.id}/configurations/networking'

resource networksecuritygroup 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [for item in networkSecurityGroupSecurityRules: {
      name: item.name
      properties: {
        description: item.properties.description
        access: item.properties.access
        destinationAddressPrefix: ((item.properties.destinationAddressPrefix == '') ? json('null') : item.properties.destinationAddressPrefix)
        destinationAddressPrefixes: ((length(item.properties.destinationAddressPrefixes) == 0) ? json('null') : item.properties.destinationAddressPrefixes)
        //destinationApplicationSecurityGroups: ((length(item.properties.destinationApplicationSecurityGroups) == 0) ? json('null') : concat(emptyArray, array(json('{{"id": "${resourceId('Microsoft.Network/applicationSecurityGroups', item.properties.destinationApplicationSecurityGroups[0].name)}","location": "${location}"}}'))))
        destinationPortRanges: ((length(item.properties.destinationPortRanges) == 0) ? json('null') : item.properties.destinationPortRanges)
        destinationPortRange: ((item.properties.destinationPortRange == '') ? json('null') : item.properties.destinationPortRange)
        direction: item.properties.direction
        priority: int(item.properties.priority)
        protocol: item.properties.protocol
        sourceAddressPrefix: ((item.properties.sourceAddressPrefix == '') ? json('null') : item.properties.sourceAddressPrefix)
        //sourceApplicationSecurityGroups: ((length(item.properties.sourceApplicationSecurityGroups) == 0) ? json('null') : concat(emptyArray, array(json('{{"id": "${resourceId('Microsoft.Network/applicationSecurityGroups', item.properties.sourceApplicationSecurityGroups[0].name)}","location": "${location}"}}'))))
        sourcePortRanges: ((length(item.properties.sourcePortRanges) == 0) ? json('null') : item.properties.sourcePortRanges)
        sourcePortRange: item.properties.sourcePortRange
      }
    }]
  }
}

resource virtualnetwork 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vNetAddressPrefixes
    }
    //ddosProtectionPlan: ((!empty(ddosProtectionPlanId)) ? ddosProtectionPlan : json('null'))
    //dhcpOptions: (empty(dnsServers) ? json('null') : varDnsServers)
    //enableDdosProtection: (!empty(ddosProtectionPlanId))
    subnets: [for item in subnets: {
      name: item.name
      properties: {
        addressPrefix: item.addressPrefix
        networkSecurityGroup: (empty(item.networkSecurityGroupName) ? json('null') : json('{"id": "${resourceId('Microsoft.Network/networkSecurityGroups', item.networkSecurityGroupName)}"}'))
        //routeTable: (empty(item.routeTableName) ? json('null') : json('{"id": "${resourceId('Microsoft.Network/routeTables', item.routeTableName)}"}'))
        //serviceEndpoints: (empty(item.serviceEndpoints) ? json('null') : item.serviceEndpoints)
        delegations: item.delegations
      }
    }]
  }
  dependsOn: [
    networksecuritygroup
  ]
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
        ipv4Address: reference(aseNetworkConfiguration, '2021-02-01').internalInboundIpAddresses[0]
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
        ipv4Address: reference(aseNetworkConfiguration, '2021-02-01').internalInboundIpAddresses[0]
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
        ipv4Address: reference(aseNetworkConfiguration, '2021-02-01').internalInboundIpAddresses[0]
      }
    ]
  }
}
