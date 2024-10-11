param location string
param keyVaultName string
param aadPodIdentityUserDefinedManagedIdentityTenantId string
param aadPodIdentityUserDefinedManagedIdentityPrincipalId string
param applicationGatewayUserDefinedManagedIdentityTenantId string
param applicationGatewayUserDefinedManagedIdentityPrincipalId string
param keyVaultNetworkRuleSetDefaultAction string
param workspaceId string
param readerRoleId string
param keyVaultPrivateDnsZoneName string
param virtualNetworkName string
param virtualNetworkId string
param privateEndpointSubnetId string
param keyVaultPrivateEndpointName string
param keyVaultPrivateEndpointGroupName string
param keyVaultPrivateDnsZoneGroupName string

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    accessPolicies: [
      {
        tenantId: applicationGatewayUserDefinedManagedIdentityTenantId
        objectId: applicationGatewayUserDefinedManagedIdentityPrincipalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
          certificates: [
            'get'
          ]
        }
      }
      {
        tenantId: aadPodIdentityUserDefinedManagedIdentityTenantId
        objectId: aadPodIdentityUserDefinedManagedIdentityPrincipalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
          certificates: [
            'get'
          ]
        }
      }
    ]
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: keyVaultNetworkRuleSetDefaultAction
    }
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: false
  }
}

resource keyVaultNameDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: keyVault
  name: 'default-Diag'
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'AuditEvent'
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

resource keyVaultNameRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, keyVault.id)
  properties: {
    roleDefinitionId: readerRoleId
    principalId: aadPodIdentityUserDefinedManagedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource keyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: keyVaultPrivateDnsZoneName
  location: 'global'
  properties: {}
}

resource keyVaultPrivateDnsZoneName_link_to_virtualNetwork 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: keyVaultPrivateDnsZone
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource keyVaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  name: keyVaultPrivateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: keyVaultPrivateEndpointName
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: [
            keyVaultPrivateEndpointGroupName
          ]
        }
      }
    ]
    subnet: {
      id: privateEndpointSubnetId
    }
  }
}

resource keyVaultPrivateEndpointName_keyVaultPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  parent: keyVaultPrivateEndpoint
  name: keyVaultPrivateDnsZoneGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: keyVaultPrivateDnsZone.id
        }
      }
    ]
  }
}
