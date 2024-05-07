//Storage account

@description('The location into which the Azure Storage resource should be deployed.')
param location string

@description('The name of the Azure Storage account to create. This must be globally unique.')
param storageAccountName string

@description('The name of the SKU to use when creating the Azure Storage account.')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageSkuName string = 'Standard_LRS'

@description('The name of the Azure Storage blob container to create.')
param storageBlobContainerName string 

module storage 'modules/storage.bicep' = {
  name: 'storage'
  params: {
    location: location
    accountName: storageAccountName
    skuName: storageSkuName
    blobContainerName: storageBlobContainerName
  }
}

//--------------------------------------------------------------

//Front Door origin group

@description('Name of existing Front Door.')
param frontDoorName string

@description('Front Door endpoint name')
param endpointName string

@description('The name of the origin group. 01ukwest in our example.')
param originGroupName string

@description('The path that should be used when connecting to the origin. For example, /testuploadcontainer')
param originPath string = '/${storageBlobContainerName}'

param originForwardingProtocol string = 'HttpsOnly'

resource profile 'Microsoft.Cdn/profiles@2021-06-01' existing ={
  name: frontDoorName
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' existing = {
  name: endpointName
  parent: profile
}

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: originGroupName
  parent: profile

  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
       additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/${originGroupName}/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 100
    }
  }
}

resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  name: originGroupName
  parent: originGroup
  properties: {
    hostName: storage.outputs.blobEndpointHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: storage.outputs.blobEndpointHostName
    priority: 1
    weight: 1000
    sharedPrivateLinkResource: null
    }
  }

  resource ruleSet 'Microsoft.Cdn/profiles/ruleSets@2021-06-01' = {
    name: 'rs${originGroupName}'
    parent: profile
  }
  
  resource urlRewriteRule 'Microsoft.Cdn/profiles/rulesets/rules@2021-06-01' = {
    name: 'rewrite'
    parent: ruleSet
    properties: {
      order: 1
      conditions: [
        {
          name: 'UrlPath'
          parameters: {
            operator: 'BeginsWith'
            negateCondition: false
            matchValues: [
              '/${originGroupName}/'
            ]
            transforms: [
              'Lowercase'
            ]
            typeName: 'DeliveryRuleUrlPathMatchConditionParameters'
          }
        }
      ]
      actions: [
        {
          name: 'UrlRewrite'
          parameters: {
          sourcePattern:'/${originGroupName}/'
          destination: '/'
          preserveUnmatchedPath: true
          typeName: 'DeliveryRuleUrlRewriteActionParameters'
          }
        }
      ]
    }
  }

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: originGroupName
  parent: endpoint
  dependsOn: [
    origin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {
    
    originGroup: {
      id: originGroup.id
    }
    originPath: originPath != '' ? originPath : null
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/${originGroupName}/*'
    ]

    forwardingProtocol: originForwardingProtocol
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'

     ruleSets: [
      {
        id: ruleSet.id
      }
    ]
  }
}



