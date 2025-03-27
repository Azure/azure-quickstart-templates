@minLength(4)
@maxLength(80)
param vWANname string = 'vWAN'

@description('Region for the Azure Virtual WAN')
param vWANlocation string = resourceGroup().location 

@description('Name of the FIRST virtual hub')
@minLength(4)
@maxLength(80)
param hub1Name string = 'Hub1' 

@description('Region for the FIRST virtual hub')
param hub1Location string = resourceGroup().location

@description('Address space for the FIRST virtual hub')
param hub1AddressSpace string = '10.1.0.0/23'

@description('Address space for the first VNet (spoke1) connected to the FIRST virtual hub')
param hub1Spoke1AddressSpace string = '10.1.2.0/24'

@description('Address space for the second VNet (spoke2) connected to the FIRST virtual hub')
param hub1Spoke2AddressSpace string = '10.1.4.0/24'

@description('Name of the SECOND virtual hub')
@minLength(4)
@maxLength(80)
param hub2Name string = 'Hub2'

@description('Region for the SECOND virtual hub')
param hub2Location string = resourceGroup().location

@description('Address space for the SECOND virtual hub')
param hub2AddressSpace string = '10.2.0.0/23'

@description('Address space for the first VNet (spoke1) connected to the SECOND virtual hub')
param hub2Spoke1AddressSpace string = '10.2.2.0/24'

@description('Address space for the second VNet (spoke2) connected to the SECOND virtual hub')
param hub2Spoke2AddressSpace string = '10.2.4.0/24'

@description('Azure Firewall Tier')
@allowed([
  'Standard'
  'Premium'
])
param firewallTier string = 'Standard' 

@description('Default with RFC1918 prefixes, to add more use comma separated list of values in CIDR notation')
param firewallSNATprivateRanges string[] = ['10.0.0.0/8','172.16.0.0/12','192.168.0.0/16','100.64.0.0/10'] //default values
// param firewallSNATprivateRanges string[] = ['10.0.0.0/8','172.16.0.0/12','192.168.0.0/16','100.64.0.0/10,'11.0.0.0/8','12.0.0.0/8','13.0.0.0/8'] // example with custom values 

@description('Enable vWAN Routing Intent and Policy for Internet Traffic')
param internetTrafficRoutingPolicy bool = true

@description('Enable vWAN Routing Intent and Policy for Private Traffic')
param privateTrafficRoutingPolicy bool = true

// NOTE: vWAN Routing Intent and Policy requires either InternetTrafficRoutingPolicy or PrivateTrafficRoutingPolicy to be true, otherwise feature will be disabled.

// NOTE: specifying additional private IP prefixes will be unavaliable only if private traffic is not secured

@description('Custom public IP prefixes to consider as internal for Virtual WAN - insert as comma-separated list of values in CIDR notation')
param customPrivateTrafficPrefixes string[] = []
// param customPrivateTrafficPrefixes string[] = ['11.0.0.0/8','12.0.0.0/8','13.0.0.0/8'] // example with custom values 

@description('Deploy VPN Site-to-Site (S2S) Gateways')
param deployS2Sgw bool = false

@description('Deploy ExpressRoute Gateways')
param deployERgw bool = false

var vWANtype = 'Standard' // 'Standard' vWAN is required for Routing Intent and Policy
var logAnalyticsWorkspaceName = '${vWANname}-LogAnalyticsWS' //single Log Analytics workspace for firewall logging
var logAnalyticsWorkspaceSKU = 'pergb2018' // default value is 'pergb2018'
var rfc1918addressSpaces = ['10.0.0.0','172.16.0.0','192.168.0.0'] // RFC1918 address spaces
var vpnGatewayScaleUnit = 1 // minimum value is 1
var erGatewayScaleUnit = 1 // minimum value is 1
var virtualRouterAsn = 65515 // default value is 65515 for Azure Virtual WAN
var minRoutingInfrastructureUnit = 2 // minimum value is 2 for Azure Virtual WAN
var vWANhubs = [
  {
            name: hub1Name
            addressSpace: hub1AddressSpace
            location: hub1Location
            routingPreference: 'ExpressRoute' // "ASPath", "ExpressRoute", "VpnGateway" - default is "ExpressRoute"
            fwName: take('${vWANname}-${hub1Name}-AzFW',56) //maximum length for Firewall name is 56 characters
            fwTier: firewallTier // 'Standard' or 'Premium'
            fwPublicIPs: 1 // Mininum value is 1
            fwPolicyName: '${vWANname}-${hub1Name}-FirewallPolicy'
            threatIntelMode: 'Alert' // 'Alert', 'Deny', 'Off' - default is 'Off'
            spoke1: {name:'${hub1Name}-vnet1', addressSpace: hub1Spoke1AddressSpace}
            spoke2: {name:'${hub1Name}-vnet2', addressSpace: hub1Spoke2AddressSpace}
  }
  { 
            name: hub2Name
            addressSpace: hub2AddressSpace
            location: hub2Location
            routingPreference: 'ExpressRoute' // "ASPath", "ExpressRoute", "VpnGateway" - default is "ExpressRoute"
            fwName: take('${vWANname}-${hub2Name}-AzFW',56)
            fwTier: firewallTier // 'Standard' or 'Premium'
            fwPublicips: 1 // Mininum value is 1
            fwPolicyName: '${vWANname}-${hub2Name}-FirewallPolicy'
            threatIntelMode: 'Alert' // 'Alert', 'Deny', 'Off' - default is 'Off'
            spoke1: {name:'${hub2Name}-vnet1', addressSpace: hub2Spoke1AddressSpace}
            spoke2: {name:'${hub2Name}-vnet2', addressSpace: hub2Spoke2AddressSpace}     
  }
]

