@description('Unique public DNS prefix for the deployment. The fqdn will look something like \'<dnsname>.westus.cloudapp.azure.com\'. Up to 62 chars, digits or dashes, lowercase, should start with a letter: must conform to \'^[a-z][a-z0-9-]{1,61}[a-z0-9]$\'.')
param dnsLabelPrefix string

@description('The name of the VM')
param vmName string = 'vm'

@description('The name of the administrator of the new VM. Exclusion list: \'admin\',\'administrator\'')
param adminUsername string = 'azureUser'

@description('The password for the administrator account of the new VM')
@secure()
param adminPassword string

@description('Public port number for RDP')
param rdpPort int = 50001

@description('Security Type of the Virtual Machine.')
@allowed([
  'Standard'
  'TrustedLaunch'
])
param securityType string = 'TrustedLaunch'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Size of the virtual machine')
param vmSize string = 'Standard_D2s_v3'

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
var storageAccountName = '${uniqueString(resourceGroup().id)}sardpvm'
var vNetName = 'rdpVNET'
var subnetName = 'Subnet'
var vnetAddressRange = '10.0.0.0/16'
var subnetAddressRange = '10.0.0.0/24'
var imagePublisher = 'MicrosoftWindowsServer'
var imageOffer = 'WindowsServer'
var imageSku = OSVersion
var networkSecurityGroupName = 'Subnet-nsg'

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'publicIp'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vNet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressRange
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressRange
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: vNet
  name: subnetName
}

resource loadBalancer 'Microsoft.Network/loadBalancers@2023-05-01' = {
  name: 'loadBalancer'
  location: location
  properties: {
    frontendIPConfigurations: [
      {
        name: 'LBFE'
        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'LBBAP'
      }
    ]
    inboundNatRules: [
      {
        name: 'rdp'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', 'loadBalancer', 'LBFE')
          }
          protocol: 'Tcp'
          frontendPort: rdpPort
          backendPort: 3389
          enableFloatingIP: false
        }
      }
    ]
  }
}

resource backendAddressPool 'Microsoft.Network/loadBalancers/backendAddressPools@2023-05-01' existing = {
  parent: loadBalancer
  name: 'LBBAP'
}

resource inboundNatRule 'Microsoft.Network/loadBalancers/inboundNatRules@2023-05-01' existing = {
  parent: loadBalancer
  name: 'rdp'
}

resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
          loadBalancerBackendAddressPools: [
            {
              id: backendAddressPool.id
            }
          ]
          loadBalancerInboundNatRules: [
            {
              id: inboundNatRule.id
            }
          ]
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : null)
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageAccount.properties.primaryEndpoints.blob
      }
    }
  }
}

resource guestAttestation 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = if ((securityType == 'TrustedLaunch') && ((securityProfileJson.uefiSettings.secureBootEnabled == true) && (securityProfileJson.uefiSettings.vTpmEnabled == true))) {
  parent: vm
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
        AscSettings: {
          ascReportingEndpoint: ''
          ascReportingFrequency: ''
        }
      }
    }
  }
}
