@description('Region of the FHIR service')
param resourceLocation string = resourceGroup().location

@description('Workspace containing the Azure Health Data Services workspace')
param workspaceName string

@description('Name of FHIR service')
param fhirName string

@description('Kind of the FHIR service to update')
@allowed([
  'fhir-R4'
  'fhir-Stu3'
])
param fhirKind string = 'fhir-R4'

@description('Name of storage account to use for import. Needs to be an existing storage account. Leave blank if this has already been configured.')
param storageName string = ''

@description('Flag to enable or disable $import')
param enableImport bool

// -- Module is required to get existing information from FHIR service
@description('Used to pull existing configuration from FHIR serviceß')
module existingFhir './existing_fhir.bicep' = {
  name: fhirName
  params: {
    fhirName: fhirName
    workspaceName: workspaceName
  }
}

@description('This is the existing AHDS workspace used to populate the updated resource')
resource existingWorkspace 'Microsoft.HealthcareApis/workspaces@2021-11-01' existing = {
  name: workspaceName
}

@description('Existing properties on the FHIR service')
var existingFhirProperties = existingFhir.outputs.properties

@description('If storage name is blank, leave the existing storage configuration')
var enableConfiguration = {
  enabled: true
  initialImportMode: true
  integrationDataStore: storageName
}

var disableConfiguration = {
  enabled: false
  initialImportMode: false
}

@description('Merge the new importConfiguration with existing properties')
var newProperties = union(existingFhirProperties, {
  importConfiguration: enableImport ? enableConfiguration : disableConfiguration
})

@description('Updated FHIR Service used to enable import')
resource fhir 'Microsoft.HealthcareApis/workspaces/fhirservices@2022-01-31-preview' = {
  name: fhirName
  parent: existingWorkspace
  location: resourceLocation
  kind: fhirKind

  identity: {
    type: 'SystemAssigned'
  }

  properties: newProperties

  dependsOn: [
    existingFhir
  ]
}

@description('Existing storage account used by FHIR service for $import')
resource existingStorageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing  = if (enableImport) {
  name: storageName
}

@description('Used to validate that the storage account exists when enabling import')
output storageAccountName string = enableImport ? existingStorageAccount.name : ''
