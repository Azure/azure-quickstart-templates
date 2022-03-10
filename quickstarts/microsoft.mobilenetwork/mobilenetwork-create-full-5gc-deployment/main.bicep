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

@description('An array containing properties of the SIM(s) you wish to create')
param simResources array

@description('The name of the SIM policy')
param simPolicyName string = 'Default-policy'

@description('The name of the slice')
param sliceName string = 'slice-1'

@description('The logical name for the packet core instance N2 signalling interface. This should match one of the interfaces configured on your Azure Stack Edge machine.')
param n2Name string = ''

@description('The IP address for the packet core instance N2 signaling interface')
param n2IpAddress string

@description('The logical name for the packet core instance N3 signalling interface. This should match one of the interfaces configured on your Azure Stack Edge machine.')
param n3Name string = ''

@description('The IP address for the packet core instance N3 interface')
param n3IpAddress string

@description('The network address of the access subnet in CIDR notation')
param n2N3Subnet string

@description('The access subnet default gateway')
param n2N3Gateway string

@description('The logical name for the packet core instance N6 signalling interface. This should match one of the interfaces configured on your Azure Stack Edge machine.')
param n6Name string = ''

@description('The IP address for the packet core instance N6 interface')
param n6IpAddress string

@description('The network address of the data subnet in CIDR notation')
param n6Subnet string

@description('The data subnet default gateway')
param n6Gateway string

@description('The network address of the subnet from which IP addresses must be allocated to UEs, given in CIDR notation')
param ueIpPoolPrefix string

@description('The name of the data network')
param dataNetworkName string = 'internet'

@description('The mode in which the packet core instance will run')
param coreNetworkTechnology string = '5GC'

@description('Whether or not Network Address and Port Translation (NAPT) should be enabled for this data network')
@allowed([
  'Enabled'
  'Disabled'
])
param naptEnabled string

@description('The resource ID of the customLocation representing the ASE device where the packet core will be deployed. If this parameter is not specified then the 5G core will be created but will not be deployed to an ASE. [Collect custom location information](https://docs.microsoft.com/en-gb/azure/private-5g-core/collect-required-information-for-a-site#collect-custom-location-information) explains which value to specify here.')
param customLocation string = ''

resource exampleMobileNetwork 'Microsoft.MobileNetwork/mobileNetworks@2022-03-01-preview' = {
  name: mobileNetworkName
  location: location
  properties: {
    publicLandMobileNetworkIdentifier: {
      mcc: mobileCountryCode
      mnc: mobileNetworkCode
    }
  }

  resource exampleDataNetwork 'dataNetworks@2022-03-01-preview' = {
    name: dataNetworkName
    location: location
    properties: {}
  }

  resource exampleSlice 'slices@2022-03-01-preview' = {
    name: sliceName
    location: location
    properties: {
      snssai: {
        sst: 1
      }
    }
  }

  resource exampleService 'services@2022-03-01-preview' = {
    name: serviceName
    location: location
    properties: {
      servicePrecedence: 253
      serviceQosPolicy: {
        maximumBitRate: {
          uplink: '2 Gbps'
          downlink: '2 Gbps'
        }
      }
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

  resource exampleSimPolicy 'simPolicies@2022-03-01-preview' = {
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

  resource exampleSite 'sites@2022-03-01-preview' = {
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

resource exampleSimResources 'Microsoft.MobileNetwork/sims@2022-03-01-preview' = [for item in simResources: {
  name: item.simName
  location: location
  properties: {
    integratedCircuitCardIdentifier: item.integratedCircuitCardIdentifier
    internationalMobileSubscriberIdentity: item.internationalMobileSubscriberIdentity
    authenticationKey: item.authenticationKey
    operatorKeyCode: item.operatorKeyCode
    deviceType: item.deviceType
    mobileNetwork: {
      id: exampleMobileNetwork.id
    }
    simPolicy: {
      id: exampleMobileNetwork::exampleSimPolicy.id
    }
  }
}]

resource examplePacketCoreControlPlane 'Microsoft.MobileNetwork/packetCoreControlPlanes@2022-03-01-preview' = {
  name: siteName
  location: location
  properties: {
    mobileNetwork: {
      id: exampleMobileNetwork.id
    }
    coreNetworkTechnology: coreNetworkTechnology
    customLocation: customLocation
    n2Interface: {
      ipv4Address: n2IpAddress
      ipv4Subnet: n2N3Subnet
      ipv4Gateway: n2N3Gateway
      name: n2Name
    }
  }

  resource examplePacketCoreDataPlane 'packetCoreDataPlanes@2022-03-01-preview' = {
    name: siteName
    location: location
    properties: {
      n3Interface: {
        ipv4Address: n3IpAddress
        ipv4Subnet: n2N3Subnet
        ipv4Gateway: n2N3Gateway
        name: n3Name
      }
    }

    resource exampleAttachedDataNetwork 'attachedDataNetworks@2022-03-01-preview' = {
      name: dataNetworkName
      location: location
      properties: {
        n6Interface: {
          ipv4Address: n6IpAddress
          ipv4Subnet: n6Subnet
          ipv4Gateway: n6Gateway
          name: n6Name
        }
        userEquipmentAddressPoolPrefix: [
          ueIpPoolPrefix
        ]
        naptConfiguration: {
          enabled: naptEnabled
        }
      }
    }
  }  
}
