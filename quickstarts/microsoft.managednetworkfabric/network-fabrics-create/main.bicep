@description('Name of the Network Fabric')
param networkFabricName string

@description('Azure Region for deployment of the Network Fabric and associated resources')
param location string = resourceGroup().location

@description('Resource Id of the Network Fabric Controller,  is should be in the format of /subscriptions/<Sub ID>/resourceGroups/<Resource group name>/providers/Microsoft.ManagedNetworkFabric/networkFabricControllers/<networkFabricController name>')
param networkFabricControllerId string

var networkFabricSku = 'fab1'
var vlanId = 123
var fabricAsn = 65046
var peerAsn = 65342
var primaryIpv4Prefix = '172.31.0.8/30'
var secondaryIpv4Prefix = '172.31.0.12/30'
var username = 'asdfg'
var password = 'asdffh'
var ipv4Prefix = '10.18.0.0/19'

@description('Create Network Fabric Controller Resource')
resource networkFabrics 'Microsoft.ManagedNetworkFabric/networkFabrics@2022-01-15-privatepreview' = {
  name: networkFabricName
  location: location
  properties: {
    networkFabricSku: networkFabricSku
    networkFabricControllerId: networkFabricControllerId
    networkToNetworkInterconnect: {
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
    }
    managementNetworkConfiguration: {
      ipv4Prefix: ipv4Prefix
      managementVpnConfiguration: {
        optionBProperties: {
          importRouteTargets: [
            '65046:10039'
          ]
          exportRouteTargets: [
            '65046:10039'
          ]
        }
      }
      workloadVpnConfiguration: {
        optionBProperties: {
          importRouteTargets: [
            '65046:10039'
          ]
          exportRouteTargets: [
            '65046:10039'
          ]
        }
      }
    }
  }
}
