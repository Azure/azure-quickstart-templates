@description('Username for Hazelcast VMs')
param adminUsername string

@description('Type of authentication to use on the Hazelcast VMs.')
@allowed([
  'password'
  'sshPublicKey'
])
param authenticationType string = 'sshPublicKey'

@description('Password or ssh key for the Hazelcast VMs.')
@secure()
param adminPasswordOrKey string

@description('Hazelcast Version')
@allowed([
  '4.0'
])
param hazelcastVersion string = '4.0'

@description('Cluster Name for hazelcast grid')
param clusterName string = '${adminUsername}${uniqueString(resourceGroup().id)}'

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsPrefix string = 'hazelcast'

@description('The number of hazelcast nodes in the grid')
param instanceCount int = 2

@description('The cluster port to identify this cluster')
param clusterPort string = '5701'

@description('The size of each instance VM')
param vmSize string = 'Standard_D2s_v3'

@description('The Ubuntu OS version for the Hazelcast VM. This will pick a fully patched image of this given Ubuntu version.')
@allowed([
  '15.10'
  '16.04-LTS'
  '18.04-LTS'
])
param ubuntuOSVersion string = '16.04-LTS'

@description('The base URL for the bootstrap files')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated. Use the defaultValue if the staging location is not secured.')
@secure()
param _artifactsLocationSasToken string = ''

@description('Location for all resources.')
param location string = resourceGroup().location

var imagePublisher = 'Canonical'
var imageOffer = 'UbuntuServer'
var nicName = 'hazelcastNic'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'Subnet'
var subnetPrefix = '10.0.1.0/24'
var publicIPAddressName = 'hazelcastPubIp'
var publicIPAddressType = 'Dynamic'
var vmName = 'hazelcast'
var roleAssignmentName = 'hazelcastRA'
var virtualNetworkName = 'hazelcastVNet'
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
var Reader = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
var scriptParameters = '${clusterName} ${hazelcastVersion} ${clusterPort}'
var bootstrapFiles = [
  uri(_artifactsLocation, 'scripts/bootstrap_hazelcast${_artifactsLocationSasToken}')
  uri(_artifactsLocation, 'scripts/hazelcast.service${_artifactsLocationSasToken}')
  uri(_artifactsLocation, 'scripts/hazelcast.conf${_artifactsLocationSasToken}')
  uri(_artifactsLocation, 'scripts/hazelcast.xml${_artifactsLocationSasToken}')
  uri(_artifactsLocation, 'scripts/install_hazelcast${_artifactsLocationSasToken}')
  uri(_artifactsLocation, 'scripts/logging.properties${_artifactsLocationSasToken}')
  uri(_artifactsLocation, 'scripts/modify_configuration${_artifactsLocationSasToken}')
  uri(_artifactsLocation, 'scripts/modify_version${_artifactsLocationSasToken}')
  uri(_artifactsLocation, 'scripts/pom.xml${_artifactsLocationSasToken}')
]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-09-01' = {
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

resource publicIPAddressName_1 'Microsoft.Network/publicIPAddresses@2022-09-01' = [for i in range(0, instanceCount): {
  name: '${publicIPAddressName}${(i + 1)}'
  location: location
  properties: {
    publicIPAllocationMethod: publicIPAddressType
    dnsSettings: {
      domainNameLabel: '${dnsPrefix}${(i + 1)}${uniqueString(resourceGroup().id)}'
    }
  }
}]

resource nicName_1 'Microsoft.Network/networkInterfaces@2022-09-01' = [for i in range(0, instanceCount): {
  name: '${nicName}${(i + 1)}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig${(i + 1)}'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', '${publicIPAddressName}${(i + 1)}')
          }
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork
    publicIPAddressName_1
  ]
}]

resource vmName_1 'Microsoft.Compute/virtualMachines@2022-11-01' = [for i in range(0, instanceCount): {
  name: '${vmName}${(i + 1)}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: ubuntuOSVersion
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}${(i + 1)}_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${nicName}${(i + 1)}')
        }
      ]
    }
  }
  dependsOn: [
    nicName_1
  ]
}]

resource roleAssignmentName_1 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for i in range(0, instanceCount): {
  name: guid('${roleAssignmentName}${(i + 1)}')
  properties: {
    roleDefinitionId: Reader
    principalId: reference(resourceId('Microsoft.Compute/virtualMachines', '${vmName}${(i + 1)}'), '2019-12-01', 'Full').identity.principalId
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    vmName_1
  ]
}]

resource vmName_1_initHazelcast 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = [for i in range(0, instanceCount): {
  name: '${vmName}${(i + 1)}/initHazelcast'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: bootstrapFiles
    }
    protectedSettings: {
      commandToExecute: 'sh bootstrap_hazelcast ${scriptParameters}'
    }
  }
  dependsOn: [
    roleAssignmentName_1
  ]
}]
