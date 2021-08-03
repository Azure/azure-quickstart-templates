param applicationName string

@description('Existing Azure DNS zone in target resource group')
param dnsZone string

var location = resourceGroup().location
var componentBase = '${substring(uniqueString(resourceGroup().id), 4)}-${applicationName}'

resource hostingPlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: '${componentBase}-asp'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: '${replace(componentBase, '-', '')}st'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource appInsights 'Microsoft.Insights/components@2015-05-01' = {
  name: '${componentBase}-ai'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}
resource functionApp 'Microsoft.Web/sites@2020-06-01' = {
  name: '${componentBase}-functionapp'
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: hostingPlan.id
    clientAffinityEnabled: false
    siteConfig: {
      http20Enabled: true
      use32BitWorkerProcess: false
      ftpsState: 'FtpsOnly'
      alwaysOn: false
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${appInsights.properties.InstrumentationKey}'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storage.id, storage.apiVersion).keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storage.id, storage.apiVersion).keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: '${componentBase}'
        }
      ]
    }
  }
}

resource dnsTxt 'Microsoft.Network/dnsZones/TXT@2018-05-01' = {
  name: '${dnsZone}/asuid.${applicationName}'
  properties: {
    TTL: 3600
    TXTRecords: [
      {
        value: [
          '${functionApp.properties.customDomainVerificationId}'
        ]
      }
    ]
  }
}

resource dnsCname 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  name: '${dnsZone}/${applicationName}'
  properties: {
    TTL: 3600
    CNAMERecord: {
      cname: '${functionApp.name}.azurewebsites.net'
    }
  }
}
// Enabling Managed certificate for a webapp requires 3 steps
// 1. Add custom domain to webapp with SSL in disabled state
// 2. Generate certificate for the domain
// 3. enable SSL
//
// The last step requires deploying again Microsoft.Web/sites/hostNameBindings - and ARM template forbids this in one deplyment, therefore we need to use modules to chain this.

resource functionAppCustomHost 'Microsoft.Web/sites/hostNameBindings@2020-06-01' = {
  name: '${functionApp.name}/${applicationName}.${dnsZone}'
  dependsOn: [
    dnsTxt
    dnsCname
  ]
  properties: {
    hostNameType: 'Verified'
    sslState: 'Disabled'
    customHostNameDnsRecordType: 'CName'
    siteName: functionApp.name
  }
}

resource functionAppCustomHostCertificate 'Microsoft.Web/certificates@2020-06-01' = {
  name: '${applicationName}.${dnsZone}'
  location: location
  dependsOn: [
    functionAppCustomHost
  ]
  properties: any({
    serverFarmId: hostingPlan.id
    canonicalName: '${applicationName}.${dnsZone}'
  })
}

// we need to use a module to enable sni, as ARM forbids using resource with this same type-name combination twice in one deployment.
module functionAppCustomHostEnable './sni-enable.bicep' = {
  name: '${deployment().name}-${applicationName}-sni-enable'
  params: {
    functionAppName: functionApp.name
    functionAppHostname: '${functionAppCustomHostCertificate.name}'
    certificateThumbprint: functionAppCustomHostCertificate.properties.thumbprint
  }
}
