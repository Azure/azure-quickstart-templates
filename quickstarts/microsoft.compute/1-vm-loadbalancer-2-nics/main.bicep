@description('Admin password.')
@secure()
param adminPassword string

@description('Admin username.')
param adminUsername string

@description('DNS for Load Balancer IP.')
param dnsNameforLBIP string

@description('Secure Boot setting of the virtual machine.')
param secureBoot bool = true

@description('vTPM setting of the virtual machine.')
param vTPM bool = true

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
  '2016-datacenter-gensecond'
  '2016-datacenter-server-core-g2'
  '2016-datacenter-server-core-smalldisk-g2'
  '2016-datacenter-smalldisk-g2'
  '2016-datacenter-with-containers-g2'
  '2016-datacenter-zhcn-g2'
  '2019-datacenter-core-g2'
  '2019-datacenter-core-smalldisk-g2'
  '2019-datacenter-core-with-containers-g2'
  '2019-datacenter-core-with-containers-smalldisk-g2'
  '2019-datacenter-gensecond'
  '2019-datacenter-smalldisk-g2'
  '2019-datacenter-with-containers-g2'
  '2019-datacenter-with-containers-smalldisk-g2'
  '2019-datacenter-zhcn-g2'
  '2022-datacenter-azure-edition'
  '2022-datacenter-azure-edition-core'
  '2022-datacenter-azure-edition-core-smalldisk'
  '2022-datacenter-azure-edition-smalldisk'
  '2022-datacenter-core-g2'
  '2022-datacenter-core-smalldisk-g2'
  '2022-datacenter-g2'
  '2022-datacenter-smalldisk-g2'
])
param OSVersion string = '2022-datacenter-azure-edition'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of storage account.')
param storageAccountName string = 'storage${uniqueString(resourceGroup().id)}'

@description('Size of the virtual machine.')
param vmSize string = 'Standard_D2s_v3'

var extensionName = 'GuestAttestation'
var extensionPublisher = 'Microsoft.Azure.Security.WindowsAttestation'
var extensionVersion = '1.0'
var maaEndpoint = substring('emptystring', 0, 0)
var maaTenantName = 'GuestAttestation'
var addressPrefix = '10.0.0.0/16'
var imageOffer = 'WindowsServer'
var imagePublisher = 'MicrosoftWindowsServer'
var imageSKU = OSVersion
var lbName = 'myLB'
var networkSecurityGroupName = '${subnetName}-nsg'
var nic1NamePrefix_var = 'nic1'
var nic2NamePrefix_var = 'nic2'
var publicIPAddressName = 'myPublicIP'
var publicIPAddressType = 'Dynamic'
var storageAccountType = 'Standard_LRS'
var subnetName = 'Subnet-1'
var subnetPrefix = '10.0.0.0/24'
var vmNamePrefix_var = 'myVM'
var vnetName = 'myVNET'

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
}

resource lb 'Microsoft.Network/loadBalancers@2020-05-01' = {
  name: lbName
  location: location
  properties: {
    frontendIPConfigurations: [
      {
        name: 'LoadBalancerFrontEnd'
        properties: {
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'BackendPool1'
      }
    ]
    inboundNatRules: [
      {
        name: 'RDP-VM0'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'LoadBalancerFrontEnd')
          }
          protocol: 'Tcp'
          frontendPort: 50001
          backendPort: 3389
          enableFloatingIP: false
        }
      }
    ]
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {}
}

resource nic1NamePrefix 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: nic1NamePrefix_var
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'BackendPool1')
            }
          ]
          loadBalancerInboundNatRules: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/inboundNatRules', lbName, 'RDP-VM0')
            }
          ]
        }
      }
    ]
  }
  dependsOn: [
    vnet
    lb
  ]
}

resource nic2NamePrefix 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: nic2NamePrefix_var
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
          }
        }
      }
    ]
  }
  dependsOn: [
    vnet
  ]
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIPAddressType
    dnsSettings: {
      domainNameLabel: dnsNameforLBIP
    }
  }
}

resource vmNamePrefix 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmNamePrefix_var
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmNamePrefix_var
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSKU
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: secureBoot
        vTpmEnabled: vTPM
      }
      securityType: 'TrustedLaunch'
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: nic1NamePrefix.id
        }
        {
          properties: {
            primary: false
          }
          id: nic2NamePrefix.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: reference(storageAccountName, '2019-06-01').primaryEndpoints.blob
      }
    }
  }
  dependsOn: [
    storageAccount

  ]
}

resource vmNamePrefix_GuestAttestation 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if (vTPM && secureBoot) {
  parent: vmNamePrefix
  name: 'GuestAttestation'
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

resource vnet 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: vnetName
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
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}
