@description('Specifies location of all resources.')
param location string = resourceGroup().location

@description('Specifies SSH public key that is used to authenticate with linux VM')
param csadminSshKey string

@description('Specifies name of the administrator account for linux VM')
@secure()
param adminUserName string

@description('Specifies password for the administrator account for linux VM')
@secure()
param ccadminRawPassword string

@description('Specifies where network traffic originates from for ingress NSG rules.')
param myIp string

@description('Specifies size of cyclecloud VM')
param vmSize string = 'Standard_D1_v2'

var roleDefinitions = {
  contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}

var saName = take('cclocker${replace(guid(resourceGroup().id), '-', '')}', 24)

var subnetName = 'Default'

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: 'cc-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          priority: 1000
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: myIp
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
      {
        name: 'HTTP'
        properties: {
          priority: 1010
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: myIp
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'HTTPS'
        properties: {
          priority: 1020
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: myIp
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: 'cc-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/22'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

resource pip 'Microsoft.Network/publicIpAddresses@2020-05-01' = {
  name: 'cycleserver-pip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: 'cycleserver-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets/', vnet.name, subnetName)
          }
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: saName
  location: location
  kind: 'Storage'
  sku: {
    name: 'Standard_LRS'
  }
}

resource mid 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'CycleCloud-MI'
  location: location
}

resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: 'cycleserver'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${mid.id}': {}
    }
  }
  properties: {
    osProfile: {
      computerName: 'CycleServer'
      adminUsername: adminUserName
      customData: loadTextContent('customData.txt')
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUserName}/.ssh/authorized_keys'
              keyData: csadminSshKey
            }
          ]
        }
      }
    }
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'OpenLogic'
        offer: 'CentOS'
        sku: '8_2'
        version: 'latest'
      }
      osDisk: {
        name: 'cycleserver-os'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
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

resource rbac 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, tenantResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.contributor), mid.id)
  properties: {
    roleDefinitionId: tenantResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.contributor)
    principalId: mid.properties.principalId
    principalType: 'ServicePrincipal'
  }
}