// module for Log Analytics workspace deployment
module logAnalyticsWsModule './modules/loganalyticsws.bicep' = {
  name: 'logAnalyticsWSmodule'
  params: {
   logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
   location: vWANhubs[0].location
   logAnalyticsWorkspaceSKU: logAnalyticsWorkspaceSKU
  }
}

// module for VNets deployment 
module vNetsModule './modules/vnets.bicep' = {
  name: 'vNetsModule'
  params: {
    vWANhubs: vWANhubs
  }
}

// module for IP Groups deployment 
module ipGroupsModule './modules/ipgroups.bicep' = {
  name: 'ipGroupsModule'
  params: {
    vWANname: vWANname
    vWANhubs: vWANhubs
  }
}

module firewallPolicies './modules/firewallpolicies.bicep' = {
  name: 'firewallPoliciesModule'
  params: {
    vWANhubs: vWANhubs 
    sourceIPAddressSpaces: rfc1918addressSpaces
    destinationIPAddressSpaces: rfc1918addressSpaces
    firewallSNATprivateRanges: firewallSNATprivateRanges
  }
}

resource vWAN 'Microsoft.Network/virtualWans@2023-04-01' = {
  name: vWANname
  location: vWANlocation
  properties: {
    disableVpnEncryption: false
    allowBranchToBranchTraffic: true
    type: vWANtype
  }
}

resource vWANHub1 'Microsoft.Network/virtualHubs@2023-04-01' = {
  name: vWANhubs[0].name
  location: vWANhubs[0].location
  properties: {
    addressPrefix: vWANhubs[0].addressSpace
    virtualRouterAsn: virtualRouterAsn
    virtualRouterAutoScaleConfiguration: {
      minCapacity: minRoutingInfrastructureUnit 
    }
    virtualWan: {
      id: vWAN.id
    }
    sku: vWANtype
    hubRoutingPreference: vWANhubs[0].routingPreference
  }
}

resource vWANHub2 'Microsoft.Network/virtualHubs@2023-04-01' = {
  name: vWANhubs[1].name
  location: vWANhubs[1].location
  properties: {
    addressPrefix: vWANhubs[1].addressSpace 
    virtualRouterAsn: virtualRouterAsn
    virtualRouterAutoScaleConfiguration: {
      minCapacity: minRoutingInfrastructureUnit
    }
    virtualWan: {
      id: vWAN.id
    }
    sku: vWANtype
    hubRoutingPreference: vWANhubs[1].routingPreference
  }
}

resource hub1Firewall 'Microsoft.Network/azureFirewalls@2023-04-01' = {
  name: vWANhubs[0].fwName
  location: vWANhubs[0].location
  zones: pickZones('Microsoft.Network', 'azureFirewalls', vWANhubs[0].location,3)
  properties: {
    sku: {
      name: 'AZFW_Hub'
      tier: vWANhubs[0].fwTier
    } 
    virtualHub: {
      id: vWANHub1.id
    }
    hubIPAddresses: {      
      publicIPs: {
        count: vWANhubs[0].fwPublicIPs
      }
    }
    firewallPolicy: {
      id: firewallPolicies.outputs.fwPolicyArrayIDs[0]
    }
  }
}

