@description('Select any region to create resouces. You can default to the same region as the resource group.')
@allowed([
  'australiaeast'
  'brazilsouth'
  'canadacentral'
  'centralus'
  'westeurope'
  'germanywestcentral'
  'italynorth'
  'japaneast'
  'uksouth'
  'eastus'
  'eastus2'
  'southafricanorth'
  'southcentralus'
  'southeastasia'
  'switzerlandnorth'
  'swedencentral'
  'westus'
  'westus2'
  'westus3'
  'centralindia'
  'eastasia'
  'northeurope'
  'koreacentral'
  ''
])
param location string = ''

@description('The name of the Devcenter resource e.g. [devCenterName]')
param devCenterName string

@description('The name of the Project resource e.g. [projectName]')
param projectName string

@description('A default Dev Box definition with Windows 11 Enterprise, Visual Studio 2022, 16 cores, 64GB RAM, and 512GB storage. The name of the Dev Dox Definition resource e.g [devBoxDefintionName]')
param devBoxDefinitionName string

@description('A Microsoft Hosted Network Pool in the region of the resouce group. The name of the Pool resource e.g. [poolName]-[region]-pool')
param poolName string

var roleDefinitionId = '45d50f46-0b78-4001-a660-4198cbe8cd05'
var principalId = deployer().objectId
var principalType = 'User'
var formattedPoolName = '${poolName}-${location}-pool'
var poolPropertyAdmin = 'Enabled'
var poolPropertyNetworkType = 'Managed'
var poolPropertyNetworkName = 'mhn-network'
var image_win11_ent_vs2022 = 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
var compute_16c_64gb = 'general_i_16c64gb512ssd_v2'
var storage_512gb = '512gb'

resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' = {
  name: devCenterName
  location: location
  tags: {
    'hidden-created-with': 'devbox-quickstart-resource'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    projectCatalogSettings: {
      catalogItemSyncEnableStatus: 'Enabled'
    }
    networkSettings: {
      microsoftHostedNetworkEnableStatus: 'Enabled'
    }
    devBoxProvisioningSettings: {
      installAzureMonitorAgentEnableStatus: 'Enabled'
    }
  }
}

resource project 'Microsoft.DevCenter/projects@2023-04-01' = {
  name: projectName
  location: location
  tags: {
    'hidden-created-with': 'devbox-quickstart-resource'
  }
  properties: {
    devCenterId: devCenter.id
  }
}

resource principalId_roleDefinitionId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: project
  name: guid(subscription().id, resourceGroup().id, principalId, roleDefinitionId)
  properties: {
    description: 'Allows deployer to create dev boxes in the project resource.'
    principalId: principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}

resource devCenterName_devBoxDefinition 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-08-01-preview' = {
  parent: devCenter
  name: devBoxDefinitionName
  location: location
  tags: {
    'hidden-created-with': 'devbox-quickstart-resource'
  }
  properties: {
    imageReference: {
      id: '${devCenter.id}/galleries/default/images/${image_win11_ent_vs2022}'
    }
    sku: {
      name: compute_16c_64gb
    }
    osStorageType: 'ssd_${storage_512gb}'
  }
}

resource projectName_formattedPool 'Microsoft.DevCenter/projects/pools@2024-10-01-preview' = {
  parent: project
  name: formattedPoolName
  location: location
  tags: {
    'hidden-created-with': 'devbox-quickstart-resource'
  }
  properties: {
    devBoxDefinitionName: devBoxDefinitionName
    licenseType: 'Windows_Client'
    localAdministrator: poolPropertyAdmin
    managedVirtualNetworkRegions: [
      location
    ]
    virtualNetworkType: poolPropertyNetworkType
    networkConnectionName: '${poolPropertyNetworkName}-${location}'
  }
}
