@description('Name of the Network Fabric')
param networkFabricName string

@description('Azure Region for deployment of the Network Fabric and associated resources')
param location string = resourceGroup().location

@description('Resource Id of the Network Fabric Controller,  is should be in the format of /subscriptions/<Sub ID>/resourceGroups/<Resource group name>/providers/Microsoft.ManagedNetworkFabric/networkFabricControllers/<networkFabricController name>')
param networkFabricControllerId string

@description('Name of the Network Fabric SKU')
param networkFabricSku string = 'fab1'

@description('Port Count')
param portCount int

@description('Maximum transmission unit')
param mtu int

@description('Interfaces')
param interfaces array

@description('Vlan identifier value')
param vlanId int

@description('ASN number assigned on CE for BGP peering with PE')
param fabricAsn int

@description('ASN number assigned on PE for BGP peering with CE')
param peerAsn int

@description('IPv4 Prefix for connectivity between TS and PE1')
param primaryIpv4Prefix string

@description('IPv4 Prefix for connectivity between TS and PE12')
param secondaryIpv4Prefix string

@description('Username of terminal server')
param username string

@description('Password of terminal server')
param password string

@description('IPv4 Prefix of the management network')
param ipv4Prefix string

@description('Import Route targets to be configured on CEs')
param managementVpnImportRouteTargets array

@description('Export Route targets to be configured on CEs')
param managementVpnExportRouteTargets array

@description('Import Route targets to be configured on CEs')
param workloadVpnImportRouteTargets array

@description('Export Route targets to be configured on CEs')
param workloadVpnExportRouteTargets array

@description('Create Network Fabric Controller Resource')
resource networkFabrics 'Microsoft.ManagedNetworkFabric/networkFabrics@2022-01-15-privatepreview' = {
  name: networkFabricName
  location: location
  properties: {
    networkFabricSku: networkFabricSku
    networkFabricControllerId: networkFabricControllerId
    networkToNetworkInterconnect: {
      layer2Configuration: {
        portCount: portCount
        mtu: mtu
        interfaces: interfaces
      }
      layer3Configuration: {
        vlanId: vlanId
        fabricAsn: fabricAsn
        peerAsn: peerAsn
        primaryIpv4Prefix: primaryIpv4Prefix
        secondaryIpv4Prefix: secondaryIpv4Prefix
      }
    }
    terminalServerConfiguration: {
      username: username
      password: password
      primaryIpv4Prefix: primaryIpv4Prefix
      secondaryIpv4Prefix: secondaryIpv4Prefix
    }
    managementNetworkConfiguration: {
      ipv4Prefix: ipv4Prefix
      managementVpnConfiguration: {
        optionBProperties: {
          importRouteTargets: managementVpnImportRouteTargets
          exportRouteTargets: managementVpnExportRouteTargets
        }
      }
      workloadVpnConfiguration: {
        optionBProperties: {
          importRouteTargets: workloadVpnImportRouteTargets
          exportRouteTargets: workloadVpnExportRouteTargets
        }
      }
    }
  }
}

output resourceID string = networkFabrics.id
