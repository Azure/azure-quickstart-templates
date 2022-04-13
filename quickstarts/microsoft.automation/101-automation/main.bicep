@description('Workspace name')
param workspaceName string

@description('Pricing tier: perGB2018 or legacy tiers (Free, Standalone, PerNode, Standard or Premium), which are not available to all customers.')
@allowed([
  'CapacityReservation'
  'Free'
  'LACluster'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
param sku string = 'PerGB2018'

@description('Number of days to retain data.')
@minValue(7)
@maxValue(730)
param dataRetention int = 30

@description('Specifies the location in which to create the workspace.')
param location string = resourceGroup().location

@description('Automation account name')
param automationAccountName string
param sampleGraphicalRunbookName string = 'AzureAutomationTutorial'
param sampleGraphicalRunbookDescription string = 'An example runbook that gets all the Resource Manager resources by using the Run As account (service principal).'
param samplePowerShellRunbookName string = 'AzureAutomationTutorialScript'
param samplePowerShellRunbookDescription string = 'An example runbook that gets all the Resource Manager resources by using the Run As account (service principal).'
param samplePython2RunbookName string = 'AzureAutomationTutorialPython2'
param samplePython2RunbookDescription string = 'An example runbook that gets all the Resource Manager resources by using the Run As account (service principal).'

@description('URI to artifacts location')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated')
@secure()
param _artifactsLocationSasToken string = ''

resource workspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: dataRetention
    features: {
      searchVersion: 1
      legacy: 0
    }
  }
}

resource automationAccount 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: automationAccountName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Basic'
    }
  }
}

resource runbook1 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = {
  parent: automationAccount
  name: sampleGraphicalRunbookName
  location: location
  properties: {
    runbookType: 'GraphPowerShell'
    logProgress: false
    logVerbose: false
    description: sampleGraphicalRunbookDescription
    publishContentLink: {
      uri: uri(_artifactsLocation, 'scripts/AzureAutomationTutorial.graphrunbook${_artifactsLocationSasToken}')
      version: '1.0.0.0'
    }
  }
}

resource runbook2 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = {
  parent: automationAccount
  name: samplePowerShellRunbookName
  location: location
  properties: {
    runbookType: 'PowerShell'
    logProgress: false
    logVerbose: false
    description: samplePowerShellRunbookDescription
    publishContentLink: {
      uri: uri(_artifactsLocation, 'scripts/AzureAutomationTutorial.ps1${_artifactsLocationSasToken}')
      version: '1.0.0.0'
    }
  }
}

resource runbook3 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = {
  parent: automationAccount
  name: samplePython2RunbookName
  location: location
  properties: {
    runbookType: 'Script'
    logProgress: false
    logVerbose: false
    description: samplePython2RunbookDescription
    publishContentLink: {
      uri: uri(_artifactsLocation, 'scripts/AzureAutomationTutorialPython2.py${_artifactsLocationSasToken}')
      version: '1.0.0.0'
    }
  }
}

resource linkedService 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = {
  parent: workspace
  name: 'Automation'
  properties: {
    resourceId: automationAccount.id
  }
}
