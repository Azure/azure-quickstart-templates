@description('Name of the CDN Profile')
param profileName string

@description('Name of the CDN Endpoint')
param endpointName string

@description('Url of the origin')
param originUrl string

@description('Subscription Id of UrlSigning Keys')
param urlSigningKeysSubId string

@description('Resourcegroup of UrlSigning Keys')
param urlSigningKeysResourceGroup string

@description('Keyvault of UrlSigning Keys')
param urlSigningKeysVaultName string

@description('UrlSigning keys secret1 Name')
param urlSigningKeysSecret1Name string

@description('UrlSigning keys secret1 version')
param urlSigningKeysSecret1Version string

@description('UrlSigning keys secret2 Name')
param urlSigningKeysSecret2Name string

@description('UrlSigning keys secret2 version')
param urlSigningKeysSecret2Version string

@description('CDN SKU names')
@allowed([
  'Standard_Akamai'
  'Standard_Verizon'
  'Premium_Verizon'
  'Standard_Microsoft'
])
param CDNSku string = 'Standard_Microsoft'

@description('Location for all resources.')
param location string = resourceGroup().location

resource profile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: profileName
  location: location
  sku: {
    name: CDNSku
  }
}

resource endpoint 'Microsoft.Cdn/profiles/endpoints@2021-06-01' = {
  parent: profile
  location: location
  name: endpointName
  properties: {
    originHostHeader: originUrl
    isHttpAllowed: true
    isHttpsAllowed: true
    queryStringCachingBehavior: 'UseQueryString'
    contentTypesToCompress: [
      'text/plain'
      'text/html'
      'text/css'
      'application/x-javascript'
      'text/javascript'
    ]
    isCompressionEnabled: true
    origins: [
      {
        name: 'origin1'
        properties: {
          hostName: originUrl
        }
      }
    ]
    urlSigningKeys: [
      {
        keyId: 'key1'
        keySourceParameters: {
          typeName: 'KeyVaultSigningKeyParameters'
          subscriptionId: urlSigningKeysSubId
          resourceGroupName: urlSigningKeysResourceGroup
          vaultName: urlSigningKeysVaultName
          secretName: urlSigningKeysSecret1Name
          secretVersion: urlSigningKeysSecret1Version
        }
      }
      {
        keyId: 'key2'
        keySourceParameters: {
          typeName: 'KeyVaultSigningKeyParameters'
          subscriptionId: urlSigningKeysSubId
          resourceGroupName: urlSigningKeysResourceGroup
          vaultName: urlSigningKeysVaultName
          secretName: urlSigningKeysSecret2Name
          secretVersion: urlSigningKeysSecret2Version
        }
      }
    ]
    deliveryPolicy: {
      description: 'UrlSigning'
      rules: [
        {
          name: 'rule1'
          order: 1
          conditions: [
            {
              name: 'UrlPath'
              parameters: {
                operator: 'Equal'
                matchValues: [
                  '/urlsigning/test'
                ]
                typeName: 'DeliveryRuleUrlPathMatchConditionParameters'
              }
            }
          ]
          actions: [
            {
              name: 'UrlSigning'
              parameters: {
                keyId: 'key1'
                algorithm: 'SHA256'
                typeName: 'DeliveryRuleUrlSigningActionParameters'
              }
            }
            {
              name: 'CacheKeyQueryString'
              parameters: {
                queryStringBehavior: 'Exclude'
                queryParameters: 'expires,keyid,signature'
                typeName: 'DeliveryRuleCacheKeyQueryStringBehaviorActionParameters'
              }
            }
          ]
        }
        {
          name: 'rule2'
          order: 2
          conditions: [
            {
              name: 'UrlPath'
              parameters: {
                operator: 'Equal'
                matchValues: [
                  '/urlsigning/test2'
                ]
                typeName: 'DeliveryRuleUrlPathMatchConditionParameters'
              }
            }
          ]
          actions: [
            {
              name: 'UrlSigning'
              parameters: {
                keyId: 'key2'
                algorithm: 'SHA256'
                parameterNameOverride: [
                  {
                    paramIndicator: 'Expires'
                    paramName: 'oexpires'
                  }
                  {
                    paramIndicator: 'KeyId'
                    paramName: 'okeyid'
                  }
                  {
                    paramIndicator: 'Signature'
                    paramName: 'osignature'
                  }
                ]
                typeName: 'DeliveryRuleUrlSigningActionParameters'
              }
            }
            {
              name: 'CacheKeyQueryString'
              parameters: {
                queryStringBehavior: 'Exclude'
                queryParameters: 'oexpires,okeyid,osignature'
                typeName: 'DeliveryRuleCacheKeyQueryStringBehaviorActionParameters'
              }
            }
          ]
        }
      ]
    }
  }
}
