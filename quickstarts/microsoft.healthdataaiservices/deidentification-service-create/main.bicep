@description('The name of the Azure Health Data Services de-identification service to create. Name must be alphanumeric, between 1 and 30 characters in length, and unique per resource group.')
@minLength(1)
@maxLength(30)
param deidServiceName string

@description('Location of the Azure Health Data Services de-identification service.')
param location string = resourceGroup().location

@description('Whether or not to create a system-assigned managed identity.')
param createSystemAssignedManagedIdentity bool = false

var identity = (createSystemAssignedManagedIdentity) ? { type: 'SystemAssigned' } : {}

resource deidentificationService 'Microsoft.HealthDataAIServices/deidServices@2024-02-28-preview' = {
  name: deidServiceName
  location: location
  identity: identity
}

output deidServiceName string = deidentificationService.properties.serviceUrl
