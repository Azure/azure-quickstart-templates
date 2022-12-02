param sqlServerName string
param storageAccountName string

resource auditingSetting 'Microsoft.Sql/servers/auditingSettings@2022-05-01-preview' = {
  name: '${sqlServerName}/default'
  properties: {
    state: 'Enabled'
    storageEndpoint: reference(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), '2021-01-01').PrimaryEndpoints.Blob
    storageAccountAccessKey: listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), '2021-01-01').keys[0].value
    retentionDays: 0
    storageAccountSubscriptionId: subscription().subscriptionId
    isStorageSecondaryKeyInUse: false
  }
}
