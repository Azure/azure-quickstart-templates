@description('Name of the CDN Profile.')
param profileName string

@description('Pricing tier of the CDN Profile.')
@allowed([
  'Standard_Verizon'
  'Premium_Verizon'
  'Custom_Verizon'
  'Standard_Akamai'
  'Standard_ChinaCdn'
  'Standard_Microsoft'
  'Premium_ChinaCdn'
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
  'Standard_955BandWidth_ChinaCdn'
  'Standard_AvgBandWidth_ChinaCdn'
  'StandardPlus_ChinaCdn'
  'StandardPlus_955BandWidth_ChinaCdn'
  'StandardPlus_AvgBandWidth_ChinaCdn'
])
param sku string = 'Standard_Microsoft'

@description('Name of the CDN Endpoint.')
param endpointName string

@description('Whether the HTTP traffic is allowed.')
param isHttpAllowed bool = true

@description('Whether the HTTPS traffic is allowed.')
param isHttpsAllowed bool = true

@description('Query string caching behavior.')
@allowed([
  'IgnoreQueryString'
  'BypassCaching'
  'UseQueryString'
])
param queryStringCachingBehavior string = 'IgnoreQueryString'

@description('Content type that is compressed.')
param contentTypesToCompress array = [
  'text/plain'
  'text/html'
  'text/css'
  'application/x-javascript'
  'text/javascript'
]

@description('Whether the compression is enabled')
param isCompressionEnabled bool = true

@description('Url of the origin')
param originUrl string

@description('Location for all resources.')
param location string = 'global'

resource profile 'Microsoft.Cdn/profiles@2020-09-01' = {
  name: profileName
  location: location
  properties: {}
  sku: {
    name: sku
  }
}

resource endpoint 'Microsoft.Cdn/profiles/endpoints@2020-09-01' = {
  parent: profile
  location: location
  name: endpointName
  properties: {
    originHostHeader: originUrl
    isHttpAllowed: isHttpAllowed
    isHttpsAllowed: isHttpsAllowed
    queryStringCachingBehavior: queryStringCachingBehavior
    contentTypesToCompress: contentTypesToCompress
    isCompressionEnabled: isCompressionEnabled
    origins: [
      {
        name: 'origin1'
        properties: {
          hostName: originUrl
        }
      }
    ]
  }
}
