@description('The name of Dev Center e.g. dc-devbox-test')
param devcenterName string

@description('The name of Network Connection e.g. con-devbox-test')
param networkConnectionName string

@description('The name of Dev Center project e.g. dcprj-devbox-test')
param projectName string

@description('The resource group name of Network Connection e.g. rg-devbox-test')
param networkingResourceGroupName string

@description('The resource id of Virtual network subnet')
param subnetId string

@description('The user or group id that will be granted to Devcenter Dev Box User role')
param principalId string

@description('Primary location for all resources e.g. eastus')
param location string = resourceGroup().location

@allowed([
  'Group'
  'ServicePrincipal'
  'User'
])
param principalType string = 'User'

// DevCenter Dev Box User role definition id
var roleDefinitionId = '45d50f46-0b78-4001-a660-4198cbe8cd05'

var devceterSettings = loadJsonContent('./devcenter-settings.json')

var image = {
  'win11-ent-base': 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-os'
  'win11-ent-m365': 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365'
  'win11-ent-vs2022': 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
}

var compute = {
  '8c-32gb': 'general_i_8c32gb256ssd_v2'
  '16c-64gb': 'general_i_16c64gb512ssd_v2'
  '32c-128gb': 'general_i_32c128gb1024ssd_v2'
}

resource devcenter 'Microsoft.DevCenter/devcenters@2023-01-01-preview' = {
  name: devcenterName
  location: location
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

resource devboxDefinitions 'Microsoft.DevCenter/devcenters/devboxdefinitions@2022-11-11-preview' = [for definition in devceterSettings.definitions: {
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
    osStorageType: 'ssd_${definition.storage}'
  }
  dependsOn: [
    attachedNetworks
  ]
}]

resource project 'Microsoft.DevCenter/projects@2022-11-11-preview' = {
  name: projectName
  location: location
  properties: {
    devCenterId: devcenter.id
  }
  resource pools 'pools' = [for pool in devceterSettings.pools: {
    name: pool.name
    location: location
    properties: {
      devBoxDefinitionName: pool.definition
      networkConnectionName: networkConnection.name
      licenseType: 'Windows_Client'
      localAdministrator: pool.administrator
      
    }
  }]
  dependsOn: [
    devboxDefinitions
  ]
}

resource role 'Microsoft.Authorization/roleAssignments@2022-04-01' = if(!empty(principalId)) {
  name: guid(subscription().id, resourceGroup().id, principalId, roleDefinitionId)
  scope: project
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}

output devcenterName string = devcenter.name

output definitions array = [for (definition, i) in devceterSettings.definitions: {
  name: devboxDefinitions[i].name
}]

output networkConnectionName string = networkConnection.name

output projectName string = project.name

output poolNames array = [for (pool, i) in devceterSettings.pools: {
  name: project::pools[i].name
}]
