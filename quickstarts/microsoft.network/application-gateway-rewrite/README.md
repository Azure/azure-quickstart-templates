# Create Application Gateway with Header Rewrite Rules

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-rewrite/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-rewrite/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-rewrite/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-rewrite/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-rewrite/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-rewrite/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fapplication-gateway-rewrite%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fapplication-gateway-rewrite%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fapplication-gateway-rewrite%2Fazuredeploy.json)

Application Gateway now supports the ability to rewrite headers of the incoming HTTP requests as well as the outgoing HTTP responses. You will be able to add, remove or update HTTP request and response headers while the request/response packets move between the client and backend pools.

With this change, you need to:
1.	Create the new objects required to rewrite the http headers:
    a.	""requestHeaderConfiguration" and "responseHeaderConfiguration": to specify the names of headers that you intend to rewrite and new value that the original headers need to be rewritten to.
    b.	“actionSet”- this object contains the configurations of the request and response headers specified above.
    c.	“rewriteRule”- this object contains all the actionSets
    d.	“rewriteRuleSet”- this object contains all the rewriteRules and will need to be attached to a request routing rule- basic or path-based
2.	You will then be required to attach the rewrite rule set with a routing rule. Once created, this rewrite configuration is attached to the source listener via the routing rule. When using a basic routing rule, the header rewrite configuration is associated with a source listener and is a global header rewrite. When a path-based routing rule is used, the header rewrite configuration is defined on the URL path map. So, it only applies to the specific path area of a site.

You can create multiple http header rewrite rule sets and each rewrite rule set can be applied to multiple listeners. However, you can apply only one http rewrite rule set to a specific listener.

| Property | Required | Description |
|---|---|---|
| rewriteRuleSets[] | No | List of rewrite rule sets. Each rewriteRuleSet contains a set of rules which have a sequence associated with them. |
| rewriteRuleSets[].rules[] | Yes | Set of rules which are grouped together which can be associated to one or more request routing rule(s). |
| rules[].actionSet | Yes | Set of actions to take when all the conditions are met. |
| rules[].requestHeaderConfiguration[] | No | List of request header actions to take. Either sets or deletes the request headers based on the values of headers or server variables. |
| requestHeaderConfiguration[].headerName | Yes | Name of the header to set. |
| requestHeaderConfiguration[].headerValue | Yes | Value to set for the header. It can be a constant string or a format string. If the value is set to an empty string, the header will be removed from the HTTP packet.

### Sample Rewrite Configuration
```
{
    "rewriteRuleSet": [
        {
        "name": "RewriteRuleSet1",
        "properties": {
            "rewriteRule": [
            {
                "name": "RWRule1",
                "actionSet": {
                "requestHeaderConfiguration": [
                    {
                    "headerName": "X-Forwarded-For",
                    "headerValue": "source IP"
                    },
                    {
                    "headerName": "Ciphers-Used",
                    "headerValue": "{var_ssl_cipher}"
                    }
                ],
                "responseHeaderConfiguration": [
                    {
                    "headerName": "Strict-Transport-Security",
                    "headerValue": "max-age=31536000"
                    }
                ]
                }
            }
            ]
        },
        "type": "Microsoft.Network/applicationGateways/rewriteRuleSet"
        }
    ]
}
```

### Sample request routing rule configuration with rewrite rule set
```
{
  "requestRoutingRules": [
    {
      "Name": "HttpRule1",
      "properties": {
        "RuleType": "Basic",
        "httpListener": {
          "id": "[resourceId('Microsoft.Network/applicationGateways/httpListeners', variables('applicationGatewayName'), 'HttpListener')]"
        },
        "backendAddressPool": {
          "id": "[resourceId('Microsoft.Network/applicationGateways/backendAddressPools', variables('applicationGatewayName'), 'appGatewayBackendPool')]"
        },
        "backendHttpSettings": {
          "id": "[resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', variables('applicationGatewayName'), 'appGatewayBackendHttpSettings')]"
        },
        "rewriteRuleSet": {
          "id": "[resourceId('Microsoft.Network/applicationGateways/rewriteRuleSets', variables('applicationGatewayName'), 'rewriteRuleSet1')]"
        }
      }
    }
  ]
}
```

You can rewrite the value in the headers to:
a.	Text value
Example: $responseHeaderConfiguration = New-AzureRmApplicationGatewayRewriteRuleHeaderConfiguration -HeaderName "Strict-Transport-Security" -HeaderValue "max-age=31536000")
b.	Value from another header
c.	Value from supported server variables
Example: $requestHeaderConfiguration = New-AzureRmApplicationGatewayRewriteRuleHeaderConfiguration -HeaderName "Ciphers-Used" -HeaderValue "{var_ssl_cipher}"
Note: In order to specify a server variable, you need to use the syntax: {var_ServerVariable}
d.	A combination of the above

For more details, please visit https://aka.ms/appgwheadercrud

### Notes:
Supported apiVersion to use http rewrite feature is "2018-10-01" and above.


