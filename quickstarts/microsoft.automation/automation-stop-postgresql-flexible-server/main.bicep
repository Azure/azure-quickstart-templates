targetScope = 'resourceGroup'

@description('Name for the Azure Automation Account to create.')
param automationAccountName string = 'aa${uniqueString(resourceGroup().id)}'

@description('Azure region for the Automation Account.')
param location string = resourceGroup().location

@description('Resource group containing the existing target PostgreSQL Flexible Server.')
param postgresResourceGroupName string = resourceGroup().name

@description('Name of the existing Azure Database for PostgreSQL Flexible Server to stop.')
param postgresServerName string

@description('Subscription containing the target server.')
param postgresSubscriptionId string = subscription().subscriptionId

@description('UTC ISO 8601 timestamp for the first execution. The default schedules the first run one day after deployment.')
param scheduleStartTime string = dateTimeAdd(utcNow('u'), 'P1D')

@description('Run the stop check every N days.')
@minValue(1)
param scheduleInterval int = 1

@description('URI of the published runbook script. When deployed from Azure Quickstart Templates, the default resolves to the script stored beside this template. Set this only when deploying the template from a local file.')
param runbookContentUri string = uri(deployment().properties.templateLink.uri, 'scripts/Stop-PostgreSqlFlexibleServer.ps1')

@description('Optional content version shown by Azure Automation. Change when the script changes.')
param runbookContentVersion string = '1.0.0'

@description('Creates a Contributor assignment scoped only to the target server for the Automation managed identity. The deploying principal needs permission to create role assignments.')
param assignServerContributorRole bool = true

var runbookName = 'Stop-PostgreSqlFlexibleServer'
var scheduleName = 'stop-postgresql-daily'

resource automationAccount 'Microsoft.Automation/automationAccounts@2023-11-01' = {
  name: automationAccountName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Basic'
    }
    publicNetworkAccess: true
  }
}

resource azAccountsModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  parent: automationAccount
  name: 'Az.Accounts'
  location: location
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/Az.Accounts'
    }
  }
}

resource azPostgreSqlModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  parent: automationAccount
  name: 'Az.PostgreSql'
  location: location
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/Az.PostgreSql'
    }
  }
  dependsOn: [
    azAccountsModule
  ]
}

resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2023-11-01' = {
  parent: automationAccount
  name: runbookName
  location: location
  properties: {
    runbookType: 'PowerShell72'
    logVerbose: true
    logProgress: true
    publishContentLink: {
      uri: runbookContentUri
      version: runbookContentVersion
    }
  }
  dependsOn: [
    azPostgreSqlModule
  ]
}

resource schedule 'Microsoft.Automation/automationAccounts/schedules@2023-11-01' = {
  parent: automationAccount
  name: scheduleName
  properties: {
    startTime: scheduleStartTime
    frequency: 'Day'
    interval: scheduleInterval
    timeZone: 'UTC'
  }
}

resource jobSchedule 'Microsoft.Automation/automationAccounts/jobSchedules@2023-11-01' = {
  parent: automationAccount
  name: guid(automationAccount.id, runbookName, scheduleName)
  properties: {
    runbook: {
      name: runbookName
    }
    schedule: {
      name: scheduleName
    }
    parameters: {
      SubscriptionId: postgresSubscriptionId
      ResourceGroupName: postgresResourceGroupName
      ServerName: postgresServerName
    }
  }
  dependsOn: [
    runbook
    schedule
  ]
}

module serverRoleAssignment 'modules/server-role-assignment.bicep' = if (assignServerContributorRole) {
  name: 'assign-postgresql-server-contributor'
  scope: resourceGroup(postgresSubscriptionId, postgresResourceGroupName)
  params: {
    postgresServerName: postgresServerName
    principalId: automationAccount.identity.principalId
    automationAccountResourceId: automationAccount.id
  }
}

output automationAccountResourceId string = automationAccount.id
output runbookResourceId string = runbook.id
output managedIdentityPrincipalId string = automationAccount.identity.principalId

