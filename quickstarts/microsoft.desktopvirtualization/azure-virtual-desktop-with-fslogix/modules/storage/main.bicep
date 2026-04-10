param location string

param storageAccountName string
param adminRoleDefinitionId string
param userRoleDefinitionId string
param adminGroupObjectId string
param userGroupObjectId string
param fileShareName string
param fileShareQuota int
param filePrivateDnsZoneName string
param virtualNetworkId string
param subnetId string
param filePrivateEndpointGroupName string
param recoveryServiceVaultName string


resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: toLower(storageAccountName)
  location: location
  sku: {
    name: 'Premium_LRS'
  }
  kind: 'FileStorage'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
  }
}

resource roleAssignmentAdmin 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(resourceGroup().id, storageAccount.id, 'Storage File Data SMB Share Elevated Contributor')
  properties: {
    roleDefinitionId: adminRoleDefinitionId
    principalType: 'Group'
    principalId: adminGroupObjectId
  }
}

resource roleAssignmentUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(resourceGroup().id, storageAccount.id, 'Storage File Data SMB Share Contributor')
  properties: {
    roleDefinitionId: userRoleDefinitionId
    principalType: 'Group'
    principalId: userGroupObjectId
  }
}

resource fileShareService 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    protocolSettings: {
      smb: {
        authenticationMethods: 'NTLMv2;Kerberos'
        channelEncryption: 'AES-128-CCM;AES-128-GCM;AES-256-GCM'
        kerberosTicketEncryption: 'RC4-HMAC;AES-256'
        versions: 'SMB3.0;SMB3.1.1'
      }
    }
    shareDeleteRetentionPolicy: {
      allowPermanentDelete: false
      days: 7
      enabled: true
    }
  }
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' = {
  parent: fileShareService
  name: toLower(fileShareName)
  properties: {
    accessTier: 'Premium'
    enabledProtocols: 'SMB'
    shareQuota: fileShareQuota
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: filePrivateDnsZoneName
  location: 'global'
}

resource privateDnsZoneNameVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: privateDnsZone
  name: 'link_to_${toLower(split(virtualNetworkId, '/')[8])}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  name: '${storageAccount.name}-file-pe'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${storageAccount.name}-file-pe'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            filePrivateEndpointGroupName
          ]
        }
      }
    ]
    subnet: {
      id: subnetId

    }
  }
}

resource PrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  parent: privateEndpoint
  name: filePrivateEndpointGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}

module backup '../recoveryservicevault/main.bicep' = {
  name: 'fileShareBackup'
  params: {
    location: location
    recoveryServiceVaultName: recoveryServiceVaultName
    storageAccountId: storageAccount.id
    fileShareName: fileShare.name
  }
}

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output fileShareName string = fileShare.name
