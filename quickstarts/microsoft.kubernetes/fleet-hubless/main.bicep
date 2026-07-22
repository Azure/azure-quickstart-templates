@description('The name of the Fleet resource.')
param fleetName string = 'my-hubless-fleet'

@description('The location of the Fleet resource.')
param location string = resourceGroup().location

resource hubless_fleet 'Microsoft.ContainerService/fleets@2025-03-01' = {
  name: fleetName
  location: location
}
