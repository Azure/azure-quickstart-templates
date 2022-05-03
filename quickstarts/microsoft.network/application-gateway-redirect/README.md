# Create Application Gateway with Http Redirects

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-redirect/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-redirect/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-redirect/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-redirect/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-redirect/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-redirect/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fapplication-gateway-redirect%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fapplication-gateway-redirect%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fapplication-gateway-redirect%2Fazuredeploy.json)

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



