@description('Name of the Network Fabric')
param networkFabricName string

@description('Azure Region for deployment of the Network Fabric and associated resources')
param location string = resourceGroup().location

@description('Switch configuration description')
param annotation string = ''

@description('Resource Id of the Network Fabric Controller,  is should be in the format of /subscriptions/<Sub ID>/resourceGroups/<Resource group name>/providers/Microsoft.ManagedNetworkFabric/networkFabricControllers/<networkFabricController name>')
param networkFabricControllerId string

@description('Name of the Network Fabric SKU')
param networkFabricSku string

@minValue(1)
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
param ipv6Prefix string = ''

@minValue(1)
@maxValue(4294967295)
@description('ASN of CE devices for CE/PE connectivity')
param fabricASN int

@description('Network and credentials configuration currently applied to terminal server')
param terminalServerConfiguration object

@description('Configuration to be used to setup the management network')
param managementNetworkConfiguration object

@description('Create Network Fabric Resource')
resource networkFabrics 'Microsoft.ManagedNetworkFabric/networkFabrics@2023-06-15' = {
  name: networkFabricName
  location: location
  properties: {
    annotation: !empty(annotation) ? annotation : null
    networkFabricSku: networkFabricSku
    rackCount: rackCount
    serverCountPerRack: serverCountPerRack
    ipv4Prefix: ipv4Prefix
    ipv6Prefix: !empty(ipv6Prefix) ? ipv6Prefix : null
    fabricASN: fabricASN
    networkFabricControllerId: networkFabricControllerId
    terminalServerConfiguration: {
      username: terminalServerConfiguration.username
      password: terminalServerConfiguration.password
      serialNumber: contains(terminalServerConfiguration, 'serialNumber') ? terminalServerConfiguration.serialNumber : null
      primaryIpv4Prefix: terminalServerConfiguration.primaryIpv4Prefix
      primaryIpv6Prefix: contains(terminalServerConfiguration, 'primaryIpv6Prefix') ? terminalServerConfiguration.primaryIpv6Prefix : null
      secondaryIpv4Prefix: terminalServerConfiguration.secondaryIpv4Prefix
      secondaryIpv6Prefix: contains(terminalServerConfiguration, 'secondaryIpv6Prefix') ? terminalServerConfiguration.secondaryIpv6Prefix : null
    }
    managementNetworkConfiguration: {
      infrastructureVpnConfiguration: {
        peeringOption: managementNetworkConfiguration.infrastructureVpnConfiguration.peeringOption
        networkToNetworkInterconnectId: contains(managementNetworkConfiguration.infrastructureVpnConfiguration, 'networkToNetworkInterconnectId') ? managementNetworkConfiguration.infrastructureVpnConfiguration.networkToNetworkInterconnectId : null
        optionBProperties: contains(managementNetworkConfiguration.infrastructureVpnConfiguration, 'optionBProperties') ? {
          routeTargets: contains(managementNetworkConfiguration.infrastructureVpnConfiguration.optionBProperties, 'routeTargets') ? managementNetworkConfiguration.infrastructureVpnConfiguration.optionBProperties.routeTargets : null
        } : null
        optionAProperties: contains(managementNetworkConfiguration.infrastructureVpnConfiguration, 'optionAProperties') ? {
          mtu: contains(managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties, 'mtu') ? managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties.mtu : null
          vlanId: managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties.vlanId
          peerASN: managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties.peerASN
          bfdConfiguration: contains(managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties, 'bfdConfiguration') ? managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties.bfdConfiguration : null
          primaryIpv4Prefix: contains(managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties, 'primaryIpv4Prefix') ? managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties.primaryIpv4Prefix : null
          primaryIpv6Prefix: contains(managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties, 'primaryIpv6Prefix') ? managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties.primaryIpv6Prefix : null
          secondaryIpv4Prefix: contains(managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties, 'secondaryIpv4Prefix') ? managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties.secondaryIpv4Prefix : null
          secondaryIpv6Prefix: contains(managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties, 'secondaryIpv6Prefix') ? managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties.secondaryIpv6Prefix : null
        } : null
      }
      workloadVpnConfiguration: {
        peeringOption: managementNetworkConfiguration.workloadVpnConfiguration.peeringOption
        networkToNetworkInterconnectId: contains(managementNetworkConfiguration.workloadVpnConfiguration, 'networkToNetworkInterconnectId') ? managementNetworkConfiguration.workloadVpnConfiguration.networkToNetworkInterconnectId : null
        optionBProperties: contains(managementNetworkConfiguration.workloadVpnConfiguration, 'optionBProperties') ? {
          routeTargets: contains(managementNetworkConfiguration.workloadVpnConfiguration.optionBProperties, 'routeTargets') ? managementNetworkConfiguration.workloadVpnConfiguration.optionBProperties.routeTargets : null
        } : null
        optionAProperties: contains(managementNetworkConfiguration.workloadVpnConfiguration, 'optionAProperties') ? {
          mtu: contains(managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties, 'mtu') ? managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties.mtu : null
          vlanId: managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties.vlanId
          peerASN: managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties.peerASN
          bfdConfiguration: contains(managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties, 'bfdConfiguration') ? managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties.bfdConfiguration : null
          primaryIpv4Prefix: contains(managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties, 'primaryIpv4Prefix') ? managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties.primaryIpv4Prefix : null
          primaryIpv6Prefix: contains(managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties, 'primaryIpv6Prefix') ? managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties.primaryIpv6Prefix : null
          secondaryIpv4Prefix: contains(managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties, 'secondaryIpv4Prefix') ? managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties.secondaryIpv4Prefix : null
          secondaryIpv6Prefix: contains(managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties, 'secondaryIpv6Prefix') ? managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties.secondaryIpv6Prefix : null
        } : null
      }
    }
  }
}

output resourceID string = networkFabrics.id
