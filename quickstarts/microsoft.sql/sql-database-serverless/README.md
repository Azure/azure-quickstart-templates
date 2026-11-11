# Azure SQL Database with paid serverless compute

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-serverless/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-serverless/PublicDeployment.svg)
![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-serverless/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-serverless/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-serverless/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsql-database-serverless%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](https://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsql-database-serverless%2Fazuredeploy.json)

This sample deploys a **paid** [General Purpose serverless SQL database](https://learn.microsoft.com/azure/azure-sql/database/serverless-tier-overview). It is not the free offer. Compute automatically scales within configured bounds and pauses after inactivity; storage remains billable while paused. Disconnect query tools when finished because open connections can prevent auto-pause.

## Deployed resources

- **Microsoft.Sql/servers**: Microsoft Entra-only administration and TLS 1.2 minimum.
- **Microsoft.Sql/servers/firewallRules**: One explicitly supplied client IPv4 address.
- **Microsoft.Sql/servers/databases**: General Purpose Gen5 serverless, 0.5-2 vCores, 32 GiB maximum data size, local backups, and 60-minute inactivity pause by default.

The Bicep source is [main.bicep](main.bicep). The repository generates the portal's `azuredeploy.json` on merge; generated JSON is not committed with this sample.

## Prerequisites

Use an Azure public-cloud subscription with permission to deploy SQL resources and a region supporting the selected serverless configuration. Supply an existing Entra administrator's display name, object ID, and principal type in the subscription tenant. For applications, use the service principal object ID, not the application ID. Supply the actual SQL client's public IPv4 address, not `0.0.0.0`.

[azuredeploy.parameters.json](azuredeploy.parameters.json) contains a `GEN-UNIQUE` repository test placeholder, not a ready-to-deploy parameters file. The commands below use the template defaults for names and pass the required existing identity and client address explicitly.

## Deploy, verify, and clean up

Run from this sample directory with Azure CLI signed in and Bicep available. Replace the three required values below. Use a **new, dedicated test resource group**. The `finally` block deletes that group even if verification fails; never substitute a group containing resources you want to keep.

```powershell
$ErrorActionPreference = 'Stop'
$subscriptionId = '<subscription-id>'
$resourceGroupName = 'rg-sql-serverless-test'
$administratorLogin = '<existing-entra-display-name>'
$administratorObjectId = '<existing-entra-object-id>'
$clientIpAddress = '<sql-client-public-ipv4>'
if ((az group exists --subscription $subscriptionId -n $resourceGroupName) -ne 'false') {
  throw 'Choose a new test resource group.'
}
try {
  az group create --subscription $subscriptionId -n $resourceGroupName -l centralus
  if ($LASTEXITCODE) { throw 'Resource group creation failed.' }
  $arguments = @('--subscription', $subscriptionId, '-g', $resourceGroupName,
    '-n', 'serverless-test', '--template-file', '.\main.bicep', '--parameters',
    "administratorLogin=$administratorLogin", "administratorObjectId=$administratorObjectId",
    "clientIpAddress=$clientIpAddress")
  az deployment group what-if @arguments
  if ($LASTEXITCODE) { throw 'Deployment preview failed.' }
  $deployment = az deployment group create @arguments -o json | ConvertFrom-Json
  if ($LASTEXITCODE -or $deployment.properties.provisioningState -ne 'Succeeded') {
    throw 'Deployment failed.'
  }
  $databaseId = $deployment.properties.outputs.databaseResourceId.value
  az resource show --ids $databaseId --api-version 2023-08-01
  if ($LASTEXITCODE) { throw 'Database verification failed.' }
  $deployment | Select-Object name, @{n='correlationId';e={$_.properties.correlationId}},
    @{n='templateHash';e={$_.properties.templateHash}}
  # Capture deployment evidence before deleting the test resource group.
} finally {
  az group delete --subscription $subscriptionId -n $resourceGroupName --yes
  if ($LASTEXITCODE) { throw 'Cleanup failed; remove the test group to stop charges.' }
  $exists = az group exists --subscription $subscriptionId -n $resourceGroupName
  if ($LASTEXITCODE -or $exists -ne 'false') { throw 'Test resource group deletion is not confirmed.' }
}
```

Verify `sku.name` is `GP_S_Gen5`, `properties.useFreeLimit` is `false`, and the configured compute bounds and `autoPauseDelay` match your inputs. Connect with Microsoft Entra authentication to the FQDN and database in the deployment outputs. SQL authentication is disabled. A paused database can take time to resume.

The `maxVcores`, `minVcores`, `maxSizeGB`, and `autoPauseDelay` parameters control cost and availability. Regional availability and valid capacity combinations are enforced by Azure SQL. This example deliberately does not offer disabling inactivity pause.

Before a PR, record real successful deployment results in [metadata.json](metadata.json) using `templateFileName: main.bicep`, as described in the [contribution guide](../../../1-CONTRIBUTION-GUIDE/README.md#testresult).

`Tags: Azure SQL Database, serverless, Bicep, Microsoft.Sql/servers, Microsoft.Sql/servers/databases, Microsoft.Sql/servers/firewallRules`
