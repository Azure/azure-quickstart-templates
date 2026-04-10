@maxLength(15)
param name string
param location string
param vCPUCount int = 2
param memoryMB int = 8192
param adminUsername string
@description('The name of a custom already created on the Azure Stack HCI cluster. For example: ubuntu-01')
param imageName string
@description('The name of an existing Logical Network in your HCI cluster - for example: vnet-compute-vlan240-dhcp')
param hciLogicalNetworkName string
@description('The name of the custom location to use for the deployment. This name is specified during the deployment of the Azure Stack HCI cluster and can be found on the Azure Stack HCI cluster resource Overview in the Azure portal.')
param customLocationName string
@secure()
param adminPassword string
param sshPublicKey string = ''

var nicName = 'nic-${name}' // name of the NIC to be created
var customLocationId = resourceId('Microsoft.ExtendedLocation/customLocations', customLocationName) // full custom location ID
var galleryImageId = resourceId('microsoft.azurestackhci/galleryimages', imageName) // full marketplace gallery image ID
var logicalNetworkId = resourceId('microsoft.azurestackhci/logicalnetworks', hciLogicalNetworkName) // full logical network ID

// precreate an Arc Connected Machine with an identity--used for zero-touch onboarding of the Arc VM during deployment
resource hybridComputeMachine 'Microsoft.HybridCompute/machines@2024-05-20-preview' = {
  name: name
  location: location
  kind: 'HCI'
  identity: {
    type: 'SystemAssigned'
  }
}

resource nic 'Microsoft.AzureStackHCI/networkInterfaces@2024-01-01' = {
  name: nicName
  location: location
  extendedLocation: {
    type: 'CustomLocation'
    name: customLocationId
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          // uncomment to specify an IP, otherwise an IP address is dynamically allocated from the Logical Network's address pool
          // privateIPAddress: 'x.x.x.x'
          subnet: {
            id: logicalNetworkId
          }
        }
      }
    ]
  }
}

resource virtualMachine 'Microsoft.AzureStackHCI/virtualMachineInstances@2024-01-01' = {
  name: 'default' // value must be 'default' per 2023-09-01-preview
  properties: {
    hardwareProfile: {
      vmSize: 'Custom'
      processors: vCPUCount
      memoryMB: memoryMB
      // ### uncomment to use dymamic memory ###
      // dynamicMemoryConfig: {
      //   maximumMemoryMB: memoryMB
      //   minimumMemoryMB: 512
      //   targetMemoryBuffer: 20
      // }
    }
    osProfile: {
      adminUsername: adminUsername
      adminPassword: adminPassword

      computerName: name
      linuxConfiguration: {
        provisionVMAgent: true // mocguestagent
        provisionVMConfigAgent: true // azure arc connected machine agent
        ssh: empty(sshPublicKey) ? null : {
          publicKeys: [
            {
              keyData: sshPublicKey
            }
          ]
        }
        disablePasswordAuthentication: empty(sshPublicKey) ? false : true
      }
    }
    storageProfile: {
      imageReference: {
        id: galleryImageId
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
  extendedLocation: {
    type: 'CustomLocation'
    name: customLocationId
  }
  scope: hybridComputeMachine
}
