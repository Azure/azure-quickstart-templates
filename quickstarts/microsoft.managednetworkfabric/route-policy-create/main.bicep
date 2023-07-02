@description('Name of the Route Policy')
param routePolicyName string

@description('Azure Region for deployment of the Route Policy and associated resources')
param location string = resourceGroup().location

@description('Route Policy statements')
param statements array

@description('Switch configuration description')
param annotation string

@description('Create Route Policy')
resource routePolicies 'Microsoft.ManagedNetworkFabric/routePolicies@2023-06-15' = {
  name: routePolicyName
  location: location
  properties: {
    annotation: annotation
    statements: statements
  }
}

output resourceID string = routePolicies.id
