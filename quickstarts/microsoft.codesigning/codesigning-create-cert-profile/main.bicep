@description('An existing signing account name.')
@minLength(3)
@maxLength(15)
param accountName string

@description('A certificate profile to provision.')
@minLength(3)
@maxLength(15)
param profileName string

@description('The identity validation id to be used for the certificate profile.')
param identityValidationId string

@description('Profile type for the certificate profile.')
@allowed([
  'PublicTrust'
  'PrivateTrust'
  'PrivateTrustCIPolicy'
  'PublicTrustTest'
  'VBSEnclave'
])
param profileType string = 'PublicTrust'

resource existingAccount 'Microsoft.CodeSigning/codeSigningAccounts@2024-02-05-preview' existing = {
  name: accountName
}
resource profile 'Microsoft.CodeSigning/codeSigningAccounts/certificateProfiles@2024-02-05-preview' = {
  parent: existingAccount
  name: profileName
  properties: {
    profileType: profileType
    identityValidationId: identityValidationId
  }
}
