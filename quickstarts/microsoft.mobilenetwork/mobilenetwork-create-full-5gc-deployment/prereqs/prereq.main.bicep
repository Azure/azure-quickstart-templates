@description('The name for the AzureStackEdgeName')
param azureStackEdgeName string

@description('Region where the AzureStackEdgeName will be deployed (must match the resource group region)')
param location string = resourceGroup().location

resource exampleAzureStackEdge 'Microsoft.DataBoxEdge/DataBoxEdgeDevices@2020-01-01' = {
  name: azureStackEdgeName
  location: location
}

output aseID string = exampleAzureStackEdge.id
