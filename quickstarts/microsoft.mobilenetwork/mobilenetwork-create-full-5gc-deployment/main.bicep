@description('Region where the Mobile Network will be deployed (must match the resource group region)')
param location string = resourceGroup().location

@description('The name for the private mobile network')
param mobileNetworkName string

@description('The mobile country code for the private mobile network')
param mobileCountryCode string = '001'

@description('The mobile network code for the private mobile network')
param mobileNetworkCode string = '01'

@description('The name for the site')
param siteName string = 'myExampleSite'

@description('The name of the service')
param serviceName string = 'Allow-all-traffic'

@description('The name of the SIM policy')
param simPolicyName string = 'Default-policy'

@description('The name of the slice')
param sliceName string = 'slice-1'

@description('The name for the SIM group.')
param simGroupName string = ''

@description('A unversioned key vault key to encrypt the SIM data that belongs to this SIM group. For example: https://contosovault.vault.azure.net/keys/azureKey.')
param existingEncryptionKeyUrl string = ''

@description('User-assigned identity is an identity in Azure Active Directory that can be used to give access to other Azure resource such as Azure Key Vault. This identity should have Get, Wrap key, and Unwrap key permissions on the key vault.')
param existingUserAssignedIdentityResourceId string = ''

@description('An array containing properties of the SIM(s) you wish to create. See [Provision proxy SIM(s)](https://docs.microsoft.com/en-gb/azure/private-5g-core/provision-sims-azure-portal) for a full description of the required properties and their format.')
param simResources array = []

@description('The resource ID of the Azure Stack Edge device to deploy to')
param azureStackEdgeDevice string = ''

@description('The virtual network name on port 5 on your Azure Stack Edge Pro device corresponding to the control plane interface on the access network. For 5G, this interface is the N2 interface; for 4G, it\'s the S1-MME interface.')
param controlPlaneAccessInterfaceName string = ''

@description('The IP address of the control plane interface on the access network. In 5G networks this is called the N2 interface whereas in 4G networks this is called the S1-MME interface.')
param controlPlaneAccessIpAddress string = ''

@description('The virtual network name on port 5 on your Azure Stack Edge Pro device corresponding to the user plane interface on the access network. For 5G, this interface is the N3 interface; for 4G, it\'s the S1-U interface.')
param userPlaneAccessInterfaceName string = ''

@description('The virtual network name on port 6 on your Azure Stack Edge Pro device corresponding to the user plane interface on the data network. For 5G, this interface is the N6 interface; for 4G, it\'s the SGi interface.')
param userPlaneDataInterfaceName string = ''

@description('The network address of the subnet from which dynamic IP addresses must be allocated to UEs, given in CIDR notation. Optional if userEquipmentStaticAddressPoolPrefix is specified. If both are specified, they must be the same size and not overlap.')
param userEquipmentAddressPoolPrefix string = ''

@description('The network address of the subnet from which static IP addresses must be allocated to UEs, given in CIDR notation. Optional if userEquipmentAddressPoolPrefix is specified. If both are specified, they must be the same size and not overlap.')
param userEquipmentStaticAddressPoolPrefix string = ''

@description('The name of the data network')
param dataNetworkName string = 'internet'

@description('The desired installation state')
param desiredState string = 'Uninstalled'

@description('The MTU (in bytes) signaled to the UE. The same MTU is set on the user plane data links for all data networks. The MTU set on the user plane access link is calculated to be 60 bytes greater than this value to allow for GTP encapsulation. ')
param ueMtu int = 1440

@description('Provide consent for Microsoft to access non-PII telemetry information from the packet core.')
param allowSupportTelemetryAccess bool = true

