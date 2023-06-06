param storageContainerName string = 'csv-defaultvms3'
param location string = 'eastus'
param customLocationName string = 'mtbhcicluster-cl'

var customLocationId = resourceId('Microsoft.ExtendedLocation/customLocations', customLocationName)

resource storageContainer 'Microsoft.AzureStackHCI/storageContainers@2021-09-01-preview' = {
  name: storageContainerName
  location: location
  extendedLocation: {
    type: 'CustomLocation'
    name: customLocationId
  }
  properties: {
    path: 'C:\\ClusterStorage\\CSV-DefaultVMs'
    resourceName: storageContainerName
  }
}
