@description('The name of Dev Center e.g. dc-devbox-test')
param devcenterName string

@description('The name of Network Connection e.g. con-devbox-test')
param networkConnectionName string

@description('The name of Resource Group hosting network connection e.g. rg-con-devbox-test-eastus')
param networkingResourceGroupName string

@description('The subnet id hosting Dev Box')
param subnetId string

@description('The name of Dev Center project e.g. dcprj-devbox-test')
param projectName string

@description('The user or group id that will be granted to Devcenter Dev Box User and Deployment Environments User role')
param principalId string

@description('Primary location for all resources e.g. eastus')
param location string = resourceGroup().location

@description('The name of Dev Center user identity')
param managedIdentityName string

@description('The name of Azure Compute Gallery')
param galleryName string

@description('The name of Azure Compute Gallery image definition')
param imageDefinitionName string

@description('The name of image template for customized image')
param imageTemplateName string

@description('The type of principal id: User or Group')
param principalType string = 'User'

@description('The id of template identity user can read the image template status')
param templateIdentityId string

@description('The guid id that generat the different name for image template. Please keep it by default')
param guidId string

// DevCenter Dev Box User role 
var DEVCENTER_DEVBOX_USER_ROLE = '45d50f46-0b78-4001-a660-4198cbe8cd05'

var CONTRIBUTOR_ROLE = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
var READER_ROLE = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
// Used when Dev Center associate with Azure Compute Gallery
var WINDOWS365_PRINCIPALID = '8eec7c09-06ae-48e9-aafd-9fb31a5d5175'

var devceterSettings = loadJsonContent('./devcenter-settings.json')
var customizedImageDefinition = devceterSettings.customizedImageDevboxdefinitions[0]
var queryTemplateProgress = take('${imageDefinitionName}-${guidId}-query',64)

var compute = {
  '8c-32gb': 'general_i_8c32gb256ssd_v2'
  '16c-64gb': 'general_i_8c32gb512ssd_v2'
  '32c-128gb': 'general_i_8c32gb1024ssd_v2'
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: managedIdentityName
}

resource devcenter 'Microsoft.DevCenter/devcenters@2023-04-01' = {
  name: devcenterName
  location: location
  identity: {
    type:  'UserAssigned'
     userAssignedIdentities: {
      '${managedIdentity.id}': {}
     }
  }
}

resource computeGallery 'Microsoft.Compute/galleries@2022-03-03' existing = {
  name: galleryName
}

resource contirbutorGalleryRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, managedIdentity.id, CONTRIBUTOR_ROLE)
  scope: computeGallery
  properties: {
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', CONTRIBUTOR_ROLE)
  }
}

resource readGalleryRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, WINDOWS365_PRINCIPALID, READER_ROLE)
  scope: computeGallery
  properties: {
    principalId: WINDOWS365_PRINCIPALID
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', READER_ROLE)
  }
}

resource devcenterGallery 'Microsoft.DevCenter/devcenters/galleries@2023-04-01' = {
  name: galleryName
  parent: devcenter
  properties: {
    galleryResourceId: computeGallery.id
  }
  dependsOn: [
    readGalleryRole
    contirbutorGalleryRole
  ]
}

resource networkConnection 'Microsoft.DevCenter/networkConnections@2023-04-01' = {
  name: networkConnectionName
  location: location
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: subnetId
    networkingResourceGroupName: networkingResourceGroupName
  }
}

resource attachedNetworks 'Microsoft.DevCenter/devcenters/attachednetworks@2023-04-01' = {
  parent: devcenter
  name: networkConnection.name
  properties: {
    networkConnectionId: networkConnection.id
  }
}

resource dcGalleryImage 'Microsoft.DevCenter/devcenters/galleries/images@2023-04-01' existing = {
  name: imageDefinitionName
  parent: devcenterGallery
}

resource imageTemplateBuild 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: queryTemplateProgress
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${templateIdentityId}': {}
    }
  }
  properties: {
    azPowerShellVersion: '8.3'
    scriptContent: 'Connect-AzAccount -Identity; \'Az.ImageBuilder\', \'Az.ManagedServiceIdentity\' | ForEach-Object {Install-Module -Name $_ -AllowPrerelease -Force}; $status=\'Started\'; while ($status -ne \'Succeeded\' -and $status -ne \'Failed\' -and $status -ne \'Cancelled\') { Start-Sleep -Seconds 30;$status = (Get-AzImageBuilderTemplate -ImageTemplateName ${imageTemplateName} -ResourceGroupName ${resourceGroup().name}).LastRunStatusRunState}'
    timeout: 'PT2H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

resource customizedImageDevboxDefinitions 'Microsoft.DevCenter/devcenters/devboxdefinitions@2023-04-01' = {
  parent: devcenter
  name: customizedImageDefinition.name
  location: location
  properties: {
    imageReference: {
      id: dcGalleryImage.id
    }
    hibernateSupport: 'Enabled'
    sku: {
      name: compute[customizedImageDefinition.compute]
    }
  }
  dependsOn: [
    attachedNetworks
    imageTemplateBuild
  ]
}

resource project 'Microsoft.DevCenter/projects@2023-04-01' = {
  name: projectName
  location: location
  properties: {
    devCenterId: devcenter.id
  }
}

resource customizedImagePools 'Microsoft.DevCenter/projects/pools@2023-04-01' = [for pool in devceterSettings.customizedImagePools: {
  parent: project
  name: pool.name
  location: location
  properties: {
    devBoxDefinitionName: pool.definition
    networkConnectionName: networkConnection.name
    licenseType: 'Windows_Client'
    localAdministrator: pool.administrator
    
  }
  dependsOn: [
    customizedImageDevboxDefinitions
    imageTemplateBuild
  ]
}]

resource devboxRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if(!empty(principalId)) {
  name: guid(subscription().id, resourceGroup().id, principalId, DEVCENTER_DEVBOX_USER_ROLE)
  scope: project
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', DEVCENTER_DEVBOX_USER_ROLE)
  }
}

output devcenterName string = devcenter.name
output customizedImageDevboxDefinitions string = customizedImageDevboxDefinitions.name
output networkConnectionName string = networkConnection.name
output projectName string = project.name
output customizedImagePools array = [for (pool, i) in devceterSettings.customizedImagePools: {
  name: customizedImagePools[i].name
}]
