// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//==============================================================================
// Parameters
//==============================================================================

@description('Required. Name of the FinOps hub instance. Used to ensure unique resource names.')
param hubName string

@description('Required. Suffix to add to the storage account name to ensure uniqueness.')
param uniqueSuffix string

@description('Optional. Azure location where all resources should be created. See https://aka.ms/azureregions. Default: (resource group location).')
param location string = resourceGroup().location

@allowed([
  'Premium_LRS'
  'Premium_ZRS'
])
@description('Optional. Storage SKU to use. LRS = Lowest cost, ZRS = High availability. Note Standard SKUs are not available for Data Lake gen2 storage. Allowed: Premium_LRS, Premium_ZRS. Default: Premium_LRS.')
param sku string = 'Premium_LRS'

@description('Optional. Tags to apply to all resources.')
param tags object = {}

@description('Optional. Tags to apply to resources based on their resource type. Resource type specific tags will be merged with tags for all resources.')
param tagsByResource object = {}

@description('Optional. List of scope IDs to monitor and ingest cost for.')
param scopesToMonitor array

@description('Optional. Number of days of data to retain in the msexports container. Default: 0.')
param msexportRetentionInDays int = 0

@description('Optional. Number of months of data to retain in the ingestion container. Default: 13.')
param ingestionRetentionInMonths int = 13

@description('Optional. Enable infrastructure encryption on the storage account. Default = false.')
param enableInfrastructureEncryption bool = false

@description('Optional. Number of days of data to retain in the Data Explorer *_raw tables. Default: 0.')
param rawRetentionInDays int = 0

@description('Optional. Number of months of data to retain in the Data Explorer *_final_v* tables. Default: 13.')
param finalRetentionInMonths int = 13

@description('Required. Id of the virtual network for private endpoints.')
param virtualNetworkId string

@description('Required. Id of the subnet for private endpoints.')
param privateEndpointSubnetId string

@description('Required. Id of the virtual network for running deployment scripts.')
param scriptSubnetId string

@description('Optional. Enable public access to the data lake.  Default: false.')
param enablePublicAccess bool

//------------------------------------------------------------------------------
// Variables
//------------------------------------------------------------------------------

// Generate globally unique storage account name: 3-24 chars; lowercase letters/numbers only
var safeHubName = replace(replace(toLower(hubName), '-', ''), '_', '')
var storageAccountSuffix = uniqueSuffix
var storageAccountName = '${take(safeHubName, 24 - length(storageAccountSuffix))}${storageAccountSuffix}'
var scriptStorageAccountName = '${take(safeHubName, 16 - length(storageAccountSuffix))}script${storageAccountSuffix}'
var schemaFiles = {
  'focuscost_1.0r2': loadTextContent('../schemas/focuscost_1.0r2.json')
  'focuscost_1.0': loadTextContent('../schemas/focuscost_1.0.json')
  'focuscost_1.0-preview(v1)': loadTextContent('../schemas/focuscost_1.0-preview(v1).json')
  'pricesheet_2023-05-01_ea': loadTextContent('../schemas/pricesheet_2023-05-01_ea.json')
  'pricesheet_2023-05-01_mca': loadTextContent('../schemas/pricesheet_2023-05-01_mca.json')
  'reservationdetails_2023-03-01': loadTextContent('../schemas/reservationdetails_2023-03-01.json')
  'reservationrecommendations_2023-05-01_ea': loadTextContent('../schemas/reservationrecommendations_2023-05-01_ea.json')
  'reservationrecommendations_2023-05-01_mca': loadTextContent('../schemas/reservationrecommendations_2023-05-01_mca.json')
  'reservationtransactions_2023-05-01_ea': loadTextContent('../schemas/reservationtransactions_2023-05-01_ea.json')
  'reservationtransactions_2023-05-01_mca': loadTextContent('../schemas/reservationtransactions_2023-05-01_mca.json')
}

// Roles needed to auto-start triggers
// Storage Blob Data Contributor - used by deployment scripts to write data to blob storage
// Storage File Data Privileged Contributor - used by deployment scripts to write data to blob storage
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deployment-script-template#use-existing-storage-account
var blobUploadRbacRoles = [
  'ba92f5b4-2d11-453d-a403-e96b0029c9fe' // Storage Blob Data Contributor - https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#storage-blob-data-contributor
  'e40ec5ca-96e0-45a2-b4ff-59039f2c2b59' // Managed Identity Contributor - https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#managed-identity-contributor
  '69566ab7-960f-475b-8e7c-b3118f30c6bd' // Storage File Data Privileged Contributor - https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/storage#storage-file-data-privileged-contributor
]

