param vWANhubs array
param internetTrafficRoutingPolicy bool
param privateTrafficRoutingPolicy bool
param customPrivateTrafficPrefixes string[]

// NOTE: vWAN Routing Intent and Policy requires either InternetTrafficRoutingPolicy or PrivateTrafficRoutingPolicy to be true, otherwise feature will be disabled.

resource hub1Firewall 'Microsoft.Network/azureFirewalls@2023-04-01' existing = {
  name: vWANhubs[0].fwname
}

resource hub2Firewall 'Microsoft.Network/azureFirewalls@2023-04-01' existing = {
  name: vWANhubs[1].fwname
}

resource virtualHubs_Hub1_defaultRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2023-06-01' = {
    name: '${vWANhubs[0].name}/defaultRouteTable'
    properties: {
      routes: (internetTrafficRoutingPolicy == true && privateTrafficRoutingPolicy == true) ? [
        {
          name: '_policy_PublicTraffic'
          destinationType: 'CIDR'
          destinations: [
            '0.0.0.0/0'
          ]
          nextHopType: 'ResourceId'
          nextHop: hub1Firewall.id
        }
        {
          name: '_policy_PrivateTraffic'
          destinationType: 'CIDR'
          destinations: [
            '10.0.0.0/8'
            '172.16.0.0/12'
            '192.168.0.0/16'
          ]
          nextHopType: 'ResourceId'
          nextHop: hub1Firewall.id
        }
        {
          name: 'private_traffic'
          destinationType: 'CIDR'
          destinations: customPrivateTrafficPrefixes
          nextHopType: 'ResourceId'
          nextHop: hub1Firewall.id 
        }
      ] : (internetTrafficRoutingPolicy == true && privateTrafficRoutingPolicy == false) ? [
        {
          name: '_policy_PublicTraffic'
          destinationType: 'CIDR'
          destinations: [
            '0.0.0.0/0'
          ]
          nextHopType: 'ResourceId'
          nextHop: hub1Firewall.id
        }
      ] : [
        {
          name: '_policy_PrivateTraffic'
          destinationType: 'CIDR'
          destinations: [
            '10.0.0.0/8'
            '172.16.0.0/12'
            '192.168.0.0/16'
          ]
          nextHopType: 'ResourceId'
          nextHop: hub1Firewall.id
        }
        {
          name: 'private_traffic'
          destinationType: 'CIDR'
          destinations: customPrivateTrafficPrefixes
          nextHopType: 'ResourceId'
          nextHop: hub1Firewall.id 
        }
      ]
      labels: [
        'default'
      ]
    }
  }
  
  
  resource virtualHubs_Hub2_defaultRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2023-06-01' = {
    name: '${vWANhubs[1].name}/defaultRouteTable'
    properties: {
      routes: (internetTrafficRoutingPolicy == true && privateTrafficRoutingPolicy == true) ? [
        {
          name: '_policy_PublicTraffic'
          destinationType: 'CIDR'
          destinations: [
            '0.0.0.0/0'
          ]
          nextHopType: 'ResourceId'
          nextHop: hub2Firewall.id
        }
        {
          name: '_policy_PrivateTraffic'
          destinationType: 'CIDR'
          destinations: [
            '10.0.0.0/8'
            '172.16.0.0/12'
            '192.168.0.0/16'
          ]
          nextHopType: 'ResourceId'
          nextHop: hub2Firewall.id
        }
        {
          name: 'private_traffic'
          destinationType: 'CIDR'
          destinations: customPrivateTrafficPrefixes
          nextHopType: 'ResourceId'
          nextHop: hub2Firewall.id 
        }
      ] : (internetTrafficRoutingPolicy == true && privateTrafficRoutingPolicy == false) ? [
        {
          name: '_policy_PublicTraffic'
          destinationType: 'CIDR'
          destinations: [
            '0.0.0.0/0'
          ]
          nextHopType: 'ResourceId'
          nextHop: hub2Firewall.id
        }
      ] : [
        {
          name: '_policy_PrivateTraffic'
          destinationType: 'CIDR'
          destinations: [
            '10.0.0.0/8'
            '172.16.0.0/12'
            '192.168.0.0/16'
          ]
          nextHopType: 'ResourceId'
          nextHop: hub2Firewall.id
        }
        {
          name: 'private_traffic'
          destinationType: 'CIDR'
          destinations: customPrivateTrafficPrefixes
          nextHopType: 'ResourceId'
          nextHop: hub2Firewall.id 
        }
      ]
      labels: [
        'default'
      ]
    }
  }
