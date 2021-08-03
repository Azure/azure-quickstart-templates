# Automation Account

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.automation/automation-account-import-runbooks-and-modules/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.automation/automation-account-import-runbooks-and-modules/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.automation/automation-account-import-runbooks-and-modules/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.automation/automation-account-import-runbooks-and-modules/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.automation/automation-account-import-runbooks-and-modules/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.automation/automation-account-import-runbooks-and-modules/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.automation/automation-account-import-runbooks-and-modules/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.automation%2Fautomation-account-import-runbooks-and-modules%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.automation%2Fautomation-account-import-runbooks-and-modules%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.automation%2Fautomation-account-import-runbooks-and-modules%2Fazuredeploy.json)

This module will create an automation account with a system assigned managed identity and import modules and runbooks.

You can also optionally enable diagnostics logs and a delete lock.

## Usage

### Example 1 - Automation account with no modules or runbooks imported
``` bicep
param deploymentName string = 'automationAccount${utcNow()}'

module automationAccount './main.bicep' = {
  name: deploymentName  
  params: {
    name: 'MyAutomationAccount'
  }
}
```

### Example 2 - Automation account with modules imported
``` bicep
param deploymentName string = 'automationAccount${utcNow()}'

module automationAccount './main.bicep' = {
  name: deploymentName  
  params: {
    name: 'MyAutomationAccount'
    modules: [
      {
        name: 'Az.Accounts'
        version: 'latest'
        uri: 'https://www.powershellgallery.com/api/v2/package'
      }
    ]    
  }
}
```

### Example 3 - Automation account with modules and runbook imported
``` bicep
param deploymentName string = 'automationAccount${utcNow()}'

module automationAccount './main.bicep' = {
  name: deploymentName  
  params: {
    name: 'MyAutomationAccount'
    modules: [
      {
        name: 'Az.Accounts'
        version: 'latest'
        uri: 'https://www.powershellgallery.com/api/v2/package'
      }
    ]
    runbooks: [
      {
        runbookName: 'MyRunbook'
        runbookUri: 'https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/<some-repo>/scripts/<some-script>.ps1'
        runbookType: 'PowerShell'
        logProgress: true
        logVerbose: false
      }
    ]        
  }
}
```

### Example 4 - Automation account with diagnostic logs and delete lock enabled
``` bicep
param deploymentName string = 'automationAccount${utcNow()}'

module automationAccount './main.bicep' = {
  name: deploymentName  
  params: {
    name: 'MyAutomationAccount'
    enableDiagnostics: true
    enableDeleteLock: true
    diagnosticStorageAccountName: 'MyDiagnosticStorageAccount'
    diagnosticStorageAccountResourceGroup: 'MyDiagnosticStorageResourceGroup'
    logAnalyticsResourceGroup: 'MyLogAnalyticsResourceGroup'
    logAnalyticsWorkspaceName: 'MyLogAnalyticsWorkspace'    
  }
}
```

TODO: Clean up README

