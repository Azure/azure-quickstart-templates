@description('Origin details')
param origins array

@description('Custom Domain Array')
param customDomains array

@description('Name of CDN Profile. For chaining, use output from parent module')
param cdnProfileName string

@description('Name of AFD endpoint')
param afdEndpointName string

@description('Rulesets List')
param routeRuleSets array

@description('Default Content to compress')
var contentTypeCompressionList = [
  'application/eot'
  'application/font'
  'application/font-sfnt'
  'application/javascript'
  'application/json'
  'application/opentype'
  'application/otf'
  'application/pkcs7-mime'
  'application/truetype'
  'application/ttf'
  'application/vnd.ms-fontobject'
  'application/xhtml+xml'
  'application/xml'
  'application/xml+rss'
  'application/x-font-opentype'
  'application/x-font-truetype'
  'application/x-font-ttf'
  'application/x-httpd-cgi'
  'application/x-javascript'
  'application/x-mpegurl'
  'application/x-opentype'
  'application/x-otf'
  'application/x-perl'
  'application/x-ttf'
  'font/eot'
  'font/ttf'
  'font/otf'
  'font/opentype'
  'image/svg+xml'
  'text/css'
  'text/csv'
  'text/html'
  'text/javascript'
  'text/js'
  'text/plain'
  'text/richtext'
  'text/tab-separated-values'
  'text/xml'
  'text/x-script'
  'text/x-component'
  'text/x-java-source'
]

resource cdn 'Microsoft.Cdn/profiles@2021-06-01' existing = {
  name: cdnProfileName
}

resource afd_endpoint 'Microsoft.Cdn/profiles/afdendpoints@2021-06-01' existing = {
  parent: cdn
  name: afdEndpointName
}

resource custom_domains 'Microsoft.Cdn/profiles/customdomains@2021-06-01' existing = [for config in customDomains: {
  parent: cdn
  name: replace(config.hostname, '.', '-')
}]

resource origin_group 'Microsoft.Cdn/profiles/originGroups@2021-06-01' existing = [for (group, index) in origins: {
  parent: cdn
  name: group.originGroupName
}]

resource origin_routes 'Microsoft.Cdn/profiles/afdendpoints/routes@2021-06-01' = [ for (group, index) in origins: {
  parent: afd_endpoint
  name: '${group.originGroupName}-route'
  properties: {
    cacheConfiguration: {
      compressionSettings: {
        isCompressionEnabled: true
        contentTypesToCompress: contentTypeCompressionList
      }
      queryStringCachingBehavior: 'UseQueryString'
    }
    customDomains: [ for (domain, cid) in customDomains: {
      id: custom_domains[cid].id
    }]
    originGroup: {
      id: origin_group[index].id
    }
    ruleSets: routeRuleSets
    supportedProtocols: [
      'Https'
    ]
    patternsToMatch: group.patternsToMatch
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
  }
}]