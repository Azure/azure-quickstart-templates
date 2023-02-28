@description('Name of new Digital Twin resource name')
param digitalTwinsName string

@allowed([
  'westcentralus'
  'westus2'
  'westus3'
  'northeurope'
  'australiaeast'
  'westeurope'
  'eastus'
  'southcentralus'
  'southeastasia'
  'uksouth'
  'eastus2'
])
@description('Location of to be created resource')
param location string

// Creates Digital Twins instance
resource digitalTwins 'Microsoft.DigitalTwins/digitalTwinsInstances@2022-10-31' = {
  name: digitalTwinsName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}

output digitalTwinsIdentityPrincipalId string = digitalTwins.identity.principalId
output digitalTwinsIdentityTenantId string = digitalTwins.identity.tenantId
