@maxLength(15) // maxlength 15 for Windows
param name string
param location string
param vCPUCount int = 2
param memoryGB int = 4
param adminUsername string
@description('The name of the Azure Stack HCI image to use for the virtual machine. This can be either a marketplace image or a custom image.')
param imageName string
@description('If the source image was created directly from the Azure Marketpace, use "Marketplace"; otherwise, if it was created from a custom image, use "Custom".')
@allowed(['Marketplace', 'Custom'])
param imageType string
@description('The name of the Azure Stack HCI virtual network to use for the virtual machine. This must already exist.')
param hciVirtualNetworkName string
param customLocationName string
@description('The name of the Azure Stack HCI storage container to use for the virtual machine. This is sometimes called a Storage Path and must already exist--see the prerequ.main.bicep file for an example.')
param storageContainerName string
@secure()
param adminPassword string

var nicName = 'nic-${name}'
var customLocationId = resourceId('Microsoft.ExtendedLocation/customLocations', customLocationName)
var fullImageType = imageType == 'Marketplace' ? 'microsoft.azurestackhci/marketplaceGalleryImages' : 'microsoft.azurestackhci/galleryImages'

resource virtualMachine 'Microsoft.AzureStackHCI/virtualmachines@2021-09-01-preview' = {
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
      osType: 'Windows'
      computerName: name
      windowsConfiguration: {
        provisionVMAgent: true
      }
    }
    storageProfile: {
      imageReference: {
        name: resourceId(fullImageType, imageName)
      }
      vmConfigContainerName: storageContainerName
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
