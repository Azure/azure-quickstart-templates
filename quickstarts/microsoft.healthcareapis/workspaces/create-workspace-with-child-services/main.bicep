@description('The Azure region for all resources.')
param location string = resourceGroup().location

@minLength(3)
@maxLength(24)
@description('The name of the Azure Health Data Services workspace.')
param workspaceName string

@minLength(3)
@maxLength(24)
@description('The name of the FHIR service.')
param fhirServiceName string

@minLength(3)
@maxLength(24)
@description('The name of the DICOM service.')
param dicomServiceName string

@description('The FHIR version to use. Defaults to R4.')
param fhirKind string = 'fhir-R4'

@description('The Microsoft Entra tenant ID for FHIR authentication.')
param tenantId string = subscription().tenantId

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
