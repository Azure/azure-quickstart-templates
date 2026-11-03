# Azure SQL Hyperscale database with a named replica

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-hyperscale-named-replica/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-hyperscale-named-replica/PublicDeployment.svg)
![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-hyperscale-named-replica/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-hyperscale-named-replica/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sql-database-hyperscale-named-replica/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsql-database-hyperscale-named-replica%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](https://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsql-database-hyperscale-named-replica%2Fazuredeploy.json)

This template deploys a **writable Azure SQL Hyperscale primary database and a read-only named replica** with independent provisioned compute. Both default to the minimum standard-series (Gen5) size of 2 vCores. This sample targets Azure public cloud.

The portal and visualization links target the upstream ARM template, which is **generated from `main.bicep` on merge**. Generated `azuredeploy.json` is not committed with this Bicep sample; use the local Bicep source before publication.

## Resources and behavior

- One `Microsoft.Sql/servers` logical server with Microsoft Entra-only authentication, TLS 1.2 minimum, and no SQL username/password.
- One `Microsoft.Sql/servers/firewallRules` rule whose start and end are the same trusted client public IPv4 address. There is no allow-all or Azure-services rule. Never pass `0.0.0.0`.
- Two distinct `Microsoft.Sql/servers/databases` resources on that server in the same region: the writable primary and `<databaseName>-reporting`. Each has its own Hyperscale SKU and **zero additional high-availability replicas**, reducing demo cost at the expense of compute failover readiness.

The named replica uses `createMode: Secondary`, `secondaryType: Named`, and `sourceDatabaseId` referencing the primary. [Named replicas on the same logical server are supported](https://learn.microsoft.com/azure/azure-sql/database/hyperscale-named-replica-configure); the replica shares underlying page servers rather than copying all data.

**Both the primary and the named replica incur compute charges**, even when idle. Storage and backup charges also apply; shared data storage does not make the replica's compute free. This is provisioned compute, not a free-offer or auto-pausing database. See [Hyperscale pricing](https://azure.microsoft.com/pricing/details/azure-sql-database/single/).

The named replica is read-only and can lag the primary. It has a **separate database endpoint/connection target**: the same server FQDN but a different initial catalog/database name. `ApplicationIntent=ReadOnly` against the primary database does **not** select this named replica. A named replica is **not an automatic failover substitute**, geo-replica, failover group, or disaster-recovery solution. See [Hyperscale replicas](https://learn.microsoft.com/azure/azure-sql/database/service-tier-hyperscale-replicas).

## Prerequisites and parameters

Use an Azure subscription with permission to deploy SQL resources and enable Entra-only authentication, an available Hyperscale Gen5 region/quota, Azure CLI, Bicep CLI, and an Entra-capable SQL client for optional data-plane verification.

The administrator must already exist **in the subscription's Microsoft Entra tenant**. Supply the directory **object ID**, not a client/application ID. For guests, use the guest object's ID in this tenant. This template does not create directory principals or grant an application database permissions. Use a least-privilege database identity rather than the administrator for real application workloads.

| Parameter | Required | Default / meaning |
| --- | --- | --- |
| `administratorLogin` | Yes | Existing principal's display name or user principal name |
| `administratorObjectId` | Yes | Existing principal's object ID in the subscription tenant |
| `clientIpAddress` | Yes | One trusted public IPv4 address; not `0.0.0.0` |
| `administratorPrincipalType` | No | `User`; also supports `Group` and `Application` |
| `location` | No | Resource group's region |
| `sqlServerName` | No | Globally unique generated logical server name |
| `databaseName` | No | `hyperscale`; replica is always suffixed `-reporting` |
| `primaryVcores` | No | `2`; supported provisioned Hyperscale Gen5 size, minimum 2 |
| `namedReplicaVcores` | No | `2`; independently chosen supported Gen5 size, minimum 2 |

The service validates server/database naming, IPv4 syntax, principal GUIDs, and regional SKU availability. A minimum of 2 does not make every integer a valid compute size; consult [Hyperscale resource limits](https://learn.microsoft.com/azure/azure-sql/database/resource-limits-vcore-single-databases#hyperscale---provisioned-compute---standard-series-gen5). The test parameter file contains only a repository `GEN-UNIQUE` placeholder; supply real required inputs at deployment time. It is not a ready-to-run user parameter file.

## Build and lint

From this directory, using Bicep CLI on your PATH:

```powershell
bicep build .\main.bicep --outfile .\azuredeploy.json
bicep lint .\main.bicep
Remove-Item .\azuredeploy.json
```

Do not include the generated JSON in a Bicep contribution.

## Deploy, verify, capture evidence, and always clean up

The following **PowerShell** example is intentionally short-lived: it creates a new dedicated test resource group and deletes it in `finally`, including after deployment or verification failure. Do not use an existing/shared group. Sign in to the intended subscription first; do not change a shared CLI authentication context during concurrent tests.

Set the three required values below before running. For a group or application administrator, also change the principal type. Only deployment management requires Azure RBAC; SQL connections require the configured administrator identity (or a separately authorized database identity).

```powershell
$ErrorActionPreference = 'Stop'
$location = 'eastus' # Choose a region with Hyperscale Gen5 capacity.
$administratorLogin = '<existing-principal-name>'
$administratorObjectId = '<object-id-in-subscription-tenant>'
$clientIpAddress = '<your-trusted-public-ipv4>'
$administratorPrincipalType = 'User'
$resourceGroup = 'rg-hs-named-' + [guid]::NewGuid().ToString('N').Substring(0, 12)
$deploymentName = 'hyperscale-named-replica'
$created = $false

function Assert-AzSuccess {
    if ($LASTEXITCODE -ne 0) { throw 'Azure CLI command failed.' }
}

try {
    az group create --name $resourceGroup --location $location --output none
    Assert-AzSuccess
    $created = $true

    $deploymentJson = az deployment group create --resource-group $resourceGroup `
        --name $deploymentName --template-file .\main.bicep `
        --parameters administratorLogin=$administratorLogin `
            administratorObjectId=$administratorObjectId `
            administratorPrincipalType=$administratorPrincipalType clientIpAddress=$clientIpAddress `
        --output json
    Assert-AzSuccess
    $deployment = $deploymentJson | ConvertFrom-Json
    if ($deployment.properties.provisioningState -ne 'Succeeded') { throw 'Deployment did not succeed.' }
    $outputs = $deployment.properties.outputs
    $serverName = $outputs.sqlServerName.value

    foreach ($dbName in @($outputs.primaryDatabaseName.value, $outputs.namedReplicaDatabaseName.value)) {
        az sql db show --resource-group $resourceGroup --server $serverName --name $dbName `
            --query '{name:name,status:status,sku:sku,currentSku:currentSku,secondaryType:secondaryType,sourceDatabaseId:sourceDatabaseId,ha:highAvailabilityReplicaCount}' --output json
        Assert-AzSuccess
    }

    # Capture these real values in your review evidence BEFORE the group is deleted.
    [pscustomobject]@{
        templateFileName = 'main.bicep'
        correlationId = $deployment.properties.correlationId
        deploymentName = $deployment.name
    } | ConvertTo-Json
    $outputs | ConvertTo-Json -Depth 10
    # Run the read-only SQL checks below here, before leaving this try block.
    # Record actual successful evidence in metadata.json testResult.deployments before submitting a PR.
}
finally {
    # Also handle a group create that succeeded remotely but returned a client-side error.
    $exists = az group exists --name $resourceGroup --output tsv
    Assert-AzSuccess
    if ($created -or $exists -eq 'true') {
        az group delete --name $resourceGroup --yes --output none
        Assert-AzSuccess
    }
    $exists = az group exists --name $resourceGroup --output tsv
    Assert-AzSuccess
    if ($exists -ne 'false') { throw "Cleanup failed: resource group $resourceGroup still exists." }
    Write-Host "Verified resource group $resourceGroup is absent."
}
```

Never fabricate `testResult` values. If deploying fails, inspect the error and retain failure evidence, but still let `finally` remove the dedicated group. Deleting the group removes both billable databases and the logical server.

### Read-only SQL verification

Before cleanup, connect with Microsoft Entra authentication using the configured principal and the output `sqlServerFullyQualifiedDomainName`. Use encryption and certificate validation (`Encrypt=True;TrustServerCertificate=False`). The firewall must allow the client's egress IPv4 address; your network must also allow Azure SQL connectivity.

Open **two separate connections**: one with initial catalog `primaryDatabaseName`, the other with `namedReplicaDatabaseName`. Do not use `USE` to switch databases in Azure SQL Database. Execute this read-only query on each:

```sql
SELECT DB_NAME() AS database_name,
       DATABASEPROPERTYEX(DB_NAME(), 'Updateability') AS updateability,
       SERVERPROPERTY('EngineEdition') AS engine_edition;

SELECT edition, service_objective
FROM sys.database_service_objectives
WHERE database_id = DB_ID();
```

Expect the primary to report `READ_WRITE`, the named replica `READ_ONLY`, engine edition `5`, and `Hyperscale` with the independently requested `HS_Gen5_<vCores>` service objective. No user tables or test data are provisioned; no writes are needed for these checks.

`Tags: Azure SQL Database, Hyperscale, named replica, read scale-out, Microsoft Entra, Microsoft.Sql/servers, Microsoft.Sql/servers/databases`
