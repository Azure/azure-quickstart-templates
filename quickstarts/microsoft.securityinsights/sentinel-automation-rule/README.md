---
description: This sample shows how to create a new automation rule in Microsoft Sentinel
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: sentinel-automation-rule
languages:
- json
---
# Creates a new Microsoft Sentinel Automation Rule

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.securityinsights/sentinel-automation-rule/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.securityinsights/sentinel-automation-rule/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.securityinsights/sentinel-automation-rule/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.securityinsights/sentinel-automation-rule/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.securityinsights/sentinel-automation-rule/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.securityinsights/sentinel-automation-rule/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.securityinsights%2Fsentinel-automation-rule%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.securityinsights%2Fsentinel-automation-rule%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.securityinsights%2Fsentinel-automation-rule%2Fazuredeploy.json)

This sample template demonstrates how to create an Automation Rule in your Microsoft Sentinel workspace. This sample automation rule triggers on incident creation and looks for specific analytic rule ID, severity, tactics and title. If the incident matches these conditions, it then modifies incident status and adds a tag. For more information about automation rules, visit [Automation in Azure Sentinel](https://docs.microsoft.com/azure/sentinel/automation-in-azure-sentinel)

## Prerequisites ##

In order to deploy this template successfully, you need to have an existing Microsoft Sentinel workspace. Optionally, you need an analytics rule ID. If you do not wish to target a specific analytic rule ID, you can remove that parameter and its condition from the azuredeploy.json file.

`Tags: Microsoft.SecurityInsights/automationRules, Microsoft.OperationalInsights/workspaces, Microsoft.OperationalInsights/workspaces/providers/onboardingStates, Microsoft.OperationalInsights/workspaces/providers/alertRules`
