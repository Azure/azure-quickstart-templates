@description('The name of the Azure Analysis Services server to create. Server name must begin with a letter, be lowercase alphanumeric, and between 3 and 63 characters in length. Server name must be unique per region.')
param deidServiceName string

@description('Location of the Azure Analysis Services server. For supported regions, see https://docs.microsoft.com/en-us/azure/analysis-services/analysis-services-overview#availability-by-region')
param location string = resourceGroup().location

@description('Whether or not to create a system-assigned managed identity.')
param createSystemAssignedManagedIdentity bool = false

var identity = if (createSystemAssignedManagedIdentity) ? { type: 'SystemAssigned' } : null

resource deidentificationService 'Microsoft.HealthDataAIServices/deidServices@2024-02-28-preview' = {
  name: deidServiceName
  location: location
  identity: identity
}
