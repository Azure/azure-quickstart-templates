@description('Name of new or existing vnet to which Azure Route Server should be deployed.')
param vnetName string = 'routeservervnet'

@description('IP prefix for available addresses in vnet address space.')
param vnetIpPrefix string = '10.1.0.0/16'

@description('Specify whether to provision new vnet or deploy to existing vnet.')
@allowed([
  'New'
  'Existing'
])
param vnetNew_or_Existing string = 'New'

@description('Route Server subnet IP prefix MUST be within vnet IP prefix address space.')
param routeServerSubnetIpPrefix string = '10.1.1.0/27'


@description('Specify whether to provision new standard public IP or deploy using existing standard public IP.')
@allowed([
  'New'
  'Existing'
])
param publicIpNew_or_Existing string = 'New'

@description('Name of the standard Public IP used for the Route Server')
param publicIpName string = 'routeserverpip'

@description('Name of Route Server.')
param firstRouteServerName string = 'routeserver'

@description('Name of BGP connection.')
param routeServerBgpConnectionName string = 'conn1'

@description('Peer ASN connecting to.')
param peerAsn int = 65002

@description('Peer IP connecting to.')
param peerIp string = '10.0.1.4'

@description('Azure region for Route Server and virtual network.')
param location string = resourceGroup().location

var ipconfigName = 'ipconfig1'
var routeServerSubnetName = 'RouteServerSubnet'

resource vnet 'Microsoft.Network/virtualNetworks@2020-05-01' = if (vnetNew_or_Existing == 'New') {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetIpPrefix
      ]
    }
  }
}

resource routeserverSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-05-01' = {
  name: routeServerSubnetName
  parent: vnet
  properties: {
    addressPrefix: routeServerSubnetIpPrefix
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2020-05-01' = if (publicIpNew_or_Existing == 'New') {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
}

resource firstRouteServer 'Microsoft.Network/virtualHubs@2020-06-01' = {
  name: firstRouteServerName
  location: location
  properties: {
    sku: 'Standard'
  }

  
}

resource ipconfig  'Microsoft.Network/virtualHubs/ipConfigurations@2020-06-01' = {
  name: ipconfigName
  parent: firstRouteServer
  properties: {
    subnet:{
      id: routeserverSubnet.id
    }
    publicIPAddress: {
      id: publicIp.id
    }
  }
}

resource bgpConnnection 'Microsoft.Network/virtualHubs/bgpConnections@2020-06-01' = {
  name: routeServerBgpConnectionName
  parent: firstRouteServer
  properties: {
    peerAsn: peerAsn
    peerIp: peerIp
  }
  dependsOn: [
    ipconfig
  ]
}
