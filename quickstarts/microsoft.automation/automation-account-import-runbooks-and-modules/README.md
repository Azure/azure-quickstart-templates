# Automation Account
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
