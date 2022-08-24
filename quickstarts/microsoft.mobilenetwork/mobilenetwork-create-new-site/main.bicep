@description('Region where the mobile network will be deployed (must match the resource group region)')
param location string

@description('Name of the mobile network to which you are adding a site')
param existingMobileNetworkName string

@description('Name of the existing data network to which the mobile network connects')
param existingDataNetworkName string

@description('The name for the site')
param siteName string = 'myExampleSite'

@description('The platform type where packet core is deployed.')
@allowed([
  'AKS-HCI'
  'BaseVM'
])
param platformType string = 'AKS-HCI'

@description('The name of the control plane interface on the access network. In 5G networks this is called the N2 interface whereas in 4G networks this is called the S1-MME interface. This should match one of the interfaces configured on your Azure Stack Edge machine.')
param controlPlaneAccessInterfaceName string = ''

@description('The IP address of the control plane interface on the access network. In 5G networks this is called the N2 interface whereas in 4G networks this is called the S1-MME interface.')
param controlPlaneAccessIpAddress string = ''

@description('The logical name of the user plane interface on the access network. In 5G networks this is called the N3 interface whereas in 4G networks this is called the S1-U interface. This should match one of the interfaces configured on your Azure Stack Edge machine.')
param userPlaneAccessInterfaceName string = ''

@description('The IP address of the user plane interface on the access network. In 5G networks this is called the N3 interface whereas in 4G networks this is called the S1-U interface. Not required for AKS-HCI.')
param userPlaneAccessInterfaceIpAddress string = ''

@description('The network address of the access subnet in CIDR notation')
param accessSubnet string = ''

@description('The access subnet default gateway')
param accessGateway string = ''

@description('The logical name of the user plane interface on the data network. In 5G networks this is called the N6 interface whereas in 4G networks this is called the SGi interface. This should match one of the interfaces configured on your Azure Stack Edge machine.')
param userPlaneDataInterfaceName string = ''

@description('The IP address of the user plane interface on the data network. In 5G networks this is called the N6 interface whereas in 4G networks this is called the SGi interface. Not required for AKS-HCI.')
param userPlaneDataInterfaceIpAddress string = ''

@description('The network address of the data subnet in CIDR notation')
param userPlaneDataInterfaceSubnet string = ''

@description('The data subnet default gateway')
param userPlaneDataInterfaceGateway string = ''

@description('The network address of the subnet from which dynamic IP addresses must be allocated to UEs, given in CIDR notation. Optional if userEquipmentStaticAddressPoolPrefix is specified. If both are specified, they must be the same size and not overlap.')
param userEquipmentAddressPoolPrefix string = ''

@description('The network address of the subnet from which static IP addresses must be allocated to UEs, given in CIDR notation. Optional if userEquipmentAddressPoolPrefix is specified. If both are specified, they must be the same size and not overlap.')
param userEquipmentStaticAddressPoolPrefix string = ''

@description('The mode in which the packet core instance will run')
param coreNetworkTechnology string = '5GC'

@description('Whether or not Network Address and Port Translation (NAPT) should be enabled for this data network')
@allowed([
  'Enabled'
  'Disabled'
])
param naptEnabled string

@description('A list of DNS servers that UEs on this data network will use')
param dnsAddresses array

@description('The resource ID of the custom location that targets the Azure Kubernetes Service on Azure Stack HCI (AKS-HCI) cluster on the Azure Stack Edge Pro device in the site. If this parameter is not specified, the packet core instance will be created but will not be deployed to an ASE. [Collect custom location information](https://docs.microsoft.com/en-gb/azure/private-5g-core/collect-required-information-for-a-site#collect-custom-location-information) explains which value to specify here.')
param customLocation string = ''

#disable-next-line BCP081
resource existingMobileNetwork 'Microsoft.MobileNetwork/mobileNetworks@2022-04-01-preview' existing = {
  name: existingMobileNetworkName

  #disable-next-line BCP081
  resource existingDataNetwork 'dataNetworks@2022-04-01-preview' existing = {
    name: existingDataNetworkName
  }

  #disable-next-line BCP081
  resource exampleSite 'sites@2022-04-01-preview' = {
    name: siteName
    location: location
    properties: {
      networkFunctions: [
        {
          id: examplePacketCoreControlPlane.id
        }
        {
          id: examplePacketCoreControlPlane::examplePacketCoreDataPlane.id
        }
      ]
    }
  }
}

#disable-next-line BCP081
resource examplePacketCoreControlPlane 'Microsoft.MobileNetwork/packetCoreControlPlanes@2022-04-01-preview' = {
  name: siteName
  location: location
  properties: {
    mobileNetwork: {
      id: existingMobileNetwork.id
    }
    sku: 'EvaluationPackage'
    coreNetworkTechnology: coreNetworkTechnology
    platform: {
      type: platformType
      customLocation: empty(customLocation) ? null : {
        id: customLocation
      }
    }
    controlPlaneAccessInterface: {
      ipv4Address: controlPlaneAccessIpAddress
      ipv4Subnet: accessSubnet
      ipv4Gateway: accessGateway
      name: controlPlaneAccessInterfaceName
    }
  }

  #disable-next-line BCP081
  resource examplePacketCoreDataPlane 'packetCoreDataPlanes@2022-04-01-preview' = {
    name: siteName
    location: location
    properties: {
      userPlaneAccessInterface: {
        ipv4Address: userPlaneAccessInterfaceIpAddress
        ipv4Subnet: accessSubnet
        ipv4Gateway: accessGateway
        name: userPlaneAccessInterfaceName
      }
    }

    #disable-next-line BCP081
    resource exampleAttachedDataNetwork 'attachedDataNetworks@2022-04-01-preview' = {
      name: existingDataNetworkName
      location: location
      properties: {
        userPlaneDataInterface: {
          ipv4Address: userPlaneDataInterfaceIpAddress
          ipv4Subnet: userPlaneDataInterfaceSubnet
          ipv4Gateway: userPlaneDataInterfaceGateway
          name: userPlaneDataInterfaceName
        }
        userEquipmentAddressPoolPrefix: empty(userEquipmentAddressPoolPrefix) ? null : [
          userEquipmentAddressPoolPrefix
        ]
        userEquipmentStaticAddressPoolPrefix: empty(userEquipmentStaticAddressPoolPrefix) ? null : [
          userEquipmentStaticAddressPoolPrefix
        ]
        naptConfiguration: {
          enabled: naptEnabled
        }
        dnsAddresses: dnsAddresses
      }
    }
  }
}
