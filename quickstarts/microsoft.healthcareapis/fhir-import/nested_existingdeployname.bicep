@description('Name of the existing AHDS workspace')
param workspaceName string

@description('Name of the existing FHIR service')
param fhirName string

output properties object = reference(resourceId('Microsoft.HealthcareApis/workspaces/fhirservices', workspaceName, fhirName), '2023-02-28')
