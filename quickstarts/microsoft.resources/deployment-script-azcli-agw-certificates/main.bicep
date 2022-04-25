@description('The name of the Azure Application Gateway')
param AgwName string = 'cr${uniqueString(resourceGroup().id)}'

@description('The name of the Azure Application Gateway')
param AkvName string = 'cr${uniqueString(resourceGroup().id)}'

param FrontEndCertificate string = 'frontend'

param BackEndCertificate string = 'backend'

@description('The location to deploy the resources to')
param Location string = resourceGroup().location

// param DnsPrivateZoneName string = 'Contoso.local'

// resource dns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
//   name: DnsPrivateZoneName
//   location: 'global'
  
//   resource frontend 'A@2020-06-01' = {
//     name: FrontEndCertificate
//     properties: {
//       aRecords: [
//         {
//           ipv4Address: agw.outputs.agwPip
//         }
//       ]
//     }
//   }
// }

resource akv 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: AkvName
  location: Location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableSoftDelete: false
    enableRbacAuthorization: true
    accessPolicies: []
  }
}
output akvName string = akv.name

module akvCertFrontend 'br/public:deployment-scripts/create-kv-certificate:1.0.1' = {
  name: 'CreateFeKvCert'
  params: {
    akvName: akv.name
    certificateName: FrontEndCertificate
  }
}

module akvCertBackend 'br/public:deployment-scripts/create-kv-certificate:1.0.1' = {
  name: 'CreateBeKvCert'
  params: {
    akvName: akv.name
    certificateName: BackEndCertificate
  }
}

module agw 'appgw.bicep' = {
  name: AgwName
  params: {
    location: Location
    akvName: akv.name
    backEndCertificateSecretId: akvCertBackend.outputs.certificateSecretIdUnversioned
    frontEndCertificateSecretId: akvCertFrontend.outputs.certificateSecretIdUnversioned
  }
}
