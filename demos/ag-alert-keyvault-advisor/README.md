This template deploys an Azure Monitor alert which notifies you in an event **an Application Gateway in the given resource group is facing Key Vault related issues**.  

**Notes**

- Azure Monitor alert rules are charged based on the type and number of signals it monitors. You may want to visit the [pricing page](https://azure.microsoft.com/en-in/pricing/details/monitor/) before deploying this alert template or can view the estimated cost after the deployment. 

- You will need to create [Azure Monitor Action Group](https://docs.microsoft.com/en-us/azure/azure-monitor/alerts/action-groups) in advance and provide its ResourceID during this deployment. This action group notifies your users when the alert rule is triggered. You can use an existing or create a new one and reuse it for multiple such alerts.

>[!TIP]
> You can manually form the ResourceID for your Action Group by following these steps.
> 1. Select Azure Monitor in your Azure portal
> 1. Open Alerts blade and select Action Groups
> 1. Select the action group to view its details
> 1. Use the Resource Group Name, Action Group Name and Subscription Info here to form the ResourceID for the action group as shown below. <br>
> `/subscriptions/<subscription-id-from-your-account>/resourcegroups/<resource-group-name>/providers/microsoft.insights/actiongroups/<action-group-name>` 