//==============================================================================
// Resources
//==============================================================================

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: sku
  }
  kind: 'BlockBlobStorage'
  tags: union(tags, contains(tagsByResource, 'Microsoft.Storage/storageAccounts') ? tagsByResource['Microsoft.Storage/storageAccounts'] : {})
  properties: union(!enableInfrastructureEncryption ? {} : {
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: enableInfrastructureEncryption
    }
  }, {
    supportsHttpsTrafficOnly: true
    allowSharedKeyAccess: true
    isHnsEnabled: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: enablePublicAccess ? 'Allow' : 'Deny'
    }
  })
}

resource scriptStorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' =  {
  name: scriptStorageAccountName
  location: location
  sku: {
    name: 'Standard_LRS' //sku
  }
  kind: 'StorageV2'// 'BlockBlobStorage'
  tags: union(tags, contains(tagsByResource, 'Microsoft.Storage/storageAccounts') ? tagsByResource['Microsoft.Storage/storageAccounts'] : {})
  properties: {
    supportsHttpsTrafficOnly: true
    allowSharedKeyAccess: true
    isHnsEnabled: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: scriptSubnetId
          action: 'Allow'
        }
      ]
    }
  }
}

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  location: 'global'
  tags: union(tags, contains(tagsByResource, 'Microsoft.Storage/privateDnsZones') ? tagsByResource['Microsoft.Storage/privateDnsZones'] : {})
  properties: {}
}

resource dfsPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: 'privatelink.dfs.${environment().suffixes.storage}'
  location: 'global'
  tags: union(tags, contains(tagsByResource, 'Microsoft.Storage/privateDnsZones') ? tagsByResource['Microsoft.Storage/privateDnsZones'] : {})
  properties: {}
}

resource queuePrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: 'privatelink.queue.${environment().suffixes.storage}'
  location: 'global'
  tags: union(tags, contains(tagsByResource, 'Microsoft.Storage/privateDnsZones') ? tagsByResource['Microsoft.Storage/privateDnsZones'] : {})
  properties: {}
}

resource tablePrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: 'privatelink.table.${environment().suffixes.storage}'
  location: 'global'
  tags: union(tags, contains(tagsByResource, 'Microsoft.Storage/privateDnsZones') ? tagsByResource['Microsoft.Storage/privateDnsZones'] : {})
  properties: {}
}

resource blobPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: blobPrivateDnsZone
  name: '${replace(blobPrivateDnsZone.name, '.', '-')}-link'
  location: 'global'
  tags: union(tags, contains(tagsByResource, 'Microsoft.Network/privateDnsZones/virtualNetworkLinks') ? tagsByResource['Microsoft.Network/privateDnsZones/virtualNetworkLinks'] : {})
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource dfsPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: dfsPrivateDnsZone
  name: '${replace(dfsPrivateDnsZone.name, '.', '-')}-link'
  location: 'global'
  tags: union(tags, contains(tagsByResource, 'Microsoft.Network/privateDnsZones/virtualNetworkLinks') ? tagsByResource['Microsoft.Network/privateDnsZones/virtualNetworkLinks'] : {})
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource queuePrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: queuePrivateDnsZone
  name: '${replace(queuePrivateDnsZone.name, '.', '-')}-link'
  location: 'global'
  tags: union(tags, contains(tagsByResource, 'Microsoft.Network/privateDnsZones/virtualNetworkLinks') ? tagsByResource['Microsoft.Network/privateDnsZones/virtualNetworkLinks'] : {})
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource tablePrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: tablePrivateDnsZone
  name: '${replace(tablePrivateDnsZone.name, '.', '-')}-link'
  location: 'global'
  tags: union(tags, contains(tagsByResource, 'Microsoft.Network/privateDnsZones/virtualNetworkLinks') ? tagsByResource['Microsoft.Network/privateDnsZones/virtualNetworkLinks'] : {})
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource blobEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${storageAccount.name}-blob-ep'
  location: location
  tags: union(tags, contains(tagsByResource, 'Microsoft.Network/privateEndpoints') ? tagsByResource['Microsoft.Network/privateEndpoints'] : {})
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'blobLink'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: ['blob']
        }
      }
    ]
  }
}

resource scriptEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${scriptStorageAccount.name}-blob-ep'
  location: location
  tags: union(tags, contains(tagsByResource, 'Microsoft.Network/privateEndpoints') ? tagsByResource['Microsoft.Network/privateEndpoints'] : {})
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'scriptLink'
        properties: {
          privateLinkServiceId: scriptStorageAccount.id
          groupIds: ['blob']
        }
      }
    ]
  }
}

