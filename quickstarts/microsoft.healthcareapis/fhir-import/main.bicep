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

@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'existing'

var enableConfiguration = {
  enabled: true
  initialImportMode: true
  integrationDataStore: storageName
}
var disableConfiguration = {
  enabled: false
  initialImportMode: false
}
var newDeployName = 'newdeploy${uniqueString(resourceGroup().id, fhirName)}'
var existingDeployName = 'existingdeploy${uniqueString(resourceGroup().id, fhirName)}'

@description('Updated FHIR Service used to enable import')
resource fhir 'Microsoft.HealthcareApis/workspaces/fhirservices@2022-06-01' = {
  name: '${workspaceName}/${fhirName}'
  location: resourceLocation
  kind: fhirKind
  identity: {
    type: 'SystemAssigned'
  }
  properties: union((newOrExisting == 'existing') ? existingDeploy.outputs.properties : newDeploy.outputs.properties, {
      importConfiguration: (enableImport ? enableConfiguration : disableConfiguration)
    })
}

@description('Used to pull existing configuration from FHIR serviceß')
module existingDeploy './nested_existingdeployname.bicep' = if (newOrExisting == 'existing') {
  name: existingDeployName
  params: {
    fhirName: fhirName
    workspaceName: workspaceName
  }
}

@description('Used to pull existing configuration from FHIR serviceß')
module newDeploy './nested_newdeployname.bicep' = if (newOrExisting == 'new') {
  name: newDeployName
  params: {
    fhirName: fhirName
    workspaceName: workspaceName
    resourceLocation: resourceLocation
  }
}

@description('Used to validate that the storage account exists when enabling import')
output storageAccountName string = (enableImport ? storageName : '')
