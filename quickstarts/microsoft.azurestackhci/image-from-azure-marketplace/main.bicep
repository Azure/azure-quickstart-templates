param customLocationName string
param location string
param imageName string
param osType string
param publisherId string
param offerId string
param planId string
param skuVersion string
param hyperVGeneration string

var customLocationId = resourceId('Microsoft.ExtendedLocation/customLocations', customLocationName)

resource image 'microsoft.azurestackhci/marketplacegalleryimages@2021-09-01-preview' = {
  extendedLocation: {
    name: customLocationId
    type: 'CustomLocation'
  }
  location: location
  name: imageName
  properties: {
    osType: osType
    resourceName: imageName
    hyperVGeneration: hyperVGeneration
    identifier: {
      publisher: publisherId
      offer: offerId
      sku: planId
    }
    version: {
      name: skuVersion
    }
  }
  tags: {}
}