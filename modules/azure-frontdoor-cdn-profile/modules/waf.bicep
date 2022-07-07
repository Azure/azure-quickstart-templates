@sys.description('Name of Azure CDN SKU')
param skuName string

@sys.description('Name of the WAF policy to create.')
param wafPolicyName string 

@allowed([
  'Detection'
  'Prevention'
])
@sys.description('Describes if it is in detection mode or prevention mode at policy level.')
param wafPolicyMode string

@sys.description('Describes if the policy needs to enabled or disabled.')
param enableWAFPolicy bool

@sys.description('Response body to return on Block')
param wafBlockResponseBody string = 'Access Denied by Firewall.'

@allowed([
  401
  403
])
@sys.description('Response Code to return on Block. Default to 403')
param wafBlockResponseCode int = 403


@sys.description('Describes if request body should be checked. Since we only allow GET in this module due to Custom Rule, default to false')
param enableRequestBodyCheck bool = false

resource waf 'Microsoft.Network/frontdoorwebapplicationfirewallpolicies@2020-11-01' = {
  name: wafPolicyName
  location: 'Global'
  sku: {
    name: skuName
  }
  properties: {
    policySettings: {
      enabledState: enableWAFPolicy ? 'Enabled' : 'Disabled'
      mode: wafPolicyMode
      customBlockResponseStatusCode: wafBlockResponseCode
      customBlockResponseBody: base64(wafBlockResponseBody)
      requestBodyCheck: enableRequestBodyCheck ? 'Enabled' : 'Disabled'
    }
    customRules: {
      rules: [
        {
          name: 'BlockMethod'
          enabledState: 'Enabled'
          priority: 10
          ruleType: 'MatchRule'
          rateLimitDurationInMinutes: 1
          rateLimitThreshold: 100
          matchConditions: [
            {
              matchVariable: 'RequestMethod'
              operator: 'Equal'
              negateCondition: true
              matchValue: [
                'GET'
                'OPTIONS'
                'HEAD'
              ]
              transforms: []
            }
          ]
          action: 'Block'
        }
      ]
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_DefaultRuleSet'
          ruleSetVersion: '2.0'
          ruleSetAction: 'Log'
          ruleGroupOverrides: [
            {
              ruleGroupName: 'NODEJS'
              rules: [
                {
                  ruleId: '934100'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'General'
              rules: [
                {
                  ruleId: '200003'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '200002'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920480'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920470'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920450'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920440'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920430'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920420'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920350'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920341'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920340'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920330'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920320'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920311'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920310'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920300'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920290'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920280'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920271'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920270'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920260'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920240'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920230'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920220'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920210'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920201'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920200'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920190'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920180'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920171'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920170'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920160'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920121'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920120'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '920100'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'METHOD-ENFORCEMENT'
              rules: [
                {
                  ruleId: '911100'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'JAVA'
              rules: [
                {
                  ruleId: '944250'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '944240'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '944210'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '944200'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '944130'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '944120'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '944110'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '944100'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'FIX'
              rules: [
                {
                  ruleId: '943120'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '943110'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '943100'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'SQLI'
              rules: [
                {
                  ruleId: '942510'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942500'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942480'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942470'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942450'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942440'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942430'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942410'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942400'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942390'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942380'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942370'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942361'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942360'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942350'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942340'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942330'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942320'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942310'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942300'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942290'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942280'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942270'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942260'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942250'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942240'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942230'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942220'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942210'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942200'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942190'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942180'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942170'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942160'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942150'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942140'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942120'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942110'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '942100'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'XSS'
              rules: [
                {
                  ruleId: '941380'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941370'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941360'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941350'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941340'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941330'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941320'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941310'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941300'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941290'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941280'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941270'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941260'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941250'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941240'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941230'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941220'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941210'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941200'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941190'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941180'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941170'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941160'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941150'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941140'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941130'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941120'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941110'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941101'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '941100'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'PHP'
              rules: [
                {
                  ruleId: '933210'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '933200'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '933180'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '933170'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '933160'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '933151'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '933150'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '933140'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '933130'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '933120'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '933110'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '933100'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'RCE'
              rules: [
                {
                  ruleId: '932180'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '932171'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '932170'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '932160'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '932150'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '932140'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '932130'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '932120'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '932115'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '932110'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '932105'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '932100'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'RFI'
              rules: [
                {
                  ruleId: '931130'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '931120'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '931110'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '931100'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'LFI'
              rules: [
                {
                  ruleId: '930130'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '930120'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '930110'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '930100'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'PROTOCOL-ATTACK'
              rules: [
                {
                  ruleId: '921151'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '921160'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '921150'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '921140'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '921130'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '921120'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '921110'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'MS-ThreatIntel-CVEs'
              rules: [
                {
                  ruleId: '99001016'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '99001015'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '99001014'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '99001001'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'MS-ThreatIntel-SQLI'
              rules: [
                {
                  ruleId: '99031002'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '99031001'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'MS-ThreatIntel-AppSec'
              rules: [
                {
                  ruleId: '99030002'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '99030001'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
              ]
              exclusions: []
            }
            {
              ruleGroupName: 'MS-ThreatIntel-WebShells'
              rules: [
                {
                  ruleId: '99005006'
                  enabledState: 'Disabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '99005004'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '99005003'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
                {
                  ruleId: '99005002'
                  enabledState: 'Enabled'
                  action: 'Log'
                  exclusions: []
                }
              ]
              exclusions: []
            }
          ]
          exclusions: []
        }
      ]
    }
  }
}

output cdnWafId string = waf.id
output cdnWafName string = waf.name
