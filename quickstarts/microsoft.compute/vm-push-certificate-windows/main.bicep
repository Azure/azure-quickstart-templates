@description('Name of the VM')
param vmName string = 'WindowsVm'

@description('Security Type of the Virtual Machine.')
@allowed([
  'Standard'
  'TrustedLaunch'
])
param securityType string = 'TrustedLaunch'

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

@description('Location for all resources.')
param location string = resourceGroup().location

var subnet1Ref = resourceId('Microsoft.Network/virtualNetworks/subnets/', virtualNetworkName, subnet1Name)
var nicName = 'certNIC'
var subnet1Prefix = '10.0.0.0/24'
var subnet1Name = 'Subnet-1'
var virtualNetworkName = 'certVNET'
var addressPrefix = '10.0.0.0/16'
var publicIPName = 'certPublicIP'
var networkSecurityGroupName = '${subnet1Name}-nsg'
var securityProfileJson = {
  uefiSettings: {
    secureBootEnabled: true
    vTpmEnabled: true
  }
  securityType: securityType
}
var extensionName = 'GuestAttestation'
var extensionPublisher = 'Microsoft.Azure.Security.WindowsAttestation'
var extensionVersion = '1.0'
var maaTenantName = 'GuestAttestation'
var maaEndpoint = substring('emptyString', 0, 0)

resource publicIP 'Microsoft.Network/publicIPAddresses@2019-06-01' = {
  name: publicIPName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-08-01' = {
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

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-06-01' = {
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

resource nic 'Microsoft.Network/networkInterfaces@2019-06-01' = {
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

resource vm 'Microsoft.Compute/virtualMachines@2019-07-01' = {
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
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : json('null'))
  }
}

resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if ((securityType == 'TrustedLaunch') && ((securityProfileJson.uefiSettings.secureBootEnabled == true) && (securityProfileJson.uefiSettings.vTpmEnabled == true))) {
  parent: vm
  name: extensionName
  location: location
  properties: {
    publisher: extensionPublisher
    type: extensionName
    typeHandlerVersion: extensionVersion
    autoUpgradeMinorVersion: true
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
