@description('Name of the VM')
param vmName string = 'WindowsVm'

@description('The name of the existing User assigned Managed Identity resource. In existing Key Vault this managed identity needs to be granted the role to access secret.')
param userAssignedIdentityName string

@description('Size of the VM')
param vmSize string = 'Standard_D2s_v3'

@description('Admin Username')
param adminUsername string

@description('Admin Password')
@secure()
param adminPassword string

@description('Resource Group of Key Vault that has a secret - must be of the format /subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/<vaultName>/providers/Microsoft.KeyVault/vaults/<vaultName>')
param vaultResourceId string

@description('Url of the certificate in Key Vault - the url must be to a base64 encoded secret, not a key or cert: https://<vaultEndpoint>/secrets/<secretName>/<secretVersion>')
param secretUrlWithVersion string

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
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

@description('Secure Boot setting of the virtual machine.')
param secureBoot bool = true

@description('vTPM setting of the virtual machine.')
param vTPM bool = true

@description('Location for all resources.')
param location string = resourceGroup().location

var extensionName = 'GuestAttestation'
var extensionPublisher = 'Microsoft.Azure.Security.WindowsAttestation'
var extensionVersion = '1.0'
var maaTenantName = 'GuestAttestation'
var subnet1Ref = resourceId('Microsoft.Network/virtualNetworks/subnets/', virtualNetworkName, subnet1Name)
var nicName = 'certNIC'
var subnet1Prefix = '10.0.0.0/24'
var subnet1Name = 'Subnet-1'
var virtualNetworkName = 'certVNET'
var addressPrefix = '10.0.0.0/16'
var publicIPName = 'certPublicIP'
var networkSecurityGroupName = '${subnet1Name}-nsg'

resource publicIP 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicIPName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
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

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
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
        name: subnet1Name
        properties: {
          addressPrefix: subnet1Prefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-04-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.id
          }
          subnet: {
            id: subnet1Ref
          }
        }
      }
    ]
  }
  dependsOn: [

    virtualNetwork
  ]
}

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId('Microsoft.ManagedIdentity/userAssignedIdentities/', userAssignedIdentityName)}': {}
    }
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      secrets: [
        {
          sourceVault: {
            id: vaultResourceId
          }
          vaultCertificates: [
            {
              certificateUrl: secretUrlWithVersion
              certificateStore: 'My'
            }
          ]
        }
      ]
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        caching: 'ReadWrite'
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
          id: nic.id
        }
      ]
    }
  }
}

resource vmName_GuestAttestation 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
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
          maaEndpoint: ''
          maaTenantName: maaTenantName
        }
        AscSettings: {
          ascReportingEndpoint: ''
          ascReportingFrequency: ''
        }
        useCustomToken: 'false'
        disableAlerts: 'false'
      }
    }
  }
}
