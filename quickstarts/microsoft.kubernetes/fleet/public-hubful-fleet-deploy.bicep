@description('The name of the Fleet resource.')
param fleet_name string = 'my-hubful-fleet'

@description('The location of the Fleet resource.')
param location string = resourceGroup().location


resource hubful_fleet 'Microsoft.ContainerService/fleets@2025-03-01' = {
  name: fleet_name
  location: location

  properties: {
    hubProfile: {
      dnsPrefix: fleet_name
    }
  }
}