resource hub2Firewall 'Microsoft.Network/azureFirewalls@2023-04-01' = {
  name: vWANhubs[1].fwName
  location: vWANhubs[1].location
 zones: pickZones('Microsoft.Network', 'azureFirewalls', vWANhubs[1].location,3)
  properties: {
    sku: {
      name: 'AZFW_Hub'
      tier: vWANhubs[1].fwTier
    }
    virtualHub: {
      id: vWANHub2.id
    }
    hubIPAddresses: {
      publicIPs: {
        count: vWANhubs[0].fwPublicIPs
      }
    }
    firewallPolicy: {
      id: firewallPolicies.outputs.fwPolicyArrayIDs[1]
    }
  }
}

// NOTE: vWAN Routing Intent and Policy requires either InternetTrafficRoutingPolicy or PrivateTrafficRoutingPolicy to be true, otherwise feature will be disabled.

module resourceIntentModule './modules/routingintent.bicep' = if (internetTrafficRoutingPolicy == true || privateTrafficRoutingPolicy == true ) {
  name: 'resourceIntentModule'
  params:{
    vWANhubs: vWANhubs
    internetTrafficRoutingPolicy: internetTrafficRoutingPolicy
    privateTrafficRoutingPolicy: privateTrafficRoutingPolicy
  }
  #disable-next-line no-unnecessary-depends
  dependsOn: [vWANHub1,vWANHub2,hub1Firewall,hub2Firewall]
}

module PrivateTrafficRouteTable './modules/PrivateTrafficRouteTable.bicep' = if ((internetTrafficRoutingPolicy == true || privateTrafficRoutingPolicy == true ) && !empty(customPrivateTrafficPrefixes)) {
  name: 'PrivateTrafficRouteTable'
  params: {
    vWANhubs: vWANhubs
    internetTrafficRoutingPolicy: internetTrafficRoutingPolicy
    privateTrafficRoutingPolicy: privateTrafficRoutingPolicy
    customPrivateTrafficPrefixes: customPrivateTrafficPrefixes
  }
  #disable-next-line no-unnecessary-depends
  dependsOn: [resourceIntentModule]
}


module firewallDiagnosticsModule './modules/fwdiagnostics.bicep' = {
  name: 'firewallDiagnosticsModule'
  params: {
    vWANhubs: vWANhubs
    logAnalyticsWorkspaceID: logAnalyticsWsModule.outputs.LogAnalyticsWorkspaceID
  }
  #disable-next-line no-unnecessary-depends
  dependsOn:[hub1Firewall, hub2Firewall]
}

module vnetConnectionsModule'./modules/vnetconnections.bicep' = {
  name: 'vnetConnectionsModule'
  params: {
    vWANhubs: vWANhubs
    vNetsIDs: vNetsModule.outputs.spokeVnetsIDs
  }
  #disable-next-line no-unnecessary-dependson
  dependsOn: [hub1Firewall, hub2Firewall]
}

module vpnS2Smodule './modules/vpns2s.bicep' = if (deployS2Sgw == true) {
  name: 'vpnS2Smodule'
  params: {
    vWANhubs: vWANhubs
    vWANHub1ID: vWANHub1.id
    vWANHub2ID: vWANHub2.id
    vpnGatewayScaleUnit: vpnGatewayScaleUnit
    logAnalyticsWorkspaceID: logAnalyticsWsModule.outputs.LogAnalyticsWorkspaceID
  }
  #disable-next-line no-unnecessary-dependson // This is required to avoid conflicts in vWAN RP, some resources must be created in a certain order
  dependsOn: [resourceIntentModule]
}

module erModule './modules/er.bicep' = if (deployERgw == true) {
  name: 'erModule'
  params:{
    vWANhubs: vWANhubs
    vWANHub1ID: vWANHub1.id
    vWANHub2ID: vWANHub2.id
    ErGatewayScaleUnit: erGatewayScaleUnit
    LogAnalyticsWorkspaceID: logAnalyticsWsModule.outputs.LogAnalyticsWorkspaceID
  }
  #disable-next-line no-unnecessary-dependson
  dependsOn: [resourceIntentModule]
}

// Generate outputs for Public IP addresses used by Azure Firewalls and VPN Gateways (if deployed):
output hub1FirewallPublicIPaddresses object = hub1Firewall.properties.hubIPAddresses.publicIPs
output hub2FirewallPublicIPaddresses object = hub2Firewall.properties.hubIPAddresses.publicIPs
output hub1VPNs2sGatewayIPaddresses array = deployS2Sgw ? vpnS2Smodule.outputs.vpnGatewayConfigs[0] : ['No VPN S2S gateway deployed in ${vWANhubs[0].name}.']
output hub2VPNs2sGatewayIPaddresses array = deployS2Sgw ? vpnS2Smodule.outputs.vpnGatewayConfigs[1] : ['No VPN S2S gateway deployed in ${vWANhubs[1].name}.']
