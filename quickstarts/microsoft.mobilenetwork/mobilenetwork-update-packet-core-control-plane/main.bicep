@description('Region where the mobile network will be deployed (must match the resource group region)')
param location string = resourceGroup().location

@description('The name of the existing packet core / site.')
param existingSiteName string = 'myExampleSite'

@description('The name of the existing packet core platform type.')
param existingPacketCorePlatformType string = 'AKS-HCI'

@description('The name of the mobile network.')
param existingMobileNetworkName string

@description('The mode in which the packet core instance will run.')
@allowed([
  'EPC'
  '5GC'
])
param existingPacketCoreNetworkTechnology string = '5GC'

@description('The resource ID of the customLocation representing the ASE device where the packet core will be deployed. If this parameter is not specified then the 5G core will be created but will not be deployed to an ASE. [Collect custom location information](https://docs.microsoft.com/en-gb/azure/private-5g-core/collect-required-information-for-a-site#collect-custom-location-information) explains which value to specify here.')
param existingPacketCoreCustomLocationId string = ''

@description('The name of the control plane interface on the access network. In 5G networks this is called the N2 interface whereas in 4G networks this is called the S1-MME interface. This should match one of the interfaces configured on your Azure Stack Edge machine.')
param controlPlaneAccessInterfaceName string = ''

@description('The IP address of the control plane interface on the access network. In 5G networks this is called the N2 interface whereas in 4G networks this is called the S1-MME interface.')
param controlPlaneAccessIpAddress string

@description('The network address of the access subnet in CIDR notation')
param accessSubnet string

@description('The access subnet default gateway')
param accessGateway string

@description('The version of packet core to use. Only set this field when instructed to by your support engineer.')
param newVersion string = ''

#disable-next-line BCP081
resource existingMobileNetwork 'Microsoft.MobileNetwork/mobileNetworks@2022-04-01-preview' existing = {
  name: existingMobileNetworkName
}

#disable-next-line BCP081
resource examplePacketCoreControlPlane 'Microsoft.MobileNetwork/packetCoreControlPlanes@2022-04-01-preview' = {
  name: existingSiteName
  location: location
  properties: {
    mobileNetwork: {
      id: existingMobileNetwork.id
    }
    sku: 'EvaluationPackage'
    coreNetworkTechnology: existingPacketCoreNetworkTechnology
    platform: {
      type: existingPacketCorePlatformType
      customLocation: empty(existingPacketCoreCustomLocationId) ? null : {
        id: existingPacketCoreCustomLocationId
      }
    }
    controlPlaneAccessInterface: {
      name: controlPlaneAccessInterfaceName
      ipv4Address: controlPlaneAccessIpAddress
      ipv4Subnet: accessSubnet
      ipv4Gateway: accessGateway
    }
    version: newVersion
  }
}
