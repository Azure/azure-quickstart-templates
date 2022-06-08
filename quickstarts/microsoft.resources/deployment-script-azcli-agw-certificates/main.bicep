@description('The name of the Azure Application Gateway')
param AgwName string = 'agw-${uniqueString(resourceGroup().id)}'

@description('The name of the Azure Application Gateway')
param AkvName string = 'akv-${uniqueString(resourceGroup().id)}'

param FrontendCertificateName string = 'frontend'

@description('The location to deploy the resources to')
param Location string = resourceGroup().location

param DnsPrivateZoneName string = 'Contoso.local'

resource dns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: DnsPrivateZoneName
  location: 'global'
  
  resource frontend 'A@2020-06-01' = {
    name: FrontendCertificateName
    properties: {
      ttl: 60
      aRecords: [
        {
          ipv4Address: agw.outputs.agwPip
        }
      ]
    }
  }
  
  resource appdirect 'A@2020-06-01' = {
    name: 'appdirect'
    properties: {
      ttl: 60
      aRecords: [
        {
          ipv4Address: app.outputs.IpAddress
        }
      ]
    }
  }
}

var FrontendCertificateFqdn = '${FrontendCertificateName}.${DnsPrivateZoneName}'

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

module akvCertFrontend 'br/public:deployment-scripts/create-kv-certificate:1.1.1' = {
  name: 'CreateFeKvCert'
  params: {
    akvName: akv.name
    certificateName: FrontendCertificateName
    certificateCommonName: FrontendCertificateFqdn
  }
}

module agw 'appgw.bicep' = {
  name: AgwName
  params: {
    location: Location
    akvName: akv.name
    frontEndCertificateSecretId: akvCertFrontend.outputs.certificateSecretIdUnversioned
    backendIpAddress: app.outputs.IpAddress
  }
}
output agwIp string = agw.outputs.agwPip

resource fnAppUai 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  location: Location
  name: 'id-app-SampleApp-4kogxjemf2t7a'
}

module app 'aciApp.bicep' = {
  name: 'sampleWebApplication'
  params: {
    appName: 'SampleWebApp'
    location: Location
  }
}
