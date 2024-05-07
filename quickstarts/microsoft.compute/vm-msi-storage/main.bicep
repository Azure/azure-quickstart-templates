@description('The name of you Virtual Machine.')
param vmName string = 'vm-msi'

@description('Username for the Virtual Machine.')
param adminUsername string

@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'sshPublicKey'

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = toLower('vm-msi-${uniqueString(resourceGroup().id)}')

@description('The offer of the Ubuntu image from which to launch the Virtual Machine.')
param imageOffer string = '0001-com-ubuntu-server-jammy'

@description('The SKU of the Ubuntu image from which to launch the Virtual Machine.')
param imageSku string = '22_04-lts-gen2'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The size of the VM')
param VmSize string = 'Standard_B2s'

@description('Name of the VNET')
param virtualNetworkName string = 'vNet'

@description('Name of the subnet in the virtual network')
param subnetName string = 'Subnet'

@description('Name of the Network Security Group')
param networkSecurityGroupName string = 'SecGroupNet'

@description('Resource group name for the storage account role assignment')
param storageAccountResourceGroupName string

@description('Storage account name the MSI will be given access to')
param storageAccountName string

@description('Security Type of the Virtual Machine.')
@allowed([
  'Standard'
  'TrustedLaunch'
])
param securityType string = 'TrustedLaunch'

@description('Role to assign to the MSI on the storage account')
@allowed([
  'StorageBlobDataContributor'
  'StorageBlobDataOwner'
  'StorageBlobDataReader'
])
param msiRole string = 'StorageBlobDataReader'

var extensionName = 'GuestAttestation'
var extensionPublisher = 'Microsoft.Azure.Security.LinuxAttestation'
var extensionVersion = '1.0'
var maaTenantName = 'GuestAttestation'
var securityProfileJson = {
  uefiSettings: {
    secureBootEnabled: true
    vTpmEnabled: true
  }
  securityType: securityType
}
var publicIpAddressName = '${vmName}PublicIP'
var networkInterfaceName = '${vmName}NetInt'
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
var osDiskType = 'StandardSSD_LRS'
var subnetAddressPrefix = '10.1.0.0/24'
var addressPrefix = '10.1.0.0/16'
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}
var roleDefinitionId = {
  StorageBlobDataContributor: subscriptionResourceId('Microsoft.Authorization/roleAssignments', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  StorageBlobDataOwner: subscriptionResourceId('Microsoft.Authorization/roleAssignments', 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b')
  StorageBlobDataReader: subscriptionResourceId('Microsoft.Authorization/roleAssignments', '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1')
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-11-01' = {
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
          addressPrefix: subnetAddressPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: publicIpAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
    idleTimeoutInMinutes: 4
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          priority: 1000
          protocol: 'TCP'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2022-11-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpAddress.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
  dependsOn: [

    virtualNetwork

  ]
}

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: VmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: imageOffer
        sku: imageSku
        version: 'latest'
      }
    }
    securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : null)
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}

resource vmName_GuestAttestation 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = if ((securityType == 'TrustedLaunch') && ((securityProfileJson.uefiSettings.secureBootEnabled == true) && (securityProfileJson.uefiSettings.vTpmEnabled == true))) {
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

module assignRole './nested_assignRole.bicep' = {
  name: 'assignRole'
  scope: resourceGroup(storageAccountResourceGroupName)
  params: {
    storageAccountName: storageAccountName
    assignedRoleDefinitionId: roleDefinitionId[msiRole]
    principalId: vm.identity.principalId
  }
}

output adminUsername string = adminUsername
output hostname string = publicIpAddress.properties.dnsSettings.fqdn
output sshCommand string = 'ssh ${adminUsername}@${publicIpAddress.properties.dnsSettings.fqdn}'
