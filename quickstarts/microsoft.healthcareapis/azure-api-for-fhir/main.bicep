@description('The name of the service.')
param serviceName string

@description('Location of Azure API for FHIR')
@allowed([
  'australiaeast'
  'eastus'
  'eastus2'
  'japaneast'
  'northcentralus'
  'northeurope'
  'southcentralus'
  'southeastasia'
  'uksouth'
  'ukwest'
  'westcentralus'
  'westeurope'
  'westus2'
])
param location string

resource service 'Microsoft.HealthcareApis/services@2021-11-01' = {
  name: serviceName
  location: location
  kind: 'fhir-R4'
  properties: {
    authenticationConfiguration: {
      audience: 'https://${serviceName}.azurehealthcareapis.com'
      authority: uri(environment().authentication.loginEndpoint, subscription().tenantId)
    }
  }
}
