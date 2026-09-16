targetScope = 'resourceGroup'
param enablePurgeProtection bool = false
param keys array = []
param keyvaultname string
param location string = 'usgovarizona'
param skuname string
param softDeleteRetentionInDays int = 90
param subnetName string
param tagsByResource object = {}
param tenant_id string
param vnetName string
param vnetRG string
param privateDnsRegistrationType string = ''
param existingManagedResourceGroupPrivateDnsZone string = ''
param manuallySelectedPrivateDnsZone string = ''
param newManagedResourceGroupPrivateDnsZone string = ''
param enableDiagnostics bool = false
param workspaceId string = ''
param vnetLocation string = ''

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRG)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: subnetName
  parent: virtualNetwork
}

resource keyvault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyvaultname
  tags: contains(tagsByResource, 'Microsoft.KeyVault/vaults') ? tagsByResource['Microsoft.KeyVault/vaults'] : {}
  location: location
  properties: {
    sku: {
      family: 'A'
      name: skuname
    }
    tenantId: tenant_id
    enableRbacAuthorization: true
    publicNetworkAccess: 'disabled'
    enableSoftDelete: true
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection ? true : null
  }
}

resource keyvaultkeys 'Microsoft.KeyVault/vaults/keys@2023-07-01' = [
  for key in keys: {
    name: key.name
    parent: keyvault
    properties: {
      keySize: key.keySize
      kty: key.keyType
      rotationPolicy: {
        attributes: {
          expiryTime: 'P1Y'
        }
        lifetimeActions: [
          {
            action: {
              type: 'Rotate'
            }
            trigger: {
              timeAfterCreate: 'P30D'
            }
          }
        ]
      }
    }
  }
]

resource pe 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${keyvaultname}-kv-pe'
  tags: contains(tagsByResource, 'Microsoft.Network/privateEndpoints')
    ? tagsByResource['Microsoft.Network/privateEndpoints']
    : {}
  location: !empty(vnetLocation) ? vnetLocation : location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${keyvaultname}-plsc'
        properties: {
          privateLinkServiceId: keyvault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
    subnet: {
      id: subnet.id
    }
  }
}

// 1. Determine the correct ID based on your conditions
var selectedDnsZoneId = privateDnsRegistrationType == 'manuallySelectZone'
  ? manuallySelectedPrivateDnsZone
  : (privateDnsRegistrationType == 'defaultManagedResourceGroupZone' && !empty(existingManagedResourceGroupPrivateDnsZone))
      ? existingManagedResourceGroupPrivateDnsZone
      : (privateDnsRegistrationType == 'defaultManagedResourceGroupZone' && !empty(newManagedResourceGroupPrivateDnsZone))
          ? newManagedResourceGroupPrivateDnsZone
          : ''

// 2. Deploy a single resource, but ONLY if we found a valid ID (checked by !empty)
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (!empty(selectedDnsZoneId)) {
  parent: pe
  name: 'dnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privateDnsZoneConfig'
        properties: {
          privateDnsZoneId: selectedDnsZoneId
        }
      }
    ]
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  name: 'default'
  scope: keyvault
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
      {
        category: 'AzurePolicyEvaluationDetails'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output keyVaultId string = keyvault.id
output vaultUri string = keyvault.properties.vaultUri
