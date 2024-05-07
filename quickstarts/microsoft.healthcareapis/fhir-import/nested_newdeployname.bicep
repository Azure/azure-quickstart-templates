@description('Name of the existing AHDS workspace')
param workspaceName string

@description('Name of the existing FHIR service')
param fhirName string

@description('Region of the FHIR service')
param resourceLocation string

resource workspace 'Microsoft.HealthcareApis/workspaces@2022-06-01' = {
  name: workspaceName
  location: resourceLocation
  properties: {
  }
}

output properties object = {
  authenticationConfiguration: {
    authority: '${environment().authentication.loginEndpoint}${subscription().tenantId}'
    audience: 'https://${workspaceName}-${fhirName}.fhir.azurehealthcareapis.com'
    smartProxyEnabled: false
  }
}
