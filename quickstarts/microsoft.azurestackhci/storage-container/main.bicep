param storageContainerName string
param hciLocalPath string
param location string
param customLocationName string 

var customLocationId = resourceId('Microsoft.ExtendedLocation/customLocations', customLocationName)

resource storageContainer 'Microsoft.AzureStackHCI/storageContainers@2021-09-01-preview' = {
  name: storageContainerName
  location: location
  extendedLocation: {
    type: 'CustomLocation'
    name: customLocationId
  }
  properties: {
    path: hciLocalPath
    resourceName: storageContainerName
  }
}
