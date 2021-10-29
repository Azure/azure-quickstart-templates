@description('String specifying the name of the managed HSM.')
param managedHSMName string

@description('String specifying the Azure location where the managed HSM should be created.')
param location string = resourceGroup().location

@description('Array specifying the objectIDs associated with a list of initial administrators.')
param initialAdminObjectIds array

@description('String specifying the Azure Active Directory tenant ID that should be used for authenticating requests to the managed HSM.')
param tenantId string = subscription().tenantId

@description('Specifies the number of days that logs are gonna be kept. If you do not want to apply any retention policy and retain data forever, set value to 0.')
@minValue(0)
@maxValue(365)
param logsRetentionInDays int = 0

resource managedHSM 'Microsoft.KeyVault/managedHSMs@2021-04-01-preview' = {
  name: managedHSMName
  location: location
  sku: {
    name: 'Standard_B1'
    family: 'B'
  }
  properties: {
    enableSoftDelete: true
    softDeleteRetentionInDays: logsRetentionInDays
    enablePurgeProtection: false
    tenantId: tenantId
    initialAdminObjectIds: initialAdminObjectIds
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Allow'
      ipRules: []
      virtualNetworkRules: []
    }
  }
}
