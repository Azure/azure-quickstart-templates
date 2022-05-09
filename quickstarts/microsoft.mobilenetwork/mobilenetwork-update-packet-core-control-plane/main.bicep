@description('Region where the mobile network will be deployed (must match the resource group region)')
param location string = resourceGroup().location

@description('The name for the existing packet core control plane / site name')
param existingSiteName string = 'myExampleSite'

@description('The version of packet core to use. Only set this field when instructed to by your support engineer.')
param version string = ''

// Need to fetch the existing object's state in a separate deployment to workaround circular dependency error
module fetchedData './nestedtemplates/fetch.bicep' = {
  name: 'fetchExistingPacketCore'
  params: {
    existingSiteName: existingSiteName
  }
}

// Required to avoid type error
var existingCoreNetworkTechnology = contains(fetchedData.outputs.existingCoreNetworkTechnology, '5GC') ? '5GC' : 'EPC'

resource examplePacketCoreControlPlane 'Microsoft.MobileNetwork/packetCoreControlPlanes@2022-03-01-preview' = {
  name: existingSiteName
  location: location
  properties: {
    mobileNetwork: fetchedData.outputs.existingMobileNetwork
    coreNetworkTechnology: existingCoreNetworkTechnology
    customLocation: empty(fetchedData.outputs.existingCustomLocation) ? null : fetchedData.outputs.existingCustomLocation
    controlPlaneAccessInterface: fetchedData.outputs.existingControlPlaneAccessInterface
    version: version
  }
}
