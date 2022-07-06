---
description: This template enables you to setup email notifications for your Recovery Services vaults using Azure Monitor, by deploying an alert processing rule and an action group
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: recovery-services-create-alert-processing-rule
languages:
- json
- bicep
---
# Setup notifications for backup alerts using Azure Monitor

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-create-alert-processing-rule/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-create-alert-processing-rule/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-create-alert-processing-rule/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-create-alert-processing-rule/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-create-alert-processing-rule/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-create-alert-processing-rule/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-create-alert-processing-rule/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-create-alert-processing-rule%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-create-alert-processing-rule%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-create-alert-processing-rule%2Fazuredeploy.json)

This template enables you to setup email notifications for your Recovery Services vaults using Azure Monitor.

To route Azure Monitor based alerts to notification channels like email, [action groups](https://docs.microsoft.com/azure/azure-monitor/alerts/action-groups) and [alert processing rules](https://docs.microsoft.com/azure/azure-monitor/alerts/alerts-action-rules?tabs=portal) are used. This template deploys an alert processing rule and an action group in your required subscription to programmatically configure email notifications for all Recovery Services vaults in that subscription.

## More details

Azure Backup now provides a new and improved alerting solution using Azure Monitor. The following are the benefits of this new alerting solution:

* Ability to configure notifications to a wide range of notification channels - Azure Monitor supports a wide range of notification channels such as email, ITSM, webhooks, logic apps, and so on. You can configure notifications for backup alerts to any of these channels without needing to spend too much time creating custom integrations.

* Ability to select which scenarios to get notified about - With Azure Monitor alerts, you can choose which scenarios to get notified about. You also have the flexibility to choose whether to enable notifications for test subscriptions or not.

* Ability to manage alerts and notifications programmatically - You can leverage Azure Monitor's REST APIs to manage alerts and notifications via non-portal clients as well.

* Ability to have a consistent alerts management experience for multiple Azure services including backup - Azure Monitor is the established paradigm for monitoring resources across Azure. With the integration of Azure Backup with Azure Monitor, backup alerts can be managed in the same way as alerts for other Azure services without requiring a separate paradigm.

If you are using classic backup alerts, it is recommended to start using Azure Monitor based alerts for backup for its varied benefits.

[Learn more about Azure Backup Monitoring](https://docs.microsoft.com/azure/backup/monitoring-and-alerts-overview)

`Tags: Microsoft.Insights/actionGroups, Microsoft.AlertsManagement/actionRules`
