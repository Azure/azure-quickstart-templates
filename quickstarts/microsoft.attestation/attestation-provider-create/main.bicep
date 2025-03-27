@description('Name of the Attestation provider. Must be between 3 and 24 characters in length and use numbers and lower-case letters only.')
param attestationProviderName string = uniqueString(resourceGroup().name)

@description('Location for all resources.')
param location string = resourceGroup().location

param policySigningCertificates string = ''

var PolicySigningCertificates = {
  PolicySigningCertificates: {
    keys: [
      {
        kty: 'RSA'
        use: 'sig'
        x5c: [
          policySigningCertificates
        ]
      }
    ]
  }
}

resource attestationProvider 'Microsoft.Attestation/attestationProviders@2021-06-01' = {
  name: attestationProviderName
  location: location
  properties: (empty(policySigningCertificates) ? json('{}') : PolicySigningCertificates)
}

output attestationName string = attestationProvider.id
output location string = location
output resourceGroupName string = resourceGroup().name
output resourceId string = attestationProvider.id
