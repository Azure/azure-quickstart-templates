@description('The name for the existing packet core control plane / site name')
param existingSiteName string = 'myExampleSite'

resource existingPacketCoreControlPlane 'Microsoft.MobileNetwork/packetCoreControlPlanes@2022-03-01-preview' existing = {
  name: existingSiteName
}
output existingMobileNetwork object = existingPacketCoreControlPlane.properties.mobileNetwork
output existingCoreNetworkTechnology string = existingPacketCoreControlPlane.properties.coreNetworkTechnology
output existingCustomLocation object = contains(existingPacketCoreControlPlane.properties, 'customLocation') ? existingPacketCoreControlPlane.properties.customLocation ?? {} : {}
output existingControlPlaneAccessInterface object = existingPacketCoreControlPlane.properties.controlPlaneAccessInterface
