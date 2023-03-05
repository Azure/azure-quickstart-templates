@description('Name of CDN Profile. For chaining, use output from parent module')
param cdnProfileName string

resource cdn 'Microsoft.Cdn/profiles@2021-06-01' existing = {
  name: cdnProfileName
}

@description('Default ruleset')
resource global_rulesets 'Microsoft.Cdn/profiles/rulesets@2021-06-01' = {
  parent: cdn
  name: 'Global'
}

@description('Modify other request-response headers and add to global rulesets')
resource drs_global_overwriteResponseHeaders_rule 'Microsoft.Cdn/profiles/rulesets/rules@2021-06-01' = {
  parent: global_rulesets
  name: 'OverwriteResponseHeaders'
  properties: {
    order: 1
    actions: [
      {
        name: 'ModifyResponseHeader'
        parameters: {
          typeName: 'DeliveryRuleHeaderActionParameters'
          headerAction: 'Overwrite'
          headerName: 'X-CDN'
          value: 'AZUR'
        }
      }
      {
        name: 'RouteConfigurationOverride'
        parameters: {
          typeName: 'DeliveryRuleRouteConfigurationOverrideActionParameters'
          cacheConfiguration: {
            isCompressionEnabled: 'Enabled'
            queryStringCachingBehavior: 'UseQueryString'
            cacheBehavior: 'OverrideIfOriginMissing'
            cacheDuration: '365.00:00:00'
          }
        }
      }
    ]
    matchProcessingBehavior: 'Continue'
  }
} 

output defaultRuleSetId string = global_rulesets.id