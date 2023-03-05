@description('Name of the CDN Profile')
param profileName string

@description('Name of the CDN Endpoint')
param endpointName string

@description('Url of the origin')
param originUrl string

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
  name: endpointName
  location: location
  properties: {
    originHostHeader: originUrl
    isHttpAllowed: true
    isHttpsAllowed: true
    queryStringCachingBehavior: 'IgnoreQueryString'
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
    deliveryPolicy: {
      description: 'Add Response Headers'
      rules: [
        {
          name: 'GeoMatchCondition'
          order: 1
          conditions: [
            {
              name: 'RemoteAddress'
              parameters: {
                typeName: 'DeliveryRuleRemoteAddressConditionParameters'
                operator: 'GeoMatch'
                matchValues: [
                  'US'
                ]
              }
            }
          ]
          actions: [
            {
              name: 'ModifyResponseHeader'
              parameters: {
                typeName: 'DeliveryRuleHeaderActionParameters'
                headerAction: 'Overwrite'
                headerName: 'X-CLIENT-COUNTRY'
                value: 'US'
              }
            }
          ]
        }
        {
          name: 'IPv4Match'
          order: 2
          conditions: [
            {
              name: 'RemoteAddress'
              parameters: {
                typeName: 'DeliveryRuleRemoteAddressConditionParameters'
                operator: 'IPMatch'
                matchValues: [
                  '0.0.0.0/0'
                ]
              }
            }
          ]
          actions: [
            {
              name: 'ModifyResponseHeader'
              parameters: {
                typeName: 'DeliveryRuleHeaderActionParameters'
                headerAction: 'Overwrite'
                headerName: 'X-CLIENT-IP-VERSION'
                value: 'IPv4'
              }
            }
          ]
        }
        {
          name: 'IPv6Match'
          order: 3
          conditions: [
            {
              name: 'RemoteAddress'
              parameters: {
                typeName: 'DeliveryRuleRemoteAddressConditionParameters'
                operator: 'IPMatch'
                matchValues: [
                  '::0/0'
                ]
              }
            }
          ]
          actions: [
            {
              name: 'ModifyResponseHeader'
              parameters: {
                typeName: 'DeliveryRuleHeaderActionParameters'
                headerAction: 'Overwrite'
                headerName: 'X-CLIENT-IP-VERSION'
                value: 'IPv6'
              }
            }
          ]
        }
      ]
    }
  }
}
