# Stop PostgreSQL Flexible Server with Azure Automation

[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.automation%2Fautomation-stop-postgresql-flexible-server%2Fazuredeploy.json)
[![Visualize](https://aka.ms/armtemplatevisualizerbutton)](https://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.automation%2Fautomation-stop-postgresql-flexible-server%2Fazuredeploy.json)
[![Bicep Version](https://img.shields.io/badge/Bicep-main-blue.svg)](main.bicep)

This sample creates an Azure Automation Account with a system-assigned managed identity and a PowerShell 7.2 runbook. The runbook reads an existing Azure Database for PostgreSQL Flexible Server and sends a stop request only when its state is `Ready`. A daily UTC schedule is created automatically.

Tags: `azure automation, postgresql, flexible server, managed identity, cost management`

## Prerequisites

- An existing Azure Database for PostgreSQL Flexible Server.
- Permission to create resources in the deployment resource group.
- `Microsoft.Authorization/roleAssignments/write` on the target server when `assignServerContributorRole` is `true`.

The template assigns the Automation Account identity the built-in Contributor role scoped only to the target server. This lets the runbook read and stop that server, but does not grant access to other resources. Set `assignServerContributorRole` to `false` if an administrator manages a custom least-privilege role assignment separately.

## Deployment notes

The Deploy to Azure button resolves the runbook script from this sample's `scripts` folder after it is merged into the Azure Quickstart Templates repository. For a local Azure CLI deployment, provide `runbookContentUri` as a reachable HTTPS URI for `Stop-PostgreSqlFlexibleServer.ps1`.

Automation module imports are asynchronous. Wait until `Az.Accounts` and `Az.PostgreSql` show as available before relying on the first scheduled run.

Stopping a flexible server pauses compute but can leave storage and backup charges. Confirm the schedule, current billing behavior, and operational requirements before deployment.
