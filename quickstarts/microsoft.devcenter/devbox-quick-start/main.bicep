param projectName string = 'default-project-name'
param devCenterName string = 'default-dc-name'
param devBoxDefinitionName string = 'default-dbd-name'
param poolName string = 'default-pool-name'

var location = resourceGroup().location
var poolPropertyAdmin = 'Enabled'
var poolPropertyNetworkType = 'Managed'
var poolPropertyNetworkName = 'Network'
var image_win11_ent_vs2022 = 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
var compute_16c_64gb = 'general_i_16c64gb512ssd_v2'
var storage_512gb = '512gb'

resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' = {
  name: devCenterName
  location: location
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
  dependsOn: []
}

resource project 'Microsoft.DevCenter/projects@2023-04-01' = {
  name: projectName
  location: location
  properties: {
    devCenterId: devCenter.id
  }
}

resource devcenterName_devBoxDefinition 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-08-01-preview' = {
  parent: devCenter
  name: devBoxDefinitionName
  location: location
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

resource projectName_pool 'Microsoft.DevCenter/projects/pools@2024-10-01-preview' = {
  parent: project
  name: poolName
  location: location
  properties: {
    devBoxDefinitionName: devBoxDefinitionName
    licenseType: 'Windows_Client'
    localAdministrator: poolPropertyAdmin
    managedVirtualNetworkRegions: [
      location
    ]
    virtualNetworkType: poolPropertyNetworkType
    networkConnectionName: '${poolPropertyNetworkName}-${locaiton}}'
  }
}
