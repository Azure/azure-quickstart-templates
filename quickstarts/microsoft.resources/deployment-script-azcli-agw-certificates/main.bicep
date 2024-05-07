@description('The name of the Azure Application Gateway')
param AgwName string = 'agw-${uniqueString(resourceGroup().id)}'

@description('The name of the Azure Key Vault')
param AkvName string = 'akv-${uniqueString(resourceGroup().id)}'

@description('The name of the certificate to generate for the frontend AGW. Name will be used as a ARecord in a Private DNS zone.')
param FrontendCertificateName string = 'frontend'

@description('The location to deploy the resources to')
param Location string = resourceGroup().location

@description('The name of the DNS Private Zone to create')
param DnsPrivateZoneName string = 'Contoso.local'

var FrontendCertificateFqdn = '${FrontendCertificateName}.${DnsPrivateZoneName}'

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

@description('This is just a *random* sample app to sit behind the Application Gateway.')
module app 'aciApp.bicep' = {
  name: 'sampleWebApplication'
  params: {
    appName: 'SampleWebApp'
    location: Location
  }
}

output FrontendPrivateDnsFqdn string = FrontendCertificateFqdn
output ApplicationGatewayPublicIp string = agw.outputs.agwPip
output KeyVaultName string = akv.name
