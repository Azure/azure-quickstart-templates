@description('The name of the WAF policy')
param wafPolicyName string

@description('Describes if it is in detection mode or prevention mode at policy level.')
@allowed([
  'Detection'
  'Prevention'
])
param wafMode string = 'Detection'


resource wafPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2020-11-01' = {
  name: wafPolicyName
  location: 'global'
  properties: {
    policySettings: {
      mode: wafMode
      enabledState: 'Enabled'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'DefaultRuleSet'
          ruleSetVersion: '1.0'
        }
      ]
    }
  }
}
