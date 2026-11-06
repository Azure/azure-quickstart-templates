# Azure SQL Database backup retention policies

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-backup-retention/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-backup-retention/PublicDeployment.svg)
![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-backup-retention/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-backup-retention/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-backup-retention/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsql-database-backup-retention%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](https://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsql-database-backup-retention%2Fazuredeploy.json)

This sample configures [short-term](https://learn.microsoft.com/azure/azure-sql/database/automated-backups-overview) and [long-term backup retention](https://learn.microsoft.com/azure/azure-sql/database/long-term-retention-overview) for a **paid** Azure SQL database. It creates policies, not an immediately available long-term backup. Scheduled full backups become eligible for long-term retention over time.

## Deployed resources

- **Microsoft.Sql/servers**: Entra-only administration and minimum TLS 1.2.
- **Microsoft.Sql/servers/firewallRules**: Access for one required SQL client IPv4 address.
- **Microsoft.Sql/servers/databases**: Standard S0 by default, using local backup redundancy.
- **Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies**: Seven-day point-in-time restore retention by default.
- **Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies**: Weekly backups retained for one week, monthly backups for one month, and yearly backups for one year by default.

The source is [main.bicep](main.bicep). The repository generates the portal's `azuredeploy.json` on merge. [azuredeploy.parameters.json](azuredeploy.parameters.json) contains repository `GEN-UNIQUE` test data, not a deployable identity configuration.

## Prerequisites

Use Azure public cloud, an existing Entra user/group/service principal in the subscription tenant, and permission to deploy SQL resources. For an application administrator, supply its service principal object ID. Supply the actual SQL client's public IPv4 address, never `0.0.0.0`. The sample does not create application users.

The database and backup storage are billable. Long-term backups can survive database, server, and resource group deletion and continue accruing storage charges. Disabling a retention policy does not delete existing long-term backups.

## Deploy and verify

From this directory, sign in with Azure CLI and use Bicep. Replace the required values. Only use a new, dedicated test group.

```powershell
$ErrorActionPreference = 'Stop'
$subscriptionId = '<subscription-id>'
$resourceGroupName = 'rg-sql-retention-test'
$location = 'centralus'
$administratorLogin = '<existing-entra-display-name>'
$administratorObjectId = '<existing-entra-object-id>'
$clientIpAddress = '<sql-client-public-ipv4>'
if ((az group exists --subscription $subscriptionId -n $resourceGroupName) -ne 'false') {
  throw 'Choose a new test resource group.'
}
$serverName = $null
$databaseName = $null
try {
  az group create --subscription $subscriptionId -n $resourceGroupName -l $location
  if ($LASTEXITCODE) { throw 'Resource group creation failed.' }
  $arguments = @('--subscription', $subscriptionId, '-g', $resourceGroupName,
    '-n', 'retention-test', '--template-file', '.\main.bicep', '--parameters',
    "administratorLogin=$administratorLogin", "administratorObjectId=$administratorObjectId",
    "clientIpAddress=$clientIpAddress")
  az deployment group what-if @arguments
  if ($LASTEXITCODE) { throw 'Deployment preview failed.' }
  $deployment = az deployment group create @arguments -o json | ConvertFrom-Json
  if ($LASTEXITCODE -or $deployment.properties.provisioningState -ne 'Succeeded') {
    throw 'Deployment failed.'
  }
  $serverName = $deployment.properties.outputs.serverName.value
  $databaseName = $deployment.properties.outputs.databaseName.value
  az sql db str-policy show --subscription $subscriptionId -g $resourceGroupName -s $serverName -n $databaseName
  if ($LASTEXITCODE) { throw 'Short-term retention verification failed.' }
  az sql db ltr-policy show --subscription $subscriptionId -g $resourceGroupName -s $serverName -n $databaseName
  if ($LASTEXITCODE) { throw 'Long-term retention verification failed.' }
  $deployment | Select-Object name, @{n='correlationId';e={$_.properties.correlationId}},
    @{n='templateHash';e={$_.properties.templateHash}}
  # Perform the optional restore exercise below here, before cleanup.
} finally {
  try {
    # A short test might have no LTR backups. Check rather than assuming.
    if ($serverName -and $databaseName) {
      $backups = az sql db ltr-backup list --subscription $subscriptionId --location $location `
        --server $serverName --database $databaseName -o json | ConvertFrom-Json
      if ($LASTEXITCODE) { throw 'LTR backup inventory failed; check for retained backup charges.' }
      foreach ($backup in $backups) {
        az sql db ltr-backup delete --subscription $subscriptionId --location $location `
          --server $serverName --database $databaseName --name $backup.name --yes
        if ($LASTEXITCODE) { throw 'LTR backup removal failed; check for retained backup charges.' }
      }
    }
  } finally {
    az group delete --subscription $subscriptionId -n $resourceGroupName --yes
    if ($LASTEXITCODE) { throw 'Cleanup failed; remove the test group to stop charges.' }
    $exists = az group exists --subscription $subscriptionId -n $resourceGroupName
    if ($LASTEXITCODE -or $exists -ne 'false') { throw 'Test group deletion is not confirmed.' }
  }
}
```

Capture genuine deployment evidence in [metadata.json](metadata.json) before deleting the test group, using `templateFileName: main.bicep`, per the [contribution guide](../../../1-CONTRIBUTION-GUIDE/README.md#testresult). Deployment success verifies the policies, not a completed recovery exercise or availability of future LTR backups.

### Point-in-time restore exercise

Run this inside the `try` block above. First connect with Entra authentication and create test data in the source database. Allow time for the first automated backup and a restorable point; newly created databases are not immediately restorable.

```powershell
$source = az sql db show --subscription $subscriptionId -g $resourceGroupName `
  -s $serverName -n $databaseName -o json | ConvertFrom-Json
if ($LASTEXITCODE -or -not $source.earliestRestoreDate) { throw 'No restore point is available yet.' }
$restoreTime = [DateTime]::UtcNow.AddMinutes(-5).ToString('o')
if ([DateTime]$source.earliestRestoreDate -gt [DateTime]$restoreTime) {
  throw 'Wait until the selected point is within the available restore window.'
}
az sql db restore --subscription $subscriptionId -g $resourceGroupName -s $serverName `
  -n $databaseName --dest-name "$databaseName-restored" --time $restoreTime
if ($LASTEXITCODE) { throw 'Point-in-time restore failed.' }
```

Connect to the restored database with Entra authentication and verify the test data. The restore creates a separate **billable database**, not an in-place rollback. Both databases are removed by deleting the dedicated test group. Actual LTR restore requires a retained backup; see the linked Microsoft Learn guide rather than treating a policy as a backup.

`Tags: Azure SQL Database, backup, retention, restore, Bicep, Microsoft.Sql/servers, Microsoft.Sql/servers/databases`
