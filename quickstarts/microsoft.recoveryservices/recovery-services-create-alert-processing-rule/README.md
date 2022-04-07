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


