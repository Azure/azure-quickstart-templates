@description('Server Name for Azure database for MySQL')
param serverName string

@description('Provide the location for all the resources.')
param location string = resourceGroup().location

@description('UserName of Microsoft Entra ID user or group')
param entraAdminUserName string

@description('Object id of Microsoft Entra ID user or group. You can obtain it using az ad user show --id <user>')
param entraAdminObjectID string

@description('ResourceId of the user-assigned managed identity')
param umiResourceId string

resource server 'Microsoft.DBforMySQL/flexibleServers@2024-06-01-preview' = {
  location: location
  name: serverName
  sku: {
    name: 'Standard_D2ads_v5'
    tier: 'GeneralPurpose'
  }
  identity: {
    type:'UserAssigned'
    userAssignedIdentities: {
      umiResourceId :{
        tenantId: subscription().tenantId
      }
    }
  }
  properties: {
    version: '8.0.21'
    storage: {
      storageSizeGB: 20
      iops: 3200
      autoGrow: 'Enabled'
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
  }
}

resource firewallRules 'Microsoft.DBforMySQL/flexibleServers/firewallRules@2023-12-30' = {
  parent: server
  name: 'AllowAllMicrosoftAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource aad_auth_only 'Microsoft.DBforMySQL/flexibleServers/configurations@2023-12-30' = {
  parent: server
  name: 'aad_auth_only'
  properties: {
    value: 'ON'
    currentValue: 'ON'
  }
}

resource serverAdmin 'Microsoft.DBforMySQL/flexibleServers/administrators@2023-12-30' = {
  parent: server
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: entraAdminUserName
    sid: entraAdminObjectID
    tenantId: subscription().tenantId
    identityResourceId: umiResourceId
  }
}