param vWANhubs array
param internetTrafficRoutingPolicy bool
param privateTrafficRoutingPolicy bool
// NOTE: vWAN Routing Intent and Policy requires either InternetTrafficRoutingPolicy or PrivateTrafficRoutingPolicy to be true, otherwise feature will be disabled.

resource vWANHub1 'Microsoft.Network/virtualHubs@2023-04-01' existing = {
  name: vWANhubs[0].name
}

resource vWANHub2 'Microsoft.Network/virtualHubs@2022-11-01' existing = {
  name: vWANhubs[1].name
}

resource hub1Firewall 'Microsoft.Network/azureFirewalls@2023-04-01' existing = {
  name: vWANhubs[0].fwname
}

resource hub2Firewall 'Microsoft.Network/azureFirewalls@2023-04-01' existing = {
  name: vWANhubs[1].fwname
}

resource vWANHub1RoutingIntent 'Microsoft.Network/virtualHubs/routingIntent@2023-04-01' = {
  parent: vWANHub1
  name: '${vWANhubs[0].name}-RoutingIntent'
  properties: {
    routingPolicies: (internetTrafficRoutingPolicy == true && privateTrafficRoutingPolicy == true) ? [
        {
          name: 'PublicTraffic'
          destinations: [
            'Internet'
          ]
          nextHop: hub1Firewall.id
        }
       {
          name: 'PrivateTraffic'
          destinations: [
            'PrivateTraffic'
          ]
          nextHop: hub1Firewall.id        
       }
      ] : (internetTrafficRoutingPolicy == true && privateTrafficRoutingPolicy == false) ? [
        {
          name: 'PublicTraffic'
          destinations: [
            'Internet'
          ]
          nextHop: hub1Firewall.id
        }
    ] : [
      {
        name: 'PrivateTraffic'
        destinations: [
          'PrivateTraffic'
        ]
        nextHop: hub1Firewall.id        
     }
    ]
  }
}

resource vWANHub2RoutingIntent 'Microsoft.Network/virtualHubs/routingIntent@2023-04-01' = {
  parent: vWANHub2
  name: '${vWANhubs[1].name}-RoutingIntent'
  properties: {
    routingPolicies: (internetTrafficRoutingPolicy == true && privateTrafficRoutingPolicy == true) ? [
        {
          name: 'PublicTraffic'
          destinations: [
            'Internet'
          ]
          nextHop: hub2Firewall.id
        }
       {
          name: 'PrivateTraffic'
          destinations: [
            'PrivateTraffic'
          ]
          nextHop: hub2Firewall.id        
       }
      ] : (internetTrafficRoutingPolicy == true && privateTrafficRoutingPolicy == false) ? [
        {
          name: 'PublicTraffic'
          destinations: [
            'Internet'
          ]
          nextHop: hub2Firewall.id
        }
    ] : [
      {
        name: 'PrivateTraffic'
        destinations: [
          'PrivateTraffic'
        ]
        nextHop: hub2Firewall.id        
     }
    ]
  }
}

