targetScope = 'resourceGroup'

param accountKind string = 'StorageV2'
param accessTier string = 'Hot'
@allowed([
  'AzureServices'
])
param bypass string = 'AzureServices'
param containers array = []
@allowed([
  true
])
param httpsRequired bool = true
param isHnsEnabled bool = false
param largeFileSharesState string = 'Disabled'
param keyName string = ''

param keyVaultId string = ''
param location string = 'usgovarizona'
param replicationStrategy string = 'Standard_LRS'
param storageAccountName string
param subnetName string
param tagsByResource object = {}
param umiId string = ''
param vnetName string
param vnetRG string
param privateDnsRegistrationType string = ''
param existingBlobManagedResourceGroupPrivateDnsZone string = ''
param existingFileManagedResourceGroupPrivateDnsZone string = ''
param existingQueueManagedResourceGroupPrivateDnsZone string = ''
param existingTableManagedResourceGroupPrivateDnsZone string = ''
param existingDfsManagedResourceGroupPrivateDnsZone string = ''
param manuallySelectedBlobDnsZone string = ''
param manuallySelectedFileDnsZone string = ''
param manuallySelectedQueueDnsZone string = ''
param manuallySelectedTableDnsZone string = ''
param manuallySelectedDfsDnsZone string = ''

param newBlobManagedResourceGroupPrivateDnsZone string = ''
param newFileManagedResourceGroupPrivateDnsZone string = ''
param newQueueManagedResourceGroupPrivateDnsZone string = ''
param newTableManagedResourceGroupPrivateDnsZone string = ''
param newDfsManagedResourceGroupPrivateDnsZone string = ''

param logAnalyticsWorkspaceId string = ''
param vnetLocation string = ''

var effectiveBypass = empty(bypass) ? 'AzureServices' : bypass
var peLocation = !empty(vnetLocation) ? vnetLocation : location

var umiSubId = split(umiId, '/')[2]
var umiRG = split(umiId, '/')[4]
var umiName = split(umiId, '/')[8]

var kvSubId = split(keyVaultId, '/')[2]
var kvRG = split(keyVaultId, '/')[4]
var kvName = split(keyVaultId, '/')[8]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRG)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: subnetName
  parent: virtualNetwork
}

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: umiName
  scope: resourceGroup(umiSubId, umiRG)
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: kvName
  scope: resourceGroup(kvSubId, kvRG)
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-08-01' = {
  name: storageAccountName
  tags: contains(tagsByResource, 'Microsoft.Storage/storageAccounts')
    ? tagsByResource['Microsoft.Storage/storageAccounts']
    : {}
  location: location
  kind: accountKind
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  sku: {
    name: replicationStrategy
  }
  properties: {
    allowSharedKeyAccess:false
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    accessTier: (accountKind == 'StorageV2' || accountKind == 'BlobStorage') ? accessTier : null
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: httpsRequired
    publicNetworkAccess: 'Disabled'
    isHnsEnabled: (accountKind == 'StorageV2' || accountKind == 'BlobStorage') ? isHnsEnabled : null
    largeFileSharesState: largeFileSharesState
    networkAcls: {
      bypass: effectiveBypass
      defaultAction: 'Deny'
      ipRules: []
      resourceAccessRules: []
      virtualNetworkRules: []
    }
    encryption: {
      identity: {
        userAssignedIdentity: userAssignedIdentity.id
      }
      keySource: 'Microsoft.Keyvault'
      keyvaultproperties: {
        keyvaulturi: keyVault.properties.vaultUri
        keyname: keyName
      }
      requireInfrastructureEncryption: true
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
        queue: {
          enabled: true
          keyType: 'Account'
        }
        table: {
          enabled: true
          keyType: 'Account'
        }
      }
    }
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = if (contains(
  ['StorageV2', 'BlobStorage', 'BlockBlobStorage'],
  accountKind
)) {
  parent: storageAccount
  name: 'default'
}

resource storageAccountContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [
  for container in containers: {
    parent: blobService
    name: container.name
    properties: {
      publicAccess: container.publicAccess
    }
  }
]

// Determine the correct DNS zone ID based on registration type for each service
var selectedBlobDnsZoneId = privateDnsRegistrationType == 'manuallySelectZone'
  ? manuallySelectedBlobDnsZone
  : (privateDnsRegistrationType == 'defaultManagedResourceGroupZone' && !empty(existingBlobManagedResourceGroupPrivateDnsZone))
      ? existingBlobManagedResourceGroupPrivateDnsZone
      : (privateDnsRegistrationType == 'defaultManagedResourceGroupZone' && !empty(newBlobManagedResourceGroupPrivateDnsZone))
          ? newBlobManagedResourceGroupPrivateDnsZone
          : ''

var selectedFileDnsZoneId = privateDnsRegistrationType == 'manuallySelectZone'
  ? manuallySelectedFileDnsZone
  : (privateDnsRegistrationType == 'defaultManagedResourceGroupZone' && !empty(existingFileManagedResourceGroupPrivateDnsZone))
      ? existingFileManagedResourceGroupPrivateDnsZone
      : (privateDnsRegistrationType == 'defaultManagedResourceGroupZone' && !empty(newFileManagedResourceGroupPrivateDnsZone))
          ? newFileManagedResourceGroupPrivateDnsZone
          : ''