resource dfsEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${storageAccount.name}-dfs-ep'
  location: location
  tags: union(tags, contains(tagsByResource, 'Microsoft.Network/privateEndpoints') ? tagsByResource['Microsoft.Network/privateEndpoints'] : {})
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'dfsLink'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: ['dfs']
        }
      }
    ]
  }
}

resource blobPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  name: 'storage-endpoint-zone'
  parent: blobEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: blobPrivateDnsZone.name
        properties: {
          privateDnsZoneId: blobPrivateDnsZone.id
        }
      }
    ]
  }
}

resource dfsPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  name: 'dfs-endpoint-zone'
  parent: dfsEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: dfsPrivateDnsZone.name
        properties: {
          privateDnsZoneId: dfsPrivateDnsZone.id
        }
      }
    ]
  }
}

resource scriptPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  name: 'blob-endpoint-zone'
  parent: scriptEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: blobPrivateDnsZone.name
        properties: {
          privateDnsZoneId: blobPrivateDnsZone.id
        }
      }
    ]
  }
}

//------------------------------------------------------------------------------
// Containers
//------------------------------------------------------------------------------

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: storageAccount
  name: 'default'
}

resource configContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  parent: blobService
  name: 'config'
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}

resource exportContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  parent: blobService
  name: 'msexports'
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}

resource ingestionContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  parent: blobService
  name: 'ingestion'
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}

//------------------------------------------------------------------------------
// Settings.json
//------------------------------------------------------------------------------

// Create managed identity to upload files
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${storageAccountName}_blobManager'
  tags: union(tags, contains(tagsByResource, 'Microsoft.ManagedIdentity/userAssignedIdentities') ? tagsByResource['Microsoft.ManagedIdentity/userAssignedIdentities'] : {})
  location: location
}

// Assign access to the identity
resource identityRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for role in blobUploadRbacRoles: {
  name: guid(storageAccount.id, role, identity.id)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}]

resource uploadSettings 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: '${storageAccountName}_uploadSettings'
  kind: 'AzurePowerShell'
  // chinaeast2 is the only region in China that supports deployment scripts
  location: startsWith(location, 'china') ? 'chinaeast2' : location
  tags: union(tags, contains(tagsByResource, 'Microsoft.Resources/deploymentScripts') ? tagsByResource['Microsoft.Resources/deploymentScripts'] : {})
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  dependsOn: [
    configContainer
    identityRoleAssignments
    blobEndpoint
    blobPrivateDnsZoneGroup
    scriptEndpoint
    scriptPrivateDnsZoneGroup
  ]
  properties: {
    azPowerShellVersion: '9.0'
    retentionInterval: 'PT1H'
    environmentVariables: [
      {
        name: 'ftkVersion'
        value: loadTextContent('./ftkver.txt')
      }
      {
        name: 'scopes'
        value: join(scopesToMonitor, '|')
      }
      {
        name: 'msexportRetentionInDays'
        value: string(msexportRetentionInDays)
      }
      {
        name: 'ingestionRetentionInMonths'
        value: string(ingestionRetentionInMonths)
      }
      {
        name: 'rawRetentionInDays'
        value: string(rawRetentionInDays)
      }
      {
        name: 'finalRetentionInMonths'
        value: string(finalRetentionInMonths)
      }
      {
        name: 'storageAccountName'
        value: storageAccountName
      }
      {
        name: 'containerName'
        value: 'config'
      }
      {
        name: 'schemaFiles'
        value: string(schemaFiles)
      }
    ]
    scriptContent: loadTextContent('./scripts/Copy-FileToAzureBlob.ps1')
    storageAccountSettings: {
      storageAccountName: scriptStorageAccount.name
      //storageAccountKey: storageAccount.listKeys().keys[0].value
    }
    containerSettings: {
      containerGroupName: '${scriptStorageAccount.name}cg'
      subnetIds: [
        {
          id: scriptSubnetId
        }
      ]
    }
  }
}

//==============================================================================
// Outputs
//==============================================================================

@description('The resource ID of the storage account.')
output resourceId string = storageAccount.id

@description('The name of the storage account.')
output name string = storageAccount.name

@description('The resource ID of the storage account.')
output scriptStorageAccountResourceId string = scriptStorageAccount.id

@description('The name of the storage account.')
output scriptStorageAccountName string = scriptStorageAccount.name

@description('The name of the container used for configuration settings.')
output configContainer string = configContainer.name

@description('The name of the container used for Cost Management exports.')
output exportContainer string = exportContainer.name

@description('The name of the container used for normalized data ingestion.')
output ingestionContainer string = ingestionContainer.name
