---
description: Deploy an Azure SQL Managed Instance using the Freemium offer with a dedicated virtual network, Entra-only authentication, restricted public access, and a weekday schedule.
page_type: sample
products:
- azure
- azure-resource-manager
- azure-sql-managed-instance
urlFragment: sqlmi-free-offer
languages:
- bicep
- json
---
# Azure SQL Managed Instance free offer

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sqlmi-free-offer/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sqlmi-free-offer/PublicDeployment.svg)
![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sqlmi-free-offer/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sqlmi-free-offer/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sqlmi-free-offer/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsqlmi-free-offer%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](https://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsqlmi-free-offer%2Fazuredeploy.json)

This sample creates an Azure SQL Managed Instance using the **Freemium** offer. It creates no VM, jumpbox, VPN gateway, firewall, or other billed connectivity resources. The deploy and visualize links use the generated `azuredeploy.json`; the repository builds that file from `main.bicep` when the sample is merged. Per the repository's Bicep contribution guidance, generated JSON is not committed with this sample.

## Resources

With the default `deployNetwork: true`, the template creates ten resources:

- One `Microsoft.Sql/managedInstances` resource using **General Purpose Gen5**, **4 vCores**, **64 GB** storage, `LicenseIncluded`, `pricingModel: Freemium`, and `isGeneralPurposeV2: true`.
- One `Microsoft.Sql/managedInstances/azureADOnlyAuthentications` child resource, explicitly enabling Entra-only authentication.
- One `Microsoft.Sql/managedInstances/startStopSchedules` child resource with a 09:00–17:00 UTC Monday–Friday schedule.
- One virtual network and a dedicated `/27` SQL Managed Instance subnet delegated to `Microsoft.Sql/managedInstances`.
- One network security group, three separately declared customer security-rule child resources, and one route table associated with that subnet. Security rules are separate child resources rather than an inline NSG rule array. SQL Managed Instance service-aided subnet configuration manages the mandatory service rules and routes; this template leaves custom routes and outbound restrictions unset.

The three SQL resources are always in the template. The seven network resources are conditional on `deployNetwork`. On later deployments into the same resource group, set `deployNetwork` to `false` to reuse the previously created subnet without issuing PUTs for its VNet, subnet, NSG, NSG rules, or route table. This explicit reuse mode avoids reapplying customer network resources over SQL Managed Instance service-aided subnet configuration. The default instance, VNet, subnet, NSG, and route table names are deterministic for the resource group and instance name. If you overrode those names on the first deployment, pass the same `managedInstanceName` and `virtualNetworkName` values when reusing the subnet. In incremental deployment mode, resources skipped by a false condition are not deleted.

For example, include `--parameters deployNetwork=false` when redeploying this Bicep to the same resource group after the network and managed instance have been created. Continue to provide the same instance and Entra administrator values used at creation; the subnet name remains `ManagedInstance`.

## Offer limits and lifecycle

The current [free-offer documentation](https://learn.microsoft.com/azure/azure-sql/managed-instance/free-offer) describes one free instance per supported subscription, up to 720 vCore-hours per month, 64 GB storage, and a 12-month offer term. The documented database limit is up to 500 databases for Next-gen General Purpose or 100 for General Purpose. This template requests the four-vCore General Purpose Gen5 configuration, `isGeneralPurposeV2: true`, and the `Freemium` pricing model. Offer eligibility and availability are determined by Azure; this template does not guarantee that a subscription can claim the offer.

The offer stops the instance when its monthly vCore-hour limit is reached. At the end of the 12-month term, the instance stops; if it isn't upgraded within 30 days, Azure deletes the instance and its databases. There is no guaranteed SLA for the free offer. Review current [offer limits and terms](https://learn.microsoft.com/azure/azure-sql/managed-instance/free-offer) before deploying or storing data.

The free-offer portal experience applies a default workday schedule. This template does **not** rely on a portal default: it explicitly deploys the native schedule for 09:00 to 17:00 UTC, Monday through Friday. Schedule actions initiate start/stop operations; they are not readiness guarantees, and operations can take time or be delayed. The schedule is in UTC, so it does not shift for daylight saving time.

## Network and authentication

The managed instance is deployed into a new dedicated VNet and a `/27` subnet, the documented minimum subnet size. A route table is associated as required; no custom route or forced tunneling is configured. Current SQL Managed Instance service-aided subnet configuration provisions and maintains its required network rules and routes. The route table declaration omits `routes`, and customer NSG rules are separate child resources instead of an inline `securityRules` array; this avoids redeployment overwriting service-managed rules and routes.

The public data endpoint is enabled for client access without a paid jumpbox or gateway. The NSG allows TCP **3342** only from the required `clientIPv4Address` input; the template appends `/32`, so only that exact public IPv4 address is allowed. The NSG also allows the VNet-local SQL port 1433 and the VNet-local redirect range 11000–11999. Other inbound traffic remains denied by the NSG's default rules; default outbound rules are left intact for SQL Managed Instance service operation.

Supply the login name and object ID of an existing Microsoft Entra **user** in the deployment tenant. The template derives the tenant ID from `tenant().tenantId` and sets `principalType` to `User`. The SQL create API also requires a SQL administrator login and password even though the child resource enables Entra-only authentication after the managed instance is created. Because the supported Entra-only child API runs after the managed instance is provisioned, SQL authentication might remain enabled during that provisioning interval; the public NSG rule limits client traffic to the supplied IPv4 `/32`. Provide a strong, unique password; it is secure input and cannot be used for SQL authentication after Entra-only authentication is enabled. If your policy prohibits SQL authentication during initial provisioning, don't use this sample without first confirming the service behavior meets that policy.

## Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `location` | Resource group location | Region for the instance and network. |
| `managedInstanceName` | Unique name derived from the resource group | Managed instance name. |
| `virtualNetworkName` | Unique name derived from the resource group | New dedicated VNet name. |
| `virtualNetworkAddressPrefix` | `10.0.0.0/16` | VNet address space; adjust if it overlaps your existing network. |
| `managedInstanceSubnetPrefix` | `10.0.0.0/27` | Dedicated managed-instance subnet; at least `/27`. |
| `deployNetwork` | `true` | Create the dedicated VNet, subnet, NSG, NSG rules, and route table. Set to `false` to reuse the same network from an earlier deployment without updating it. |
| `clientIPv4Address` | Required | Client public IPv4 address, allowed to connect to TCP 3342. The template restricts it to `/32`. |
| `sqlAdministratorLogin` | Required | SQL administrator login required by the create API. |
| `sqlAdministratorPassword` | Required, secure | Strong password required by the create API. |
| `entraAdministratorLogin` | Required | Entra user login name, typically its user principal name. |
| `entraAdministratorObjectId` | Required | Entra user object ID (GUID). |

`azuredeploy.parameters.json` contains only `GEN-*` placeholders. They are not real values or valid credentials, object IDs, or IP addresses. Replace them with real deployment inputs; use a strong password and the exact client public IPv4 address.

## Deployment and cleanup

The following PowerShell example uses a **new, disposable resource group**. Run it from this sample folder after replacing the placeholders in the parameter prompts. The deployment can take several hours for a first SQL Managed Instance. It records deployment details and the resource inventory to the evidence file **before** deleting the resource group in `finally`, then verifies the group is gone. Enter an evidence path outside the repository if you need to retain the evidence.

```powershell
$resourceGroupName = 'rg-sqlmi-free-disposable'
$location = 'eastus'
$deploymentName = "sqlmi-free-$(Get-Date -Format 'yyyyMMddHHmmss')"
$evidencePath = Read-Host 'Evidence output path outside the repository'

if (Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue) {
    throw "Resource group '$resourceGroupName' already exists. Choose a new disposable name; this example deletes its resource group."
}

$parameters = @{
    clientIPv4Address = Read-Host 'Client public IPv4 address'
    entraAdministratorLogin = Read-Host 'Microsoft Entra user login'
    entraAdministratorObjectId = Read-Host 'Microsoft Entra user object ID (GUID)'
    sqlAdministratorLogin = Read-Host 'SQL administrator login'
    sqlAdministratorPassword = Read-Host 'Strong SQL administrator password' -AsSecureString
}

try {
    New-AzResourceGroup -Name $resourceGroupName -Location $location | Out-Null
    $deployment = New-AzResourceGroupDeployment `
        -ResourceGroupName $resourceGroupName `
        -Name $deploymentName `
        -TemplateFile '.\main.bicep' `
        -TemplateParameterObject $parameters `
        -ErrorAction Stop

    if ($deployment.ProvisioningState -ne 'Succeeded') {
        throw "Deployment finished with state '$($deployment.ProvisioningState)'."
    }

    $evidence = [ordered]@{
        deployment = Get-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -Name $deploymentName |
            Select-Object DeploymentName, CorrelationId, ProvisioningState, Timestamp
        resources = Get-AzResource -ResourceGroupName $resourceGroupName |
            Select-Object Name, ResourceType, ResourceId, ResourceGroupName
    }
    $evidence | ConvertTo-Json -Depth 6 | Set-Content -Path $evidencePath -Encoding utf8
    Write-Host "Deployment and resource evidence captured at $evidencePath before cleanup."
}
finally {
    if (Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue) {
        Remove-AzResourceGroup -Name $resourceGroupName -Force -ErrorAction Stop
    }

    if (Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue) {
        throw "Cleanup verification failed: resource group '$resourceGroupName' still exists."
    }
    Write-Host "Cleanup verified: resource group '$resourceGroupName' does not exist."
}
```

## Validation status

The current conditional-network revision has not been live-tested. No deployment result is claimed.

`Tags: Azure SQL Managed Instance, Freemium, free offer, General Purpose, Gen5, Entra-only authentication, public endpoint, start stop schedule, Microsoft.Sql/managedInstances, Microsoft.Network/virtualNetworks`
