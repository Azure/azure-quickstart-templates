@description('The name of the Front Door endpoint to create. This must be globally unique.')
param endpointName string = 'afd-${uniqueString(resourceGroup().id)}'

@description('The name of the SKU to use when creating the Front Door profile.')
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param skuName string = 'Standard_AzureFrontDoor'

@description('The host name that should be used when connecting from Front Door to the origin.')
param originHostName string

@description('The custom domain name to associate with your Front Door endpoint.')
param customDomainName string

@description('The name of the resource group that contains the key vault with custom domain\'s certificate.')
param certificateKeyVaultResourceGroupName string = resourceGroup().name

@description('The name of the Key Vault that contains the custom domain\'s certificate.')
param certificateKeyVaultName string

@description('The name of the Key Vault secret that contains the custom domain\'s certificate.')
param certificateKeyVaultSecretName string

@description('The version of the Key Vault secret that contains the custom domain\'s certificate. Set the value to an empty string to use the latest version.')
param certificateKeyVaultSecretVersion string = ''

var profileName = 'MyFrontDoor'
var originGroupName = 'MyOriginGroup'
var originName = 'MyOrigin'
var routeName = 'MyRoute'
var secretName = 'MySecret'

// Create a valid resource name for the custom domain. Resource names don't include periods.
var customDomainResourceName = replace(customDomainName, '.', '-')

resource profile 'Microsoft.Cdn/profiles@2020-09-01' = {
  name: profileName
  location: 'global'
  sku: {
    name: skuName
  }
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2020-09-01' = {
  name: endpointName
  parent: profile
  location: 'global'
  properties: {
    originResponseTimeoutSeconds: 240
    enabledState: 'Enabled'
  }
}

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2020-09-01' = {
  name: originGroupName
  parent: profile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  scope: resourceGroup(certificateKeyVaultResourceGroupName)
  name: certificateKeyVaultName

  resource secret 'secrets' existing = {
    name: certificateKeyVaultSecretName
  }
}

resource secret 'Microsoft.Cdn/profiles/secrets@2020-09-01' = {
  name: secretName
  parent: profile
  properties: {
    parameters: {
      type: 'CustomerCertificate'
      useLatestVersion: (certificateKeyVaultSecretVersion == '')
      secretVersion: certificateKeyVaultSecretVersion
      secretSource: {
        id: keyVault::secret.id
      }
    }
  }
}

resource customDomain 'Microsoft.Cdn/profiles/customDomains@2020-09-01' = {
  name: customDomainResourceName
  parent: profile
  properties: {
    hostName: customDomainName
    tlsSettings: {
      certificateType: 'CustomerCertificate'
      minimumTlsVersion: 'TLS12'
      secret: {
        id: secret.id
      }
    }
  }
}

resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2020-09-01' = {
  name: originName
  parent: originGroup
  properties: {
    hostName: originHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: originHostName
    priority: 1
    weight: 1000
  }
}

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2020-09-01' = {
  name: routeName
  parent: endpoint
  dependsOn:[
    origin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {
    customDomains: [
      {
        id: customDomain.id
      }
    ]
    originGroup: {
      id: originGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    queryStringCachingBehavior: 'IgnoreQueryString'
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

output customDomainValidationDnsTxtRecordName string = '_dnsauth.${customDomain.properties.hostName}'
output customDomainValidationDnsTxtRecordValue string = customDomain.properties.validationProperties.validationToken
output customDomainValidationExpiry string = customDomain.properties.validationProperties.expirationDate
output frontDoorEndpointHostName string = endpoint.properties.hostName
