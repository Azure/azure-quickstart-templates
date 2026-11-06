---
description: Configure a native weekday start and stop schedule for an existing General Purpose Azure SQL Managed Instance.
page_type: sample
products:
- azure
- azure-resource-manager
- azure-sql-managed-instance
urlFragment: sqlmi-start-stop-schedule
languages:
- bicep
- json
---
# Schedule start and stop for an existing SQL managed instance

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sqlmi-start-stop-schedule/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sqlmi-start-stop-schedule/PublicDeployment.svg)
![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sqlmi-start-stop-schedule/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sqlmi-start-stop-schedule/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sql/sqlmi-start-stop-schedule/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsqlmi-start-stop-schedule%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](https://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sql%2Fsqlmi-start-stop-schedule%2Fazuredeploy.json)

This operational sample configures the **native SQL Managed Instance scheduler** on an instance you already operate. It does not create a paid managed instance, virtual network, Automation account, runbook, or any other infrastructure. This sample targets Azure public cloud only.

The portal and visualization links use `azuredeploy.json`, which the repository generates from `main.bicep` on merge. Generated JSON is not included in the contribution. Before publication, deploy the local Bicep file as shown below.

## Sample overview and deployed resources

The only deployed resource is `Microsoft.Sql/managedInstances/startStopSchedules`, API version `2023-08-01`, named `default` under the existing managed instance. The parent is declared `existing` in Bicep and is not redeployed. There is no `location` parameter because this child resource has no location property; it belongs to its existing parent in the deployment resource group.

A loop builds five `scheduleList` entries, Monday through Friday. Each entry supplies `startDay`, `startTime`, `stopDay`, and `stopTime`; the schedule also supplies `timeZoneId` and `description`. Defaults initiate a start at 08:00 and a stop at 18:00 UTC on each weekday, with no weekend start. This is not a continuous policy that enforces a stopped state outside these times.

**Deployment replaces the entire `default` schedule**, including any existing weekend or custom entries. It does not immediately start or stop the instance. Review the impact on applications and obtain the instance owner's approval before deploying.

## Prerequisites

- An **existing General Purpose Azure SQL Managed Instance in the same subscription and resource group as the deployment**. Business Critical instances are not supported. Use an instance eligible for stop/start: the documented limitations exclude failover groups, Managed Instance link, zone redundancy, and instance pools. Avoid deployment during ongoing management operations.
- Permissions to deploy resources to that group and manage the instance's start/stop schedule.
- Azure CLI and Bicep for local deployment, or the portal after publication.

The main template treats the existing instance as the operational target, not infrastructure to provision. If you already have an eligible instance, skip the optional `prereqs` deployment. For contributor deployment testing, `prereqs/prereq.main.bicep` is a standalone template that provisions a dedicated throwaway free-offer General Purpose instance and its network. It does not configure a schedule, create databases, or load sample data. Do not use a customer's instance for testing.

The prerequisite instance uses `pricingModel: Freemium`, `GP_Gen5`, 4 vCores, 64 GB storage, General Purpose v2, and license-included billing. Free-offer eligibility, regional availability, quotas, and offer terms must be checked separately; do not change the pricing model to a paid model merely to bypass an eligibility error. The template creates a dedicated virtual network, delegated `/27` subnet, route table, NSG, and Entra-only authentication configuration. Its public endpoint permits TCP 3342 only from the supplied client IPv4 `/32`; SQL credentials required by the create API are disabled for authentication after provisioning.

The instance create API requires bootstrap SQL credentials even when the Entra administrator is supplied inline. Entra-only authentication is enabled by a separate child-resource operation, so there can be a SQL-authentication-enabled provisioning interval until that operation succeeds. If your policy prohibits that interval, do not deploy these prerequisites; use an existing compliant instance instead. Verify the authentication child succeeded before using the test instance.

Prerequisite inputs include `location` (defaults to the resource group location), optional generated instance and virtual-network names, network prefixes, and the required `clientIPv4Address`, `entraAdministratorLogin`, `entraAdministratorObjectId`, `sqlAdministratorLogin`, and secure `sqlAdministratorPassword`. Supply a real IPv4 address, Entra user principal name and object ID, and strong initial SQL credentials. The GEN-only `prereqs/prereq.azuredeploy.parameters.json` is a test-placeholder contract, not ready-to-deploy values. Use a protected parameter source for the password; do not place secrets in source control or command history.

The prerequisite parameter `deployNetwork` defaults to `true` for **first provisioning only**. SQL Managed Instance subsequently injects required NSG rules and routes through its network intent policy. On repeat prerequisite deployments, pass **`deployNetwork=false`** and retain the same instance name, virtual-network name, and matching network configuration. This mode sends no PUT requests for the NSG, security rules, route table, virtual network, or subnet; it uses the deterministic existing subnet ID for the instance. It does not update client access rules or apply changed network prefixes. The existing network must already be correctly configured. With incremental deployment, skipping these resources does not delete them. Do not use complete mode.

Deploy `prereqs/prereq.main.bicep` to a dedicated test resource group in incremental mode, then use its `managedInstanceId` output to obtain the existing instance name for the main deployment. Its other output is `managedInstanceSubnetId`. Keep any free-offer instance created by another coordinated test in the same dedicated group only when its resource names and configuration match; do not create a second instance unnecessarily.

Repository contribution testing requires real successful deployment evidence for **both** `prereqs/prereq.main.bicep` and `main.bicep`. Record `testResult.deployments` as an array in `metadata.json`, with each entry's exact template path, deployment name, and correlation ID. Evidence is not supplied until those deployments have actually succeeded.

`azuredeploy.parameters.json` contains only the repository's `GEN-UNIQUE` placeholder. **It does not identify a real existing instance** and cannot provision one. Supply the actual existing instance name explicitly; do not deploy the placeholder file unchanged.

## Parameters

| Parameter | Default | Description and constraints |
| --- | --- | --- |
| `managedInstanceName` | Required | Existing eligible General Purpose instance name, 1–63 characters. Must be in the deployment resource group. |
| `timeZoneId` | `UTC` | Nonempty Windows time zone ID supported by SQL Managed Instance, for example `Pacific Standard Time`. Not an IANA ID such as `America/Los_Angeles`. |
| `startTime` | `08:00` | Five-character 24-hour `HH:mm` local time. Must be earlier than `stopTime` for this same-day example. |
| `stopTime` | `18:00` | Five-character 24-hour `HH:mm` local time. Must be at least one hour after the start and at least one hour before the next start. |

Bicep constrains string lengths; the service validates time syntax, time zone IDs, non-overlap, and at least one hour between successive actions. This example does not model overnight intervals. For different days or overnight schedules, adapt the loop and validate all pairs against the service rules.

### Time zones, daylight saving time, and costs

The schedule time zone is independent of the instance's SQL time zone. Times are interpreted in `timeZoneId`. Windows zones that observe daylight saving time follow their daylight saving rules, so an 08:00 local start has a different UTC offset across the year. `UTC` has no daylight saving transition. Review schedules near clock changes, especially ambiguous or nonexistent local times, and use UTC when a fixed UTC time is required.

Schedule times **initiate** operations; they are not readiness guarantees. Starting typically takes about 20 minutes and can take longer. Choose an earlier start if applications must be ready at a particular time. Conflicting management operations can cause a scheduled stop to be skipped. Azure may start a stopped instance for urgent maintenance.

For paid instances, stopping removes compute and SQL license charges while stopped, but **data and backup storage remain billed**. Started hours are billed as whole hours; reservations are not refunded while idle. Scheduling does not make an existing paid instance free. A separately provisioned free-offer test instance remains subject to its own offer limits and terms.

## Deployment steps

The following PowerShell examples assume the current directory is this sample folder. Set the resource group and instance name to your actual existing resources. No command creates a managed instance.

### 1. Inspect and save the original schedule

```powershell
$resourceGroupName = '<existing-resource-group>'
$managedInstanceName = '<existing-managed-instance>'
$instanceId = az sql mi show --resource-group $resourceGroupName --name $managedInstanceName --query id --output tsv
if ($LASTEXITCODE -ne 0) { throw 'Existing managed instance lookup failed.' }
$scheduleUrl = "https://management.azure.com$instanceId/startStopSchedules/default?api-version=2023-08-01"
az rest --method get --url $scheduleUrl --output json
```

If a schedule exists, save its writable properties before replacing it:

```powershell
$originalSchedule = az rest --method get --url $scheduleUrl --output json | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) { throw 'Schedule backup failed. Do not deploy until the error is resolved.' }
$originalBody = @{
  properties = @{
    description = $originalSchedule.properties.description
    timeZoneId = $originalSchedule.properties.timeZoneId
    scheduleList = @($originalSchedule.properties.scheduleList | Select-Object startDay, startTime, stopDay, stopTime)
  }
}
$originalBody | ConvertTo-Json -Depth 10 | Set-Content -Path '.\original-schedule.json' -Encoding utf8
```

If GET returns **404 because no schedule exists**, record that fact and skip the backup block. Authentication, permission, and other errors are not evidence of an absent schedule. Retain the backup outside source control until cleanup is complete.

### 2. Deploy to the existing resource group

```powershell
az deployment group create `
  --resource-group $resourceGroupName `
  --name 'sqlmi-weekday-schedule' `
  --mode Incremental `
  --template-file '.\main.bicep' `
  --parameters managedInstanceName=$managedInstanceName timeZoneId='UTC' startTime='08:00' stopTime='18:00'
```

Use **incremental** mode. Do not use complete mode against a resource group containing an existing instance. The outputs `managedInstanceId` and `startStopScheduleId` identify the existing parent and the schedule child.

### 3. Verify

```powershell
az sql mi start-stop-schedule show --resource-group $resourceGroupName --mi $managedInstanceName --output json
```

Confirm the time zone, description, and all five weekday start/stop pairs. A successful deployment verifies configuration, not that future scheduled operations have executed. The documented native scheduled actions are not recorded in the Azure Activity Log; observe instance state around scheduled times rather than treating deployment history as runtime evidence.

## Cleanup and restoration

**Never delete the existing managed instance or its resource group to remove this sample.** Deleting an ARM deployment record does not remove its schedule.

- If an original schedule existed, restore it instead of deleting it:

  ```powershell
  az rest --method put --url $scheduleUrl --body '@original-schedule.json'
  az sql mi start-stop-schedule show --resource-group $resourceGroupName --mi $managedInstanceName --output json
  ```

- If no original schedule existed, remove only the schedule created by this sample:

  ```powershell
  az sql mi start-stop-schedule delete --resource-group $resourceGroupName --mi $managedInstanceName --yes
  ```

Removing or restoring a schedule does not change the instance's current running state. If testing stopped the instance, coordinate any manual restart with its owner; do not assume schedule deletion starts it.

For coordinated contributor testing only, the parent workflow owns the dedicated throwaway free instance and its resource group, including resources deployed by `prereqs/prereq.main.bicep`. It must remove or restore this schedule and wait until no dependent test still needs the instance before deleting that test group **once**. This deletion removes the prerequisite instance and all its network resources; stopping alone is not full cleanup. Do not apply that group-deletion procedure to user-owned infrastructure.

## References

- [Stop and start an instance: rules, limitations, billing, and schedule commands](https://learn.microsoft.com/azure/azure-sql/managed-instance/instance-stop-start-how-to)
- [Bicep and ARM schema for startStopSchedules, API 2023-08-01](https://learn.microsoft.com/azure/templates/microsoft.sql/2023-08-01/managedinstances/startstopschedules)
- [Managed instance create schema, API 2025-01-01](https://learn.microsoft.com/azure/templates/microsoft.sql/2025-01-01/managedinstances)
- [Entra-only authentication child schema, API 2025-01-01](https://learn.microsoft.com/azure/templates/microsoft.sql/2025-01-01/managedinstances/azureadonlyauthentications)

`Tags: Azure SQL Managed Instance, General Purpose, start stop schedule, Microsoft.Sql/managedInstances/startStopSchedules, existing resource, cost optimization`
