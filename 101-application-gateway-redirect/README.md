# Create Application Gateway with Http Redirects

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-application-gateway-redirect%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-application-gateway-redirect%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template illustrates different redirect scenarios Application Gateway supports:

1. Redirect http requests to https.
2. Redirect requests to a fixed url.
3. Redirect requests under a given path.

This functionality can be configured using RedirectConfiguration.

| Property | Mandatory | Description |
|---|---|---|
| RedirectType | Y | Supported http redirection types - Permanent, Temporary, Found, SeeOther |
| TargetListener | N | Reference to a listener to redirect the request to. |
| TargetUrl | N | A Url to redirect to. Cannot be used when TargetListener is specified.|
| IncludePath | N | True/False.|
| IncludeQueryString | N | True/False |

### Sample Redirect Configuration
```
{
    "redirectConfigurations": [
        {
            "Name": "redirectConfig1",
            "properties": {
                "redirectType": "Found",
                "targetListener": {
                    "id": "[concat(variables('applicationGatewayID'), '/httpListeners/appGatewayHttpsListener1')]"
                }
            }
        }
    ]
}
```
A RedirectConfiguration can be associated with either a listener in a basic rule, Or a Pathrule in UrlPathMap.

### Sample Configuration with Basic Rule
```
{
    "requestRoutingRules": [
        {
            "Name": "rule1",
            "properties": {
                "RuleType": "Basic",
                "httpListener": {
                    "id": "[concat(variables('applicationGatewayID'), '/httpListeners/appGatewayHttpListener1')]"
                },
                "redirectConfiguration": {
                    "id": "[concat(variables('applicationGatewayID'), '/redirectConfigurations/redirectConfig1')]"
                }
            }
        }
    ]
}
```

### Sample Configuration with UrlPathMap
```
{
    "urlPathMaps": [
        {
            "name": "urlPathMap1",
            "properties": {
              "defaultRedirectConfiguration": {
                "id": "[concat(variables('applicationGatewayID'), '/redirectConfigurations/redirectConfig2')]"
              },
                "pathRules": [
                    {
                        "name": "pathRule1",
                        "properties": {
                            "paths": [
                                "[parameters('pathMatch1')]"
                            ],
                            "redirectConfiguration": {
                                "id": "[concat(variables('applicationGatewayID'), '/redirectConfigurations/redirectConfig1')]"
                            }
                        }
                    }
                ]
            }
        }
    ]
}
```

### Notes:
Supported apiVersion to use http redirect feature is "2017-04-01" and above.

