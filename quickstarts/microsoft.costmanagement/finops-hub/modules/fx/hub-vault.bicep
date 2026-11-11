// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//==============================================================================
// Parameters
//==============================================================================

@description('Required. Name of the publisher-specific Key Vault instance.')
param vaultName string

@description('Required. Name of the Key Vault secret to create or update.')
param secretName string

@description('Required. Value of the Key Vault secret.')
@secure()
param secretValue string

@description('Optional. Value of the Key Vault secret expiration date (exp) property. This is represented as seconds since Jan 1, 1970.')
param secretExpirationInSeconds int = -1

@description('Optional. Value of the Key Vault secret not before date (nbf) property. This is represented as seconds since Jan 1, 1970.')
param secretNotBeforeInSeconds int = -1


//==============================================================================
// Resources
//==============================================================================

resource vault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: vaultName

  resource secret 'secrets' = {
    name: secretName
    properties: {
      attributes: union({
        enabled: true
      }, secretExpirationInSeconds <= 0 ? {} : {
        exp: secretExpirationInSeconds
      }, secretNotBeforeInSeconds <= 0 ? {} : {
        nbf: secretNotBeforeInSeconds
      })
      value: secretValue
    }
  }
}


//==============================================================================
// Outputs
//==============================================================================

@description('Name of the Key Vault secret.')
output secretName string = vault::secret.name
