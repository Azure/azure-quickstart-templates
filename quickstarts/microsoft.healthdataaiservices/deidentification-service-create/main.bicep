@description('The name of the Azure Health Data Services de-identification service to create. Name must be alphanumeric, between 1 and 30 characters in length, and unique per resource group.')
@minLength(1)
@maxLength(30)
param deidServiceName string

@description('Location of the Azure Health Data Services de-identification service.')
param location string = resourceGroup().location

resource deidentificationService 'Microsoft.HealthDataAIServices/deidServices@2024-09-20' = {
  name: deidServiceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}

output deidServiceName string = deidentificationService.properties.serviceUrl
