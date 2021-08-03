# Log Analytics

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.insights/log-analytics-with-datasources-solutions/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.insights/log-analytics-with-datasources-solutions/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.insights/log-analytics-with-datasources-solutions/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.insights/log-analytics-with-datasources-solutions/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.insights/log-analytics-with-datasources-solutions/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.insights/log-analytics-with-datasources-solutions/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.insights/log-analytics-with-datasources-solutions/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.insights%2Flog-analytics-with-datasources-solutions%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.insights%2Flog-analytics-with-datasources-solutions%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.insights%2Flog-analytics-with-datasources-solutions%2Fazuredeploy.json)

This module will deploy a Log Analytics Workspace with solutions, data sources and linked to an automation account.

## Usage

### Example 1 - Log Analytics Workspace with solutions and data sources
``` bicep
param deploymentName string = concat('logAnalytics', utcNow())

module logAnalytics './main.bicep' = {
  name: deploymentName
  params: {
    name: 'myLogAnalyticsWorkspace'
    sku: 'PerGB2018'
    retentionInDays: 30
    solutions: [
      {
        name: 'AzureActivity'
        product: 'OMSGallery/AzureActivity'
        publisher: 'Microsoft'
        promotionCode: ''
      }
    ]
    dataSources: [
      {
        name: 'Application'
        kind: 'WindowsEvent'
        properties: {
          eventLogName: 'Application'
          eventTypes: [
            {
              eventType: 'Error'
            }
            {
              eventType: 'Warning'
            }
          ]
        }
      }
      {
        name: 'LogicalDisk1'
        kind: 'WindowsPerformanceCounter'
        properties: {
          objectName: 'LogicalDisk'
          instanceName: '*'
          intervalSeconds: 360
          counterName: 'Avg Disk sec/Read'
        }
      }
    ]
  }
}
```

### Example 2 - Log Analytics Workspace with solutions, data sources and linked to an automation account
``` bicep
param deploymentName string = concat('logAnalytics', utcNow())

module logAnalytics './main.bicep' = {
  name: deploymentName
  params: {
    name: 'myLogAnalyticsWorkspace'
    sku: 'PerGB2018'
    retentionInDays: 30
    automationAccountName: 'myAutomationAccount'
    solutions: [
      {
        name: 'AzureActivity'
        product: 'OMSGallery/AzureActivity'
        publisher: 'Microsoft'
        promotionCode: ''
      }
    ]
    dataSources: [
      {
        name: 'Application'
        kind: 'WindowsEvent'
        properties: {
          eventLogName: 'Application'
          eventTypes: [
            {
              eventType: 'Error'
            }
            {
              eventType: 'Warning'
            }
          ]
        }
      }
      {
        name: 'LogicalDisk1'
        kind: 'WindowsPerformanceCounter'
        properties: {
          objectName: 'LogicalDisk'
          instanceName: '*'
          intervalSeconds: 360
          counterName: 'Avg Disk sec/Read'
        }
      }
    ]
  }
}
```

### Example 3 - Log Analytics Workspace with solutions, data sources, delete lock and diagnostic logs enabled
``` bicep
param deploymentName string = concat('logAnalytics', utcNow())

module logAnalytics './main.bicep' = {
  name: deploymentName
  params: {
    name: 'myLogAnalyticsWorkspace'
    sku: 'PerGB2018'
    retentionInDays: 30
    enableDeleteLock: true
    enableDiagnostics: true
    diagnosticStorageAccountName: 'myStorageAccount'
    diagnosticStorageAccountResourceGroup: 'myStorageAccountResourceGroup'    
    solutions: [
      {
        name: 'AzureActivity'
        product: 'OMSGallery/AzureActivity'
        publisher: 'Microsoft'
        promotionCode: ''
      }
    ]
    dataSources: [
      {
        name: 'Application'
        kind: 'WindowsEvent'
        properties: {
          eventLogName: 'Application'
          eventTypes: [
            {
              eventType: 'Error'
            }
            {
              eventType: 'Warning'
            }
          ]
        }
      }
      {
        name: 'LogicalDisk1'
        kind: 'WindowsPerformanceCounter'
        properties: {
          objectName: 'LogicalDisk'
          instanceName: '*'
          intervalSeconds: 360
          counterName: 'Avg Disk sec/Read'
        }
      }
    ]
  }
}
```

TODO: Clean up README

