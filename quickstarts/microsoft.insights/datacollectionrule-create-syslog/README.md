# Data Collection Rule

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.insights/datacollectionrule-create-syslog/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.insights/datacollectionrule-create-syslog/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.insights/datacollectionrule-create-syslog/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.insights/datacollectionrule-create-syslog/FairfaxDeployment.svg)
    
![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.insights/datacollectionrule-create-syslog/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.insights/datacollectionrule-create-syslog/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.insights%2Fdatacollectionrule-create-syslog%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.insights%2Fdatacollectionrule-create-syslog%2Fazuredeploy.json)

This template creates a data collection rule defining the data source (Syslog) and the destination workspace.

## Sample overview and deployed resources

The following resources are deployed

### Microsoft.Insights/dataCollectionRules

Data collection rule (DCR) - defines:
- Data Sources: WHAT data should be collected
- Destinations: WHERE it should be sent
- Data flows: HOW to route data streams 

**MySyslogDcr**: Defines *Microsoft-Syslog* as the data source, and the log analytics *workspaceResourceId* as the destination.

## Prerequisites

A log analytics workspace resource created. The resource ID will be the input of the deployment.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Notes

For more information on **data collection rules**, please visit:

- [Data Collection Rules overview](https://docs.microsoft.com/en-us/azure/azure-monitor/agents/data-collection-rule-overview)
- [Data Collection Rule Associations](https://docs.microsoft.com/en-us/azure/azure-monitor/agents/data-collection-rule-azure-monitor-agent)
- [Azure Monitor agent overview](https://docs.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview)
- [Install Azure Monitor agent](https://docs.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-install)

`Tags: DCR, DCRA, Monitor, data collection, data collection rule, azure monitor`
