@minLength(3)
@maxLength(16)
@description('Basename that is used to name provisioned resources. Should be alphanumeric, at least 3 characters and up to or less than 16 characters.')
param basename string

@description('The location where the resources are deployed. ')
var location = 'eastus'

@description('The name of the Azure Health Data Services workspace.')
var workspaceName = replace('ws-${basename}', '-', '')

@description('The name of the FHIR service.')
var fhirServiceName = 'fhir-${basename}'

@description('The name of the DICOM service.')
var dicomServiceName = 'dicom-${basename}'

@description('The FHIR version to use. Defaults to R4.')
var fhirKind = 'fhir-R4'

@description('The Microsoft Entra tenant ID for FHIR authentication.')
var tenantId = subscription().tenantId

// Azure Health Data Services workspace
resource workspace 'Microsoft.HealthcareApis/workspaces@2024-03-31' = {
  name: workspaceName
  location: location
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

// FHIR service (child of workspace)
resource fhirService 'Microsoft.HealthcareApis/workspaces/fhirservices@2024-03-31' = {
  parent: workspace
  name: fhirServiceName
  location: location
  kind: fhirKind
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    authenticationConfiguration: {
      authority: '${environment().authentication.loginEndpoint}${tenantId}'
      audience: 'https://${workspaceName}-${fhirServiceName}.fhir.azurehealthcareapis.com'
    }
    publicNetworkAccess: 'Enabled'
  }
}

// DICOM service (child of workspace)
resource dicomService 'Microsoft.HealthcareApis/workspaces/dicomservices@2024-03-31' = {
  parent: workspace
  name: dicomServiceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

// Outputs
output workspaceId string = workspace.id
output fhirServiceId string = fhirService.id
output fhirServiceUrl string = 'https://${workspaceName}-${fhirServiceName}.fhir.azurehealthcareapis.com'
output dicomServiceId string = dicomService.id
output dicomServiceUrl string = dicomService.properties.serviceUrl