var selectedQueueDnsZoneId = privateDnsRegistrationType == 'manuallySelectZone'
  ? manuallySelectedQueueDnsZone
  : (privateDnsRegistrationType == 'defaultManagedResourceGroupZone' && !empty(existingQueueManagedResourceGroupPrivateDnsZone))
      ? existingQueueManagedResourceGroupPrivateDnsZone
      : (privateDnsRegistrationType == 'defaultManagedResourceGroupZone' && !empty(newQueueManagedResourceGroupPrivateDnsZone))
          ? newQueueManagedResourceGroupPrivateDnsZone
          : ''

var selectedTableDnsZoneId = privateDnsRegistrationType == 'manuallySelectZone'
  ? manuallySelectedTableDnsZone
  : (privateDnsRegistrationType == 'defaultManagedResourceGroupZone' && !empty(existingTableManagedResourceGroupPrivateDnsZone))
      ? existingTableManagedResourceGroupPrivateDnsZone
      : (privateDnsRegistrationType == 'defaultManagedResourceGroupZone' && !empty(newTableManagedResourceGroupPrivateDnsZone))
          ? newTableManagedResourceGroupPrivateDnsZone
          : ''

var selectedDfsDnsZoneId = privateDnsRegistrationType == 'manuallySelectZone'
  ? manuallySelectedDfsDnsZone
  : (privateDnsRegistrationType == 'defaultManagedResourceGroupZone' && !empty(existingDfsManagedResourceGroupPrivateDnsZone))
      ? existingDfsManagedResourceGroupPrivateDnsZone
      : (privateDnsRegistrationType == 'defaultManagedResourceGroupZone' && !empty(newDfsManagedResourceGroupPrivateDnsZone))
          ? newDfsManagedResourceGroupPrivateDnsZone
          : ''

// Private endpoints for each storage service
resource peBlob 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${storageAccountName}-blob-pe'
  tags: contains(tagsByResource, 'Microsoft.Network/privateEndpoints')
    ? tagsByResource['Microsoft.Network/privateEndpoints']
    : {}
  location: peLocation
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${storageAccountName}-blob-plsc'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    subnet: {
      id: subnet.id
    }
  }
}

resource peFile 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${storageAccountName}-file-pe'
  tags: contains(tagsByResource, 'Microsoft.Network/privateEndpoints')
    ? tagsByResource['Microsoft.Network/privateEndpoints']
    : {}
  location: peLocation
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${storageAccountName}-file-plsc'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'file'
          ]
        }
      }
    ]
    subnet: {
      id: subnet.id
    }
  }
}

resource peQueue 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${storageAccountName}-queue-pe'
  tags: contains(tagsByResource, 'Microsoft.Network/privateEndpoints')
    ? tagsByResource['Microsoft.Network/privateEndpoints']
    : {}
  location: peLocation
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${storageAccountName}-queue-plsc'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'queue'
          ]
        }
      }
    ]
    subnet: {
      id: subnet.id
    }
  }
}

resource peTable 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${storageAccountName}-table-pe'
  tags: contains(tagsByResource, 'Microsoft.Network/privateEndpoints')
    ? tagsByResource['Microsoft.Network/privateEndpoints']
    : {}
  location: peLocation
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${storageAccountName}-table-plsc'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'table'
          ]
        }
      }
    ]
    subnet: {
      id: subnet.id
    }
  }
}

resource peDfs 'Microsoft.Network/privateEndpoints@2023-11-01' = if (isHnsEnabled) {
  name: '${storageAccountName}-dfs-pe'
  tags: contains(tagsByResource, 'Microsoft.Network/privateEndpoints')
    ? tagsByResource['Microsoft.Network/privateEndpoints']
    : {}
  location: peLocation
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${storageAccountName}-dfs-plsc'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'dfs'
          ]
        }
      }
    ]
    subnet: {
      id: subnet.id
    }
  }
}

// Deploy DNS zone groups for each PE only if a valid zone ID is found
resource privateDnsZoneGroupBlob 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (!empty(selectedBlobDnsZoneId)) {
  parent: peBlob
  name: 'dnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privateDnsZoneConfig'
        properties: {
          privateDnsZoneId: selectedBlobDnsZoneId
        }
      }
    ]
  }
}

resource privateDnsZoneGroupFile 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (!empty(selectedFileDnsZoneId)) {
  parent: peFile
  name: 'dnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privateDnsZoneConfig'
        properties: {
          privateDnsZoneId: selectedFileDnsZoneId
        }
      }
    ]
  }
}

resource privateDnsZoneGroupQueue 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (!empty(selectedQueueDnsZoneId)) {
  parent: peQueue
  name: 'dnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privateDnsZoneConfig'
        properties: {
          privateDnsZoneId: selectedQueueDnsZoneId
        }
      }
    ]
  }
}

resource privateDnsZoneGroupTable 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (!empty(selectedTableDnsZoneId)) {
  parent: peTable
  name: 'dnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privateDnsZoneConfig'
        properties: {
          privateDnsZoneId: selectedTableDnsZoneId
        }
      }
    ]
  }
}

resource privateDnsZoneGroupDfs 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (isHnsEnabled && !empty(selectedDfsDnsZoneId)) {
  parent: peDfs
  name: 'dnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privateDnsZoneConfig'
        properties: {
          privateDnsZoneId: selectedDfsDnsZoneId
        }
      }
    ]
  }
}

resource diagnosticSettingsBlob 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId) && contains(['StorageV2', 'BlobStorage', 'BlockBlobStorage'], accountKind)) {
  scope: blobService
  name: 'default'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob
