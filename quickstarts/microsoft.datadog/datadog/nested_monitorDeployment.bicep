param monitorName string
param location string
param skuName string
param singleSignOnState string
param tagRulesProperties object
param monitorTags object
param cspm bool

resource monitor 'Microsoft.Datadog/monitors@2023-01-01' = {
  name: monitorName
  location: location
  sku: {
    name: skuName
  }
  properties: {
    datadogOrganizationProperties: {
      name: monitorName
      enterpriseAppId: ''
      cspm: cspm
    }
    userInfo: {
      name: ''
      phoneNumber: ''
    }
  }
  tags: monitorTags
  identity: {
    type: 'SystemAssigned'
  }
}

resource tagRule 'Microsoft.Datadog/monitors/tagRules@2023-01-01' = {
  parent: monitor
  name: 'default'
  properties: tagRulesProperties
}

resource ssoConfig 'Microsoft.Datadog/monitors/singleSignOnConfigurations@2023-01-01' = {
  parent: monitor
  name: 'default'
  properties: {
    enterpriseAppId: ''
    singleSignOnState: singleSignOnState
  }
}

output monitorPrincipalId string = monitor.identity.principalId
