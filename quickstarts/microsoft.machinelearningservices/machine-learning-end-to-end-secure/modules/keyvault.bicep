// Creates a KeyVault with Private Link Endpoint
targetScope = 'resourceGroup'

@description('The Azure Region to deploy the resrouce group into')
param location string = resourceGroup().location

@description('Tags to apply to the Key Vault Instance')
param tags object = {}

@description('The name of the Key Vault')
param keyvaultName string

@description('The name of the Key Vault private link endpoint')
param keyvaultPleName string

@description('The Subnet ID where the Key Vault Private Link is to be created')
param subnetId string

@description('The VNet ID where the Key Vault Private Link is to be created')
param virtualNetworkId string

var privateDnsZoneName =  {
  azureusgovernment: 'privatelink.vaultcore.usgovcloudapi.net'
  azurechinacloud: 'privatelink.vaultcore.azure.cn'
  azurecloud: 'privatelink.vaultcore.azure.net'
}

var privateDnsGroupName = 'vault'

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: keyvaultName
  location: location
  tags: tags
  properties: {
    accessPolicies: []
    createMode: 'default'
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    enablePurgeProtection: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    sku: {
      family: 'A'
      name: 'standard'
    }
    softDeleteRetentionInDays: 7
    tenantId: subscription().tenantId
  }
}

resource keyVaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: keyvaultPleName
  location: location
  tags: tags
  properties: {
    manualPrivateLinkServiceConnections: []
    privateLinkServiceConnections: [
      {
        name: keyvaultPleName
        properties: {
          groupIds: [
            privateDnsGroupName
          ]
          privateLinkServiceId: keyVault.id
          requestMessage: ''
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource keyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDnsZoneName[toLower(environment().name)]
  location: 'global'
  properties: {}
  dependsOn: [
    keyVaultPrivateEndpoint
  ]
}

resource privateEndpointDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${keyVaultPrivateEndpoint.name}/${privateDnsGroupName}-PrivateDnsZoneGroup'
  properties:{
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneName[toLower(environment().name)]
        properties:{
          privateDnsZoneId: keyVaultPrivateDnsZone.id
        }
      }
    ]
  }
  dependsOn: [
    keyVaultPrivateEndpoint
    keyVaultPrivateDnsZone
  ]
}

resource keyVaultPrivateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  name: '${keyVaultPrivateDnsZone.name}/${uniqueString(keyVault.id)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
  dependsOn: [
    keyVaultPrivateDnsZone
  ]
}

output keyvaultId string = keyVault.id
