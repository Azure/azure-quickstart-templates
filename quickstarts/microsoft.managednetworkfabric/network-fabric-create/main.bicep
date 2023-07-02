@description('Name of the Network Fabric')
param networkFabricName string

@description('Azure Region for deployment of the Network Fabric and associated resources')
param location string = resourceGroup().location

@description('Switch configuration description')
param annotation string

@description('Resource Id of the Network Fabric Controller,  is should be in the format of /subscriptions/<Sub ID>/resourceGroups/<Resource group name>/providers/Microsoft.ManagedNetworkFabric/networkFabricControllers/<networkFabricController name>')
param networkFabricControllerId string

@description('Name of the Network Fabric SKU')
param networkFabricSku string = 'fab1'

@minValue(2)
@maxValue(8)
@description('Number of racks associated to Network Fabric')
param rackCount int

@minValue(1)
@maxValue(16)
@description('Number of servers per Rack')
param serverCountPerRack int

@description('IPv4 Prefix for Management Network')
param ipv4Prefix string

@description('IPv6 Prefix for Management Network')
param ipv6Prefix string

@minValue(1)
@maxValue(65535)
@description('ASN of CE devices for CE/PE connectivity')
param fabricASN int

@description('Username of terminal server')
param nfTSconfUsername string

@secure()
@description('Password of terminal server')
param nfTSconfPassword string

@description('Serial Number of Terminal server')
param nfTSconfSerialNumber string

@description('IPv4 Address Prefix of CE-PE interconnect links')
param nfTSconfPrimaryIpv4Prefix string

@description('IPv6 Address Prefix of CE-PE interconnect links')
param nfTSconfPrimaryIpv6Prefix string

@description('Secondary IPv6 Address Prefix of CE-PE interconnect links')
param nfTSconfSecondaryIpv4Prefix string

@description('Secondary IPv6 Address Prefix of CE-PE interconnect links')
param nfTSconfSecondaryIpv6Prefix string

@description('Manage the management VPN connection between Network Fabric and infrastructure services in Network Fabric Controller')
param nfMNconfInfraVpn object

@description('Manage the management VPN connection between Network Fabric and workload services in Network Fabric Controller')
param nfMNconfWorkloadVpn object

@description('Create Network Fabric Resource')
resource networkFabrics 'Microsoft.ManagedNetworkFabric/networkFabrics@2023-06-15' = {
  name: networkFabricName
  location: location
  properties: {
    annotation: annotation
    networkFabricSku: networkFabricSku
    rackCount: rackCount != '' ? rackCount : null
    serverCountPerRack: serverCountPerRack
    ipv4Prefix: ipv4Prefix
    ipv6Prefix: ipv6Prefix != '' ? ipv6Prefix : null
    fabricASN: fabricASN
    networkFabricControllerId: networkFabricControllerId
    terminalServerConfiguration: {
      username: nfTSconfUsername
      password: nfTSconfPassword
      serialNumber: nfTSconfSerialNumber != '' ? nfTSconfSerialNumber : null
      primaryIpv4Prefix: nfTSconfPrimaryIpv4Prefix
      primaryIpv6Prefix: nfTSconfPrimaryIpv6Prefix != '' ? nfTSconfPrimaryIpv6Prefix : null
      secondaryIpv4Prefix: nfTSconfSecondaryIpv4Prefix
      secondaryIpv6Prefix: nfTSconfSecondaryIpv6Prefix != '' ? nfTSconfSecondaryIpv6Prefix : null
    }
    managementNetworkConfiguration: {
      infrastructureVpnConfiguration: nfMNconfInfraVpn
      workloadVpnConfiguration: nfMNconfWorkloadVpn
    }
  }
}

output resourceID string = networkFabrics.id