@description('The mode in which the packet core instance will run')
@allowed([
  'EPC'
  '5GC'
  'EPC + 5GC'
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

@description('The resource ID of the customLocation representing the ASE device where the packet core will be deployed. If this parameter is not specified then the 5G core will be created but will not be deployed to an ASE. [Collect custom location information](https://docs.microsoft.com/en-gb/azure/private-5g-core/collect-required-information-for-a-site#collect-custom-location-information) explains which value to specify here.')
param customLocation string = ''

#disable-next-line BCP081
resource exampleMobileNetwork 'Microsoft.MobileNetwork/mobileNetworks@2024-04-01' = {
  name: mobileNetworkName
  location: location
  properties: {
    publicLandMobileNetworkIdentifier: {
      mcc: mobileCountryCode
      mnc: mobileNetworkCode
    }
  }
}

#disable-next-line BCP081
resource exampleSite 'Microsoft.MobileNetwork/mobileNetworks/sites@2024-04-01' = {
  parent: exampleMobileNetwork
  name: siteName
  location: location
}

#disable-next-line BCP081
resource exampleDataNetwork 'Microsoft.MobileNetwork/mobileNetworks/dataNetworks@2024-04-01' = {
  parent: exampleMobileNetwork
  name: dataNetworkName
  location: location
  properties: {}
}

#disable-next-line BCP081
resource exampleSlice 'Microsoft.MobileNetwork/mobileNetworks/slices@2024-04-01' = {
  parent: exampleMobileNetwork
  name: sliceName
  location: location
  properties: {
    snssai: {
      sst: 1
    }
  }
}

#disable-next-line BCP081
resource exampleService 'Microsoft.MobileNetwork/mobileNetworks/services@2024-04-01' = {
  parent: exampleMobileNetwork
  name: serviceName
  location: location
  properties: {
    servicePrecedence: 253
    pccRules: [
      {
        ruleName: 'All-traffic'
        rulePrecedence: 253
        trafficControl: 'Enabled'
        serviceDataFlowTemplates: [
          {
            templateName: 'Any-traffic'
            protocol: [
              'ip'
            ]
            direction: 'Bidirectional'
            remoteIpList: [
              'any'
            ]
          }
        ]
      }
    ]
  }
}

#disable-next-line BCP081
resource exampleSimPolicy 'Microsoft.MobileNetwork/mobileNetworks/simPolicies@2024-04-01' = {
  parent: exampleMobileNetwork
  name: simPolicyName
  location: location
  properties: {
    ueAmbr: {
      uplink: '2 Gbps'
      downlink: '2 Gbps'
    }
    defaultSlice: {
      id: exampleSlice.id
    }
    sliceConfigurations: [
      {
        slice: {
          id: exampleSlice.id
        }
        defaultDataNetwork: {
          id: exampleDataNetwork.id
        }
        dataNetworkConfigurations: [
          {
            dataNetwork: {
              id: exampleDataNetwork.id
            }
            sessionAmbr: {
              uplink: '2 Gbps'
              downlink: '2 Gbps'
            }
            allowedServices: [
              {
                id: exampleService.id
              }
            ]
          }
        ]
      }
    ]
  }
}

#disable-next-line BCP081
resource exampleSimGroupResource 'Microsoft.MobileNetwork/simGroups@2024-04-01' = if (!empty(simGroupName)) {
  name: empty(simGroupName) ? 'placeHolderForValidation' : simGroupName
  location: location
  properties: {
    mobileNetwork: {
      id: exampleMobileNetwork.id
    }
    encryptionKey: {
        keyUrl: existingEncryptionKeyUrl
    }
  }
  identity: !empty(existingUserAssignedIdentityResourceId) ? {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${existingUserAssignedIdentityResourceId}': {}
    }
  } : {
    type: 'None'
  }

  #disable-next-line BCP081
  resource exampleSimResources 'sims@2024-04-01' = [for item in simResources: {
    name: item.simName
    properties: {
      integratedCircuitCardIdentifier: item.integratedCircuitCardIdentifier
      internationalMobileSubscriberIdentity: item.internationalMobileSubscriberIdentity
      authenticationKey: item.authenticationKey
      operatorKeyCode: item.operatorKeyCode
      deviceType: item.deviceType
      simPolicy: {
        id: exampleSimPolicy.id
      }
    }
  }]
}

#disable-next-line BCP081
resource examplePacketCoreControlPlane 'Microsoft.MobileNetwork/packetCoreControlPlanes@2024-04-01' = {
  name: siteName
  location: location
  dependsOn: [
    exampleSlice
  ]
  properties: {
    sites: [
      {
        id: exampleSite.id
      }
    ]
    sku: 'G0'
    ueMtu: ueMtu
    userConsent: {
      allowSupportTelemetryAccess: allowSupportTelemetryAccess
    }
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
    installation:{
      desiredState: desiredState
    }
    localDiagnosticsAccess: {
      authenticationType: 'Password'
    }
    controlPlaneAccessInterface: {
      ipv4Address: controlPlaneAccessIpAddress
      name: controlPlaneAccessInterfaceName
    }
  }

  #disable-next-line BCP081
  resource examplePacketCoreDataPlane 'packetCoreDataPlanes@2024-04-01' = {
    name: siteName
    location: location
    properties: {
      userPlaneAccessInterface: {
        name: userPlaneAccessInterfaceName
      }
    }

    #disable-next-line BCP081
    resource exampleAttachedDataNetwork 'attachedDataNetworks@2024-04-01' = {
      name: dataNetworkName
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
