# Azure SQL Database free tier

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-free-tier/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-free-tier/PublicDeployment.svg)
![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-free-tier/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-free-tier/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-free-tier/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsql-database-free-tier%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](https://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsql-database-free-tier%2Fazuredeploy.json)

This template deploys a new [Azure SQL Database using the free tier](https://learn.microsoft.com/azure/azure-sql/database/free-tier). Each database receives 100,000 vCore seconds, 32 GB of data storage, and 32 GB of backup storage per month for the lifetime of the subscription. A subscription can have up to 10 free tier databases.

The database uses `useFreeLimit: true` and `freeLimitExhaustionBehavior: 'AutoPause'`. When the monthly allowance is exhausted, the database becomes inaccessible until the start of the next calendar month rather than continuing with paid overages. This template does not expose a paid-overage option.

## Sample overview and deployed resources

The Bicep source is [main.bicep](main.bicep); [azuredeploy.json](azuredeploy.json) is generated from it for portal deployment.

- **Microsoft.Sql/servers**: A logical server with Microsoft Entra-only authentication and a minimum TLS version of 1.2. No SQL administrator password is created.
- **Microsoft.Sql/servers/firewallRules**: A rule allowing only the supplied client IPv4 address. The template does not enable access from all Azure services or an unrestricted IP range.
- **Microsoft.Sql/servers/databases**: A General Purpose serverless Gen5 database with a maximum of 2 vCores, a minimum of 0.5 vCores, 32 GB maximum data size, locally redundant backups, and the free tier enabled. The service controls the free tier's inactivity auto-pause delay.

## Prerequisites

- An Azure public-cloud subscription eligible for the free tier, with an available free database slot. Microsoft Azure for Students Starter is not supported.
- An existing resource group in a supported Azure SQL region. If the subscription already has free tier databases, use their region.
- Permission to create the SQL server, configure its Microsoft Entra administrator, and create its database and firewall rule.
- An existing Microsoft Entra user, group, or application in the subscription tenant. Supply its display name and **object ID**. For an application, supply the service principal object ID rather than the application (client) ID, and select `Application` as the principal type.
- The public IPv4 address of the client that will connect to SQL. Do not supply `0.0.0.0`: Azure SQL treats that value as allowing Azure services, not as a single client.
- For command-line deployment, Azure PowerShell with Bicep available.

## Deployment steps

Use the **Deploy to Azure** button above and supply the administrator and client address, or deploy locally using Azure PowerShell from this sample directory:

```powershell
Connect-AzAccount
Set-AzContext -SubscriptionId '<subscription-id>'

$resourceGroupName = '<existing-resource-group>'
$administratorLogin = '<entra-administrator-display-name>'
$administratorObjectId = '<entra-administrator-object-id>'
$clientIpAddress = '<client-public-ipv4-address>'

$deployment = New-AzResourceGroupDeployment `
  -Name 'sql-free-tier' `
  -ResourceGroupName $resourceGroupName `
  -TemplateFile .\main.bicep `
  -administratorLogin $administratorLogin `
  -administratorObjectId $administratorObjectId `
  -administratorPrincipalType 'User' `
  -clientIpAddress $clientIpAddress

$deployment.Outputs
```

The location defaults to the resource group's location. Override `-location` when necessary. Use `Group` or `Application` instead of `User` when appropriate.

[azuredeploy.parameters.json](azuredeploy.parameters.json) contains only a repository test-generation placeholder for the server name. It is not a ready-to-deploy user parameters file: `GEN-UNIQUE` must be generated by test tooling or replaced with a globally unique name. Pass the required existing administrator and client IP values separately, as above; no identity or client address is fabricated by the template.

## Usage

### Connect

Use the `serverFullyQualifiedDomainName` and `databaseName` deployment outputs to connect from the allowed client, for example with SQL Server Management Studio using **Microsoft Entra MFA** for an interactive user. SQL authentication is disabled. A newly resumed serverless database can take time to become available; retry the connection after it resumes.

If a proxy or runner uses different outbound addresses for HTTPS and SQL, use the client IP reported in the SQL firewall error rather than an HTTP IP lookup. A runner with rotating outbound addresses might not be able to connect through this single-address firewall rule; use a client with a stable SQL egress address instead of broadening the rule.

The configured administrator has administrative privileges. Applications should use separately provisioned, least-privilege database users rather than the administrator. This sample does not create application users or grant application permissions.

### Verify the free tier

In the Azure portal, open the deployed SQL database and confirm that the free tier is enabled and **Free limit reached behavior** is **Auto-pause the database until next month**. Monitor the **Free amount remaining** metric. A paused database is expected after inactivity or exhaustion of the monthly allowance.

For an API-level check, inspect the database resource in Azure Resource Explorer using API version `2023-08-01` and verify:

- `properties.useFreeLimit` is `true`.
- `properties.freeLimitExhaustionBehavior` is `AutoPause`.
- `properties.maxSizeBytes` is `34359738368`.
- `properties.requestedBackupStorageRedundancy` is `Local`.

### Contributor deployment evidence

Before submitting a pull request, deploy the exact final template successfully and add genuine deployment evidence to [metadata.json](metadata.json), following the [contribution guide](../../../1-CONTRIBUTION-GUIDE/README.md#testresult):

```powershell
$deployment | Select-Object DeploymentName, CorrelationId, ProvisioningState
```

Record `templateFileName` as the deployed template (`main.bicep` or `azuredeploy.json`), `correlationId` as the returned correlation ID, and `deploymentName` as the returned deployment name in `testResult.deployments`. Do not insert placeholder deployment IDs. Local compilation does not replace the required live deployment, and repository contribution validation will fail until this evidence is supplied.

## Notes

- The free tier is intended primarily for development and proof-of-concept workloads and has no SLA.
- The inactivity auto-pause delay is service-controlled for the free tier. The template intentionally omits `autoPauseDelay`: explicitly setting a non-default delay can cause deployment to fail with `ProvisioningDisabled`. Disconnect clients, including Object Explorer, when finished to avoid preventing auto-pause and consuming the allowance.
- Only new databases are eligible; the template does not restore, copy, or convert an existing database.
- Do not change the exhaustion behavior to `BillOverUsage` unless you intend to incur charges. That change cannot be reversed to the free-limit auto-pause behavior.
- No paid monitoring, private endpoints, long-term retention, or other billable resources are added by this sample. Review the [free tier FAQ](https://learn.microsoft.com/azure/azure-sql/database/free-tier-faq) for current eligibility and limitations.
- Only Azure public cloud is declared supported by this sample.

`Tags: Azure SQL Database, free tier, serverless, Microsoft.Sql/servers, Microsoft.Sql/servers/databases, Microsoft.Sql/servers/firewallRules, Bicep, Microsoft Entra`
