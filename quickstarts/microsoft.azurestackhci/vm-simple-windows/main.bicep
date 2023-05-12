param name string
param location string
param vCPUCount int = 2
param memoryGB int = 4
param adminUsername string
param imageName string
param hciVirtualNetworkName string
param customLocationName string
@secure()
param adminPassword string

var nicName = 'nic-${name}'
var customLocationId = resourceId('Microsoft.ExtendedLocation/customLocations', customLocationName)

resource name_resource 'Microsoft.AzureStackHCI/virtualmachines@2021-09-01-preview' = {
  name: name
  location: location
  properties: {
    resourceName: name
    hardwareProfile: {
      processors: vCPUCount
      memoryGB: memoryGB
    }
    osProfile: {
      adminUsername: adminUsername
      adminPassword: adminPassword
      osType: 'windows'
      computerName: name
      windowsConfiguration: {
        provisionVMAgent: true
      }
    }
    storageProfile: {
      imageReference: {
        name: resourceId('microsoft.azurestackhci/marketplaceGalleryImages', imageName)
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
  identity: {
    type: 'SystemAssigned'
  }
}

resource nic 'Microsoft.AzureStackHCI/networkinterfaces@2021-09-01-preview' = {
  name: nicName
  location: location
  extendedLocation: {
    type: 'CustomLocation'
    name: customLocationId
  }
  properties: {
    resourceName: nicName
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('microsoft.azurestackhci/virtualnetworks', hciVirtualNetworkName)
          }
        }
      }
    ]
  }
}
