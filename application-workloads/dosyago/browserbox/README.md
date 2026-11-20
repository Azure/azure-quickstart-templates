---
description: BrowserBox remote browser isolation on Azure. The existing deployment template needs updating before use.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: browserbox
languages:
- json
---
# BrowserBox Azure Edition

> **Deployment status:** The existing Azure template is outdated and should not be used for a new deployment. Its bootstrap references installer scripts that are no longer present in the public BrowserBox repository. An updated template requires deployment testing before it can be submitted.

[BrowserBox](https://browserbox.io/?utm_source=azure_quickstart&utm_medium=listing&utm_campaign=browserbox) is self-hosted remote browser isolation. It runs a Chromium browser on infrastructure you control and streams an interactive view to a modern browser.

BrowserBox requires a valid license key, including for evaluation. See the [evaluation options](https://browserbox.io/evaluate) and the [BrowserBox customer guide](https://docs.browserbox.io/installation/) for current installation and licensing instructions. Azure infrastructure charges and BrowserBox licensing are separate.

The template files in this sample remain for reference while a replacement is prepared. Do not enter credentials into an unverified deployment. For product support, contact support@dosyago.com.

`Tags: Microsoft.Authorization/roleAssignments, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, Microsoft.Insights/components, Microsoft.Insights/actionGroups, Microsoft.Insights/metricAlerts, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, Microsoft.OperationalInsights/workspaces, CustomScriptExtension`
