param devcenterName string
param networkConnectionName string
param networkingResourceGroupName string
param subnetId string
param projectName string
param principalId string
param location string = resourceGroup().location
param managedIdentityName string
param galleryName string
param imageDefinitionName string
param imageTemplateName string

@allowed([
  'Group'
  'ServicePrincipal'
  'User'
])
param principalType string = 'User'
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

var image = {
  'win11-ent-base': 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-os'
  'win11-ent-m365': 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365'
  'win11-ent-vs2022': 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
}

var compute = {
  '8-vcpu-32gb-mem': 'general_a_8c32gb_v1'
}

var storage = {
  '256gb': 'ssd_256gb'
  '512gb': 'ssd_512gb'
  '1024gb': 'ssd_1024gb'
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: managedIdentityName
}

resource devcenter 'Microsoft.DevCenter/devcenters@2023-01-01-preview' = {
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

resource devcenterGallery 'Microsoft.DevCenter/devcenters/galleries@2023-01-01-preview' = {
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

resource networkConnection 'Microsoft.DevCenter/networkConnections@2023-01-01-preview' = {
  name: networkConnectionName
  location: location
  properties: {
    domainJoinType: 'AzureADJoin'
    subnetId: subnetId
    networkingResourceGroupName: networkingResourceGroupName
  }
}

resource attachedNetworks 'Microsoft.DevCenter/devcenters/attachednetworks@2023-01-01-preview' = {
  parent: devcenter
  name: networkConnection.name
  properties: {
    networkConnectionId: networkConnection.id
  }
}

resource dcGalleryImage 'Microsoft.DevCenter/devcenters/galleries/images@2022-11-11-preview' existing = {
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
      '${managedIdentity.id}': {}
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

resource builtinImageDevboxDefinitions 'Microsoft.DevCenter/devcenters/devboxdefinitions@2022-11-11-preview' = [for definition in devceterSettings.builtinImageDevboxDefinitions: {
  parent: devcenter
  name: definition.name
  location: location
  properties: {
    imageReference: {
      id: '${devcenter.id}/galleries/default/images/${image[definition.image]}'
    }
    sku: {
      name: compute[definition.compute]
    }
    osStorageType: storage[definition.storage]
  }
  dependsOn: [
    attachedNetworks
  ]
}]

resource customizedImageDevboxDefinitions 'Microsoft.DevCenter/devcenters/devboxdefinitions@2022-11-11-preview' = {
  parent: devcenter
  name: customizedImageDefinition.name
  location: location
  properties: {
    imageReference: {
      id: dcGalleryImage.id
    }
    sku: {
      name: compute[customizedImageDefinition.compute]
    }
    osStorageType: storage[customizedImageDefinition.storage]
  }
  dependsOn: [
    attachedNetworks
    imageTemplateBuild
  ]
}

resource project 'Microsoft.DevCenter/projects@2022-11-11-preview' = {
  name: projectName
  location: location
  properties: {
    devCenterId: devcenter.id
  }
}

resource builtinPools 'Microsoft.DevCenter/projects/pools@2023-01-01-preview' = [for pool in devceterSettings.builtinImagePools: {
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
    builtinImageDevboxDefinitions
  ]
}]

resource customizedImagePools 'Microsoft.DevCenter/projects/pools@2023-01-01-preview' = [for pool in devceterSettings.customizedImagePools: {
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

output builtinImageDevboxDefinitions array = [for (definition, i) in devceterSettings.builtinImageDevboxDefinitions: {
  name: builtinImageDevboxDefinitions[i].name
}]
output customizedImageDevboxDefinitions string = customizedImageDevboxDefinitions.name

output networkConnectionName string = networkConnection.name

output projectName string = project.name

output builtinImagePools array = [for (pool, i) in devceterSettings.builtinImagePools: {
  name: builtinPools[i].name
}]
output customizedImagePools array = [for (pool, i) in devceterSettings.customizedImagePools: {
  name: customizedImagePools[i].name
}]
