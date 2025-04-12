---
description: Use such templates to easily create some important event alerts for your Azure Application Gateway.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: ag-alert-unhealthy-host
languages:
- json
---
# Alert for Unhealthy Host Count metric

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ag-alert-unhealthy-host/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ag-alert-unhealthy-host/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ag-alert-unhealthy-host/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ag-alert-unhealthy-host/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ag-alert-unhealthy-host/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ag-alert-unhealthy-host/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fag-alert-unhealthy-host%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fag-alert-unhealthy-host%2Fazuredeploy.json)

This template deploys an Azure Monitor alert which notifies you in an event **the total unhealthy host count is greater than the [dynamic threshold](https://docs.microsoft.com/azure/azure-monitor/alerts/alerts-dynamic-thresholds)**.

## Notes

- Azure Monitor alert rules are charged based on the type and number of signals it monitors. You may want to visit the [pricing page](https://azure.microsoft.com/pricing/details/monitor/) before deploying this alert template or can view the estimated cost after the deployment.

- You will need to create [Azure Monitor Action Group](https://docs.microsoft.com/azure/azure-monitor/alerts/action-groups) in advance and provide its ResourceID during this deployment. This action group notifies your users when the alert rule is triggered. You can use an existing or create a new one and reuse it for multiple such alerts.

  You can manually form the ResourceID for your Action Group by following these steps.
   1. Select Azure Monitor in your Azure portal
   1. Open Alerts blade and select Action Groups
   1. Select the action group to view its details
   1. Use the Resource Group Name, Action Group Name and Subscription Info here to form the ResourceID for the action group as shown below. <br>
`/subscriptions/<subscription-id-from-your-account>/resourcegroups/<resource-group-name>/providers/microsoft.insights/actiongroups/<action-group-name>`

- This guidance template uses generic settings for Severity, Aggregation Granularity, Frequency of Evaluation, Condition Type, etc. It uses Dynamic threshold value with [High sensitivity](https://docs.microsoft.com/azure/azure-monitor/alerts/alerts-dynamic-thresholds#what-does-sensitivity-setting-in-dynamic-thresholds-mean). It is recommended that you modify these after the deployment to suit your requirements. [Learn more](https://docs.microsoft.com/azure/azure-monitor/alerts/alerts-metric-overview).

`Tags: microsoft.insights/metricAlerts, Microsoft.Network/networkSecurityGroups, Microsoft.Network/publicIPAddresses, Microsoft.Network/virtualNetworks, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, CustomScriptExtension, Microsoft.Network/applicationGateways, Microsoft.Network/networkInterfaces, microsoft.insights/actionGroups`
