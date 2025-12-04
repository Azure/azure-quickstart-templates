@description('The name of the Fleet resource.')
param fleetName string = 'my-hubful-fleet'

@description('The location of the Fleet resource.')
param location string = resourceGroup().location


resource hubful_fleet 'Microsoft.ContainerService/fleets@2025-03-01' = {
  name: fleetName
  location: location

  properties: {
    hubProfile: {
      dnsPrefix: fleetName
    }
  }
}
