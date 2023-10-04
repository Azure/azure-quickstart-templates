param resourceName string
param location string
param emailAddress string
param firstName string
param lastName string
param tagRulesProperties object
param monitorTags object = {}
param effectiveDate string = utcNow('yyyy-MM-ddTHH:mm:ssZ')

resource monitor 'NewRelic.Observability/monitors@2022-07-01' = {
  name: resourceName
  location: location
  properties: {
    planData: {
      usageType: 'PAYG'
      billingCycle: 'MONTHLY'
      planDetails: 'newrelic-pay-as-you-go-free-live@TIDgmz7xq9ge3py@PUBIDnewrelicinc1635200720692.newrelic_liftr_payg'
      effectiveDate: effectiveDate
    }
    userInfo: {
      firstName: firstName
      lastName: lastName
      emailAddress: emailAddress
      phoneNumber: ''
    }
  }
  tags: monitorTags
  identity: {
    type: 'SystemAssigned'
  }
}

resource resourceName_default 'NewRelic.Observability/monitors/tagRules@2022-07-01' = {
  parent: monitor
  name: 'default'
  properties: tagRulesProperties
}

output monitorPrincipalId string = monitor.identity.principalId
