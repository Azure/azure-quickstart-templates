@description('Name of the Vault')
param vaultName string

@description('Location for all resources.')
param location string = resourceGroup().location

resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2020-10-01' = {
  name: vaultName
  location: location
  properties: {}
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
}
