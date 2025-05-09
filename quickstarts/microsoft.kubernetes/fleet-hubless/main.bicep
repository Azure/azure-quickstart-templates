@description('The name of the Fleet resource.')
param fleet_name string = 'my-hubless-fleet'

@description('The location of the Fleet resource.')
param location string = resourceGroup().location

resource hubless_fleet 'Microsoft.ContainerService/fleets@2025-03-01' = {
  name: fleet_name
  location: location
}
