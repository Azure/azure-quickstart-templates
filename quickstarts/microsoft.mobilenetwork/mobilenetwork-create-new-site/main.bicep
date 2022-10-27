@description('Region where the mobile network will be deployed (must match the resource group region)')
param location string

@description('Name of the mobile network to which you are adding a site')
param existingMobileNetworkName string

@description('Name of the existing data network to which the mobile network connects')
param existingDataNetworkName string

@description('The name for the site')
param siteName string = 'myExampleSite'

@description('The resource ID of the Azure Stack Edge device to deploy to')
param azureStackEdgeDevice string = ''

@description('The virtual network name on port 5 on your Azure Stack Edge Pro device. This is the virtual network that will be used for the control plane interface on the access network. For 5G, this interface is the N2 interface, whereas for 4G, it\'s the S1-MME interface.')
param controlPlaneAccessInterfaceName string = ''

@description('The IP address of the control plane interface on the access network. In 5G networks this is called the N2 interface whereas in 4G networks this is called the S1-MME interface.')
param controlPlaneAccessIpAddress string = ''

@description('The virtual network name on port 5 on your Azure Stack Edge Pro device. This is the virtual network that will be used for the user plane interface on the access network. For 5G, this interface is the N3 interface, whereas for 4G, it\'s the S1-U interface.')
param userPlaneAccessInterfaceName string = ''

@description('The virtual network name on port 6 on your Azure Stack Edge Pro device. This is the virtual network that will be used for the user plane interface on the data network. For 5G, this interface is the N6 interface, whereas for 4G, it\'s the SGi interface')
param userPlaneDataInterfaceName string = ''

@description('The network address of the subnet from which dynamic IP addresses must be allocated to UEs, given in CIDR notation. Optional if userEquipmentStaticAddressPoolPrefix is specified. If both are specified, they must be the same size and not overlap.')
param userEquipmentAddressPoolPrefix string = ''

@description('The network address of the subnet from which static IP addresses must be allocated to UEs, given in CIDR notation. Optional if userEquipmentAddressPoolPrefix is specified. If both are specified, they must be the same size and not overlap.')
param userEquipmentStaticAddressPoolPrefix string = ''

@description('The mode in which the packet core instance will run')
@allowed([
  'EPC'
  '5GC'
])
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
      type: 'AKS-HCI'
      customLocation: empty(customLocation) ? null : {
        id: customLocation
      }
      azureStackEdgeDevice: {
        id: azureStackEdgeDevice
      }
    }
    controlPlaneAccessInterface: {
      ipv4Address: controlPlaneAccessIpAddress
      name: controlPlaneAccessInterfaceName
    }
  }

  #disable-next-line BCP081
  resource examplePacketCoreDataPlane 'packetCoreDataPlanes@2022-04-01-preview' = {
    name: siteName
    location: location
    properties: {
      userPlaneAccessInterface: {
        name: userPlaneAccessInterfaceName
      }
    }

    #disable-next-line BCP081
    resource exampleAttachedDataNetwork 'attachedDataNetworks@2022-04-01-preview' = {
      name: existingDataNetworkName
      location: location
      properties: {
        userPlaneDataInterface: {
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
