---
description: This template creates an Application Gateway with WAF configured along with a firewall policy
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: application-gateway-waf-firewall-policy
languages:
- json
- bicep
---
# Application Gateway with WAF and firewall policy

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-waf-firewall-policy/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-waf-firewall-policy/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-waf-firewall-policy/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-waf-firewall-policy/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-waf-firewall-policy/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-waf-firewall-policy/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-waf-firewall-policy/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fapplication-gateway-waf-firewall-policy%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fapplication-gateway-waf-firewall-policy%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fapplication-gateway-waf-firewall-policy%2Fazuredeploy.json)

This module will create an application gateway.

You can optionally configure the following:
- Web Application Firewall (WAF)
- Application Gateway Firewall Policy
- Key vault integration with a managed identity for certificate retrieval
- Diagnostic logs and resource lock

`Tags: bicep, network, waf, applicationgateway, Microsoft.Network/publicIPAddresses, Microsoft.Insights/diagnosticSettings, Microsoft.Authorization/locks, Microsoft.Network/applicationGateways, Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies, Microsoft.Network/virtualNetworks`