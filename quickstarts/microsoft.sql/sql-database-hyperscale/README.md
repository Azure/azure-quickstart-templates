# Azure SQL Hyperscale database with Microsoft Entra-only authentication

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-hyperscale/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-hyperscale/PublicDeployment.svg)
![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-hyperscale/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-hyperscale/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-hyperscale/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsql-database-hyperscale%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](https://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsql-database-hyperscale%2Fazuredeploy.json)

The upstream buttons target the published sample on `master`. For Bicep samples, the repository generates `azuredeploy.json` automatically on merge; it is not included in the contribution. Use the local `main.bicep` before publication. Only Azure public cloud (`AzureCloud`) is targeted; no Azure Government deployment is claimed.

## Sample overview and deployed resources

This sample creates:

- A new `Microsoft.Sql/servers` logical server with Microsoft Entra-only authentication, an existing Entra administrator, public network access, and minimum TLS 1.2.
- One `Microsoft.Sql/servers/firewallRules` rule whose start and end are the same explicitly supplied SQL client IPv4 address. It does not enable "Allow Azure services and resources to access this server" or an address range.
- One `Microsoft.Sql/servers/databases` database using paid provisioned Hyperscale standard-series (Gen5), initially 2 vCores (`HS_Gen5_2`), zero high availability (HA) replicas, no zone redundancy, and locally redundant data/backup storage.

No SQL authentication credentials, Azure Hybrid Benefit, named replicas, geo-replicas, elastic pools, private endpoints, or auxiliary billable services are provisioned. The database uses `LicenseIncluded`; no existing SQL Server license entitlement is required.

### Cost and availability

**This is a paid database. Provisioned compute is billed even while the database is idle.** This is not serverless and does not auto-pause. Allocated data storage and applicable backup storage are also billable. Review [SQL Database pricing](https://azure.microsoft.com/pricing/details/azure-sql-database/single/) for your region and subscription before deployment.

Two vCores is the smallest documented standard-series provisioned Hyperscale compute size. Zero HA replicas avoids additional replica compute charges, but failover can take longer and there is no read-only compute offload. This is a cost-focused evaluation configuration, not a zone-resilient production architecture. Microsoft supports zero to four HA replicas; this sample deliberately fixes the count at zero.

`requestedBackupStorageRedundancy: Local` selects supported locally redundant storage rather than geo-redundant storage. For Hyperscale, that selection applies to data as well as backups. It provides no geo-restore capability. Backup storage redundancy cannot be changed in place for an existing Hyperscale database. The default short-term backup retention is seven days; no long-term retention policy is created. Retained backups can still incur charges after database deletion, until their retention expires.

Hyperscale storage grows automatically; this sample does not set `maxSizeBytes` or promise a storage spending cap. A database created directly as Hyperscale cannot use reverse migration to another service tier. Review [Hyperscale limitations](https://learn.microsoft.com/azure/azure-sql/database/service-tier-hyperscale-frequently-asked-questions-faq?view=azuresql) before using it for persistent data.

## Prerequisites

- Azure CLI, PowerShell 7, and Bicep installed locally; an existing authenticated Azure CLI context in the intended AzureCloud subscription. The commands below do not change the active account or cloud.
- Permission to create/delete a dedicated resource group and deploy SQL resources, including the Entra administrator. Ensure `Microsoft.Sql` is already registered and the subscription has sufficient regional vCore quota.
- An existing Microsoft Entra user or group in the subscription tenant. Supply its display name and **object ID**, not an application/client ID. Group administrators are recommended for ongoing access management.
- The **actual public IPv4 egress address of the machine that runs the SQL client**. Behind VPN, NAT, or a proxy this can differ from another terminal or Cloud Shell address. Obtain it from your network administrator; do not use a private address, a CIDR range, or `0.0.0.0` (which has special broad-access semantics in SQL firewall rules). The rule applies at server scope.
- For the SQL query below, Windows with a current ODBC `sqlcmd` supporting `-G -U` Microsoft Entra interactive authentication, ODBC Driver 18, network connectivity to SQL Database, and an administrator user or member of the configured administrator group. Your Azure management-plane login does not itself grant SQL data-plane access. On other operating systems use an Entra-capable SQL client with an appropriate supported authentication method.

Check regional availability without provisioning resources:

```powershell
az sql db list-editions --location eastus --edition Hyperscale --show-details `
  --query "[].supportedServiceLevelObjectives[].{name:name,capacity:sku.capacity,family:sku.family}" --output table
if ($LASTEXITCODE -ne 0) { throw 'Could not list regional Hyperscale service objectives.' }
```

### Parameters

| Name | Default | Description |
| --- | --- | --- |
| `location` | Resource group location | Region supporting the chosen Hyperscale capacity. |
| `serverName` | `sql-` plus `uniqueString(resourceGroup().id)` | Globally unique new logical server name; lowercase letters, digits, and hyphens. |
| `databaseName` | `hyperscaledb` | New database name. |
| `administratorLogin` | Required | Existing Entra administrator display name; not a SQL login. |
| `administratorObjectId` | Required | Administrator object ID in the subscription tenant. |
| `administratorPrincipalType` | `User` | `User` or `Group`. |
| `clientIpAddress` | Required | Single actual public IPv4 address of the SQL client. No broad default. |
| `databaseCapacity` | `2` | Paid provisioned Gen5 vCores. Use a supported regional size between 2 and 80; the interval does not imply every integer is supported. |

The SKU is intentionally fixed to provisioned `HS_Gen5`, tier `Hyperscale`, family `Gen5`; changing `databaseCapacity` changes the paid compute size without introducing serverless or premium hardware. Larger capacity increases charges. The parameter file contains only `GEN-*` test placeholders, not deployable identities or network access settings. In particular, `GEN-CLIENT-IP-ADDRESS` is a manual substitution marker, not an automatic test-harness IP generator. Use the explicit parameters below instead of submitting that file unchanged.

## Deployment, verification, and cleanup

Run from this sample directory. The following PowerShell script prompts for required real values, deploys to a fresh dedicated resource group, captures genuine deployment evidence **before** cleanup, and deletes the group in `finally`, including when deployment or verification fails. It refuses to delete a pre-existing group.

The commands create billable Azure resources **only when you run them**. They have not been executed as part of this sample's local authoring checks.

```powershell
$ErrorActionPreference = 'Stop'
$location = 'eastus' # Confirm Hyperscale availability and quota in your chosen region.
$resourceGroup = "rg-sql-hyperscale-$([guid]::NewGuid().ToString('N').Substring(0, 10))"
$deploymentName = 'sql-hyperscale'
$administratorLogin = Read-Host 'Existing Entra administrator display name'
$administratorObjectId = Read-Host 'Existing Entra administrator object ID (GUID)'
$administratorPrincipalType = Read-Host 'Entra principal type: User or Group'
$clientIpAddress = Read-Host 'Actual public IPv4 egress address of the SQL client'

if ([string]::IsNullOrWhiteSpace($administratorLogin)) { throw 'An Entra administrator name is required.' }
$null = [guid]::Parse($administratorObjectId)
if ($administratorPrincipalType -notin @('User', 'Group')) { throw 'Choose User or Group.' }
$parsedIp = [System.Net.IPAddress]::Parse($clientIpAddress)
if ($parsedIp.AddressFamily -ne [System.Net.Sockets.AddressFamily]::InterNetwork -or
    $clientIpAddress -eq '0.0.0.0' -or
    $parsedIp.ToString() -ne $clientIpAddress) {
    throw 'Supply one actual SQL client public IPv4 address, not a range or 0.0.0.0.'
}

$exists = az group exists --name $resourceGroup --output tsv
if ($LASTEXITCODE -ne 0 -or $exists -ne 'false') { throw 'Cannot use an existing or unverifiable resource group.' }
$cleanupRequired = $false
try {
    $cleanupRequired = $true
    az group create --name $resourceGroup --location $location --output none
    if ($LASTEXITCODE -ne 0) { throw 'Resource group creation failed.' }

    az deployment group create --resource-group $resourceGroup --name $deploymentName `
      --template-file .\main.bicep `
      --parameters administratorLogin="$administratorLogin" `
        administratorObjectId="$administratorObjectId" `
        administratorPrincipalType="$administratorPrincipalType" `
        clientIpAddress="$clientIpAddress" databaseCapacity=2 --output none
    if ($LASTEXITCODE -ne 0) { throw 'Deployment failed.' }

    $deploymentJson = az deployment group show --resource-group $resourceGroup `
      --name $deploymentName --output json
    if ($LASTEXITCODE -ne 0) { throw 'Could not read deployment evidence.' }
    $deployment = $deploymentJson | ConvertFrom-Json
    if ($deployment.properties.provisioningState -ne 'Succeeded') { throw 'Deployment did not succeed.' }
    $fqdn = $deployment.properties.outputs.serverFullyQualifiedDomainName.value
    $database = $deployment.properties.outputs.databaseName.value
    $databaseId = $deployment.properties.outputs.databaseResourceId.value
    $server = $fqdn.Split('.')[0]

    $evidence = @{
        templateFileName = 'main.bicep'
        correlationId = $deployment.properties.correlationId
        deploymentName = $deployment.name
    }
    $evidence | ConvertTo-Json | Set-Content .\deployment-evidence.json
    # Preserve genuine deployment results even if a later SQL connection check fails.
    $evidence | ConvertTo-Json

    az sql server show --resource-group $resourceGroup --name $server `
      --query "{fqdn:fullyQualifiedDomainName,tls:minimalTlsVersion,publicNetworkAccess:publicNetworkAccess}" --output json
    if ($LASTEXITCODE -ne 0) { throw 'Server verification failed.' }
    az sql server ad-only-auth get --resource-group $resourceGroup --name $server --output json
    if ($LASTEXITCODE -ne 0) { throw 'Entra-only verification failed.' }
    az sql server firewall-rule list --resource-group $resourceGroup --server $server --output json
    if ($LASTEXITCODE -ne 0) { throw 'Firewall verification failed.' }
    az sql db show --ids $databaseId `
      --query "{sku:sku,currentObjective:currentServiceObjectiveName,status:status,haReplicas:highAvailabilityReplicaCount,zoneRedundant:zoneRedundant,backupStorage:currentBackupStorageRedundancy,license:licenseType}" --output json
    if ($LASTEXITCODE -ne 0) { throw 'Database verification failed.' }

    # ODBC sqlcmd: interactive Entra sign-in; sign in as the configured admin or a group member.
    $sqlUserPrincipalName = Read-Host 'Entra sign-in user principal name (UPN)'
    sqlcmd -S "tcp:$fqdn,1433" -d $database -G -U $sqlUserPrincipalName -N -b `
      -Q "SELECT DB_NAME() AS database_name, edition, service_objective FROM sys.database_service_objectives WHERE database_id = DB_ID();"
    if ($LASTEXITCODE -ne 0) { throw 'SQL data-plane verification failed.' }
} finally {
    if ($cleanupRequired) {
        az group delete --name $resourceGroup --yes --output none
        if ($LASTEXITCODE -ne 0) { throw "Cleanup failed. Delete $resourceGroup manually to avoid ongoing charges." }
        $remaining = az group exists --name $resourceGroup --output tsv
        if ($LASTEXITCODE -ne 0 -or $remaining -ne 'false') {
            throw "Cleanup not verified. Check resource group $resourceGroup immediately."
        }
        Write-Host "Verified az group exists: $remaining"
    }
}
```

Verify the displayed values: Entra-only authentication `true`; TLS `1.2`; exactly one firewall rule with both endpoints equal to your actual client address; database `Online`; SKU name `HS_Gen5`, tier `Hyperscale`, family `Gen5`, capacity `2`; current objective `HS_Gen5_2`; HA replicas `0`; zone redundancy `false`; backup storage `Local`; license `LicenseIncluded`. The SQL query should return one row with edition `Hyperscale` and service objective `HS_Gen5_2`. Firewall propagation and Entra sign-in can take time; investigate failures rather than treating management-plane success as a successful SQL connection.

To keep a database for application use, adapt the example deliberately and arrange equivalent cleanup. Connect using the output FQDN and database name with Microsoft Entra authentication, encryption enabled, and certificate validation enabled. Create least-privilege contained Entra users for applications; do not use the administrator as the application identity.

### Outputs

| Name | Value |
| --- | --- |
| `serverFullyQualifiedDomainName` | Server FQDN reported by the SQL resource provider. |
| `databaseName` | Deployed database name. |
| `databaseResourceId` | Full database resource ID. |

## Local validation and contribution evidence

Build and lint the source locally:

```powershell
bicep build .\main.bicep --outfile .\azuredeploy.json
bicep lint .\main.bicep
```

The generated JSON is only for local inspection/parity checking; do not include it in a Bicep sample PR. Remove it after validation. Compilation does not prove regional availability, permissions, deployment success, or SQL connectivity.

No Azure deployment evidence is claimed, and `metadata.json` intentionally has no `testResult`. The contribution workflow requires an actual successful deployment before PR submission. After an authorized deployment and verification, add the genuine `deployment-evidence.json` values under `testResult.deployments` in metadata. Keep the evidence file out of the PR. Never invent correlation IDs or successful test results. Deleting the resource group removes its deployment history, so capture evidence first.

## References

- [Hyperscale overview](https://learn.microsoft.com/azure/azure-sql/database/service-tier-hyperscale?view=azuresql)
- [Provisioned standard-series resource limits](https://learn.microsoft.com/azure/azure-sql/database/resource-limits-vcore-single-databases?view=azuresql#hyperscale---provisioned-compute---standard-series-gen5)
- [Hyperscale replicas, including zero HA replicas](https://learn.microsoft.com/azure/azure-sql/database/service-tier-hyperscale-replicas?view=azuresql)
- [Hyperscale automated backups, redundancy, and costs](https://learn.microsoft.com/azure/azure-sql/database/hyperscale-automated-backups-overview?view=azuresql)
- [Microsoft Entra-only authentication](https://learn.microsoft.com/azure/azure-sql/database/authentication-azure-ad-only-authentication?view=azuresql)
- [sqlcmd Microsoft Entra interactive authentication](https://learn.microsoft.com/sql/tools/sqlcmd/sqlcmd-authentication?view=sql-server-ver17)
- [SQL server firewall rules](https://learn.microsoft.com/azure/azure-sql/database/firewall-configure?view=azuresql)
- [SQL logical server ARM reference, 2023-08-01](https://learn.microsoft.com/azure/templates/microsoft.sql/2023-08-01/servers)
- [SQL database ARM reference, 2023-08-01](https://learn.microsoft.com/azure/templates/microsoft.sql/2023-08-01/servers/databases)

`Tags: Azure SQL Database, Hyperscale, Microsoft Entra, Bicep`
