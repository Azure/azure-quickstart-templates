@description('Size of VMs in the VM Scale Set.')
param vmSku string = 'Standard_D2s_v3'

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
  '2019-DataCenter-GenSecond'
  '2016-DataCenter-GenSecond'
  '2022-datacenter-azure-edition'
])
param sku string = '2022-datacenter-azure-edition'

@description('String used as a base for naming resources. Must be 3-61 characters in length and globally unique across Azure. A hash is prepended to this string for some resources, and resource-specific information is appended.')
@maxLength(61)
param vmssName string

@description('Number of VM instances (100 or less).')
@minValue(1)
@maxValue(100)
param instanceCount int = 2

@description('Admin username on all VMs.')
param adminUsername string

@description('Admin password on all VMs.')
@secure()
param adminPassword string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name for the Public IP used to access the virtual machine scale set.')
param publicIpName string = 'myPublicIP'

@description('Allocation method for the Public IP used to access the virtual machine set.')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAllocationMethod string = 'Static'

@description('SKU for the Public IP used to access the virtual machine scale set.')
@allowed([
  'Basic'
  'Standard'
])
param publicIpSku string = 'Standard'

@description('Unique DNS Name for the Public IP used to access the virtual machine scale set.')
param dnsLabelPrefix string = toLower('${vmssName}-${uniqueString(resourceGroup().id)}')

@allowed([
  'TCP'
  'HTTP'
  'HTTPS'
])
param healthExtensionProtocol string = 'TCP'
param healthExtensionPort int = 3389
param healthExtensionRequestPath string = '/'
param overprovision bool = false

@allowed([
  'Manual'
  'Rolling'
  'Automatic'
])
param upgradePolicy string = 'Manual'
param maxBatchInstancePercent int = 20
param maxUnhealthyInstancePercent int = 20
param maxUnhealthyUpgradedInstancePercent int = 20
param pauseTimeBetweenBatches string = 'PT5S'

@description('Security Type of the Virtual Machine.')
@allowed([
  'Standard'
  'TrustedLaunch'
])
param securityType string = 'TrustedLaunch'

var namingInfix = toLower(substring('${vmssName}${uniqueString(resourceGroup().id)}', 0, 9))
var addressPrefix = '10.0.0.0/16'
var subnetPrefix = '10.0.0.0/24'
var virtualNetworkName = '${namingInfix}vnet'
var subnetName = '${namingInfix}subnet'
var loadBalancerName = '${namingInfix}lb'
var natPoolName = '${namingInfix}natpool'
var bePoolName = '${namingInfix}bepool'
var natStartPort = 50000
var natEndPort = 50119
var natBackendPort = 3389
var nicName = '${namingInfix}nic'
var ipConfigName = '${namingInfix}ipconfig'
var imageReference = {
  '2019-DataCenter-GenSecond': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2016-DataCenter-GenSecond': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
  '2022-datacenter-azure-edition': {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: sku
    version: 'latest'
  }
}
var extensionName = 'GuestAttestation'
var extensionPublisher = 'Microsoft.Azure.Security.WindowsAttestation'
var extensionVersion = '1.0'
var maaTenantName = 'GuestAttestation'
var maaEndpoint = substring('emptyString', 0, 0)
var securityProfileJson = {
  uefiSettings: {
    secureBootEnabled: true
    vTpmEnabled: true
  }
  securityType: securityType
}
var rollingUpgradeJson = {
  maxBatchInstancePercent: maxBatchInstancePercent
  maxUnhealthyInstancePercent: maxUnhealthyInstancePercent
  maxUnhealthyUpgradedInstancePercent: maxUnhealthyUpgradedInstancePercent
  pauseTimeBetweenBatches: pauseTimeBetweenBatches
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: publicIpName
  location: location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

resource loadBalancer 'Microsoft.Network/loadBalancers@2022-05-01' = {
  name: loadBalancerName
  location: location
  sku: {
    name: publicIpSku
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'LoadBalancerFrontEnd'
        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: bePoolName
      }
    ]
    inboundNatPools: [
      {
        name: natPoolName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName, 'loadBalancerFrontEnd')
          }
          protocol: 'Tcp'
          frontendPortRangeStart: natStartPort
          frontendPortRangeEnd: natEndPort
          backendPort: natBackendPort
        }
      }
    ]
  }
}

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2022-03-01' = {
  name: vmssName
  location: location
  sku: {
    name: vmSku
    tier: 'Standard'
    capacity: instanceCount
  }
  properties: {
    virtualMachineProfile: {
      storageProfile: {
        osDisk: {
          createOption: 'FromImage'
          caching: 'ReadWrite'
        }
        imageReference: imageReference[sku]
      }
      osProfile: {
        computerNamePrefix: namingInfix
        adminUsername: adminUsername
        adminPassword: adminPassword
      }
      securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : null)
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: nicName
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: ipConfigName
                  properties: {
                    subnet: {
                      id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
                    }
                    loadBalancerBackendAddressPools: [
                      {
                        id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, bePoolName)
                      }
                    ]
                    loadBalancerInboundNatPools: [
                      {
                        id: resourceId('Microsoft.Network/loadBalancers/inboundNatPools', loadBalancerName, natPoolName)
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
      extensionProfile: {
        extensions: [
          {
            name: 'HealthExtension'
            properties: {
              publisher: 'Microsoft.ManagedServices'
              type: 'ApplicationHealthWindows'
              typeHandlerVersion: '1.0'
              autoUpgradeMinorVersion: false
              settings: {
                protocol: healthExtensionProtocol
                port: healthExtensionPort
                requestPath: ((healthExtensionProtocol == 'TCP') ? null : healthExtensionRequestPath)
              }
            }
          }
        ]
      }
      diagnosticsProfile: {
        bootDiagnostics: {
          enabled: true
        }
      }
    }
    orchestrationMode: 'Uniform'
    overprovision: overprovision
    upgradePolicy: {
      mode: upgradePolicy
      rollingUpgradePolicy: ((upgradePolicy == 'Rolling') ? rollingUpgradeJson : null)
      automaticOSUpgradePolicy: {
        enableAutomaticOSUpgrade: true
      }
    }
  }
  dependsOn: [
    loadBalancer
    virtualNetwork
  ]
}

resource vmssExtension 'Microsoft.Compute/virtualMachineScaleSets/extensions@2022-03-01' = if ((securityType == 'TrustedLaunch') && ((securityProfileJson.uefiSettings.secureBootEnabled == true) && (securityProfileJson.uefiSettings.vTpmEnabled == true))) {
  parent: vmss
  name: extensionName
  location: location
  properties: {
    publisher: extensionPublisher
    type: extensionName
    typeHandlerVersion: extensionVersion
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: maaEndpoint
          maaTenantName: maaTenantName
        }
      }
    }
  }
}
