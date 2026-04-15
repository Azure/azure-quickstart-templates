---
description: This template deploys a request-triggered Logic App for Microsoft Entra Entitlement Management BYOD (Bring Your Own Data) scenarios. It provisions a storage account with a byod blob container, a Logic App with an HTTP Request trigger, and AADPOP authentication policies for secure integration with Entra ID and Access Reviews.
page_type: sample
products:
- azure
- azure-resource-manager
- azure-logic-apps
- azure-active-directory
urlFragment: byod-logic-app
languages:
- json
---

# Deploy a Request-Triggered BYOD Logic App for Entitlement Management

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/identity-governance/byod-logic-app/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/identity-governance/byod-logic-app/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/identity-governance/byod-logic-app/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/identity-governance/byod-logic-app/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/identity-governance/byod-logic-app/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/identity-governance/byod-logic-app/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fidentity-governance%2Fbyod-logic-app%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fidentity-governance%2Fbyod-logic-app%2Fazuredeploy.json)

## Overview

This template deploys a **request-triggered Logic App** for Microsoft Entra Entitlement Management BYOD (Bring Your Own Data) scenarios. When triggered, the Logic App reads files from a blob storage container and uploads them to Microsoft Graph for use in Access Reviews.

The template only requires two inputs — a **Logic App name** and a **Storage Account name**. Everything else is auto-configured.

## How It Works

When an Access Review triggers the Logic App via HTTP webhook, the following workflow executes:

1. **Receive trigger payload** — The HTTP Request trigger accepts a POST containing `catalogId`, `customDataProvidedResourceId`, `reviewDefinitionId`, and `reviewInstanceId`.
2. **Create an upload session** — The Logic App calls the Microsoft Graph API to create a BYOD upload session for the specified catalog and resource.
3. **List blobs** — After a short delay, the Logic App lists all files in the `byod` container of the configured storage account.
4. **Upload each file** — For each blob found, the Logic App reads the file content and uploads it to the Graph API upload session as a multipart form upload. Files are processed sequentially with a short delay between each upload.
5. **End the upload session** — Once all files are uploaded (or if the upload loop fails), the Logic App closes the upload session by setting `isUploadDone` to `true`.

All Microsoft Graph API calls use the Logic App's **system-assigned managed identity** for authentication.

## Parameters

| Parameter | Type | Description | Default Value |
|-----------|------|-------------|---------------|
| `logicAppName` | string | The name of the Logic App workflow that will be created to handle BYOD data uploads for Access Reviews | *Required* |
| `storageAccountName` | string | The name of the storage account to create. Files placed in its `byod` container will be uploaded to Microsoft Graph during Access Reviews | *Required* |
| `location` | string | Azure region for all deployed resources | Resource group location |
| `cloudEnvironment` | string | Target Azure cloud environment. Determines ARM, Graph, and STS endpoints. Allowed values: `AzureCloud`, `AzureUSGovernment`, `AzureChinaCloud` | `AzureCloud` |

The blob connection name is auto-generated as `{logicAppName}-{storageAccountName}-connection`.

## Resources Deployed

| Resource | Type | Description |
|----------|------|-------------|
| Storage Account | `Microsoft.Storage/storageAccounts` | StorageV2 account with HTTPS-only, TLS 1.2, and blob/file retention policies |
| Blob Container | `Microsoft.Storage/storageAccounts/blobServices/containers` | Container named `byod` where data files are stored |
| Blob Connection | `Microsoft.Web/connections` | Managed identity-authenticated connection to Azure Blob Storage |
| Logic App | `Microsoft.Logic/workflows` | System-assigned managed identity Logic App with HTTP trigger and AADPOP access control |
| Role Assignment | `Microsoft.Authorization/roleAssignments` | Grants the Logic App **Storage Blob Data Reader** on the storage account |

## Deployment

### Azure Portal

Click the **Deploy to Azure** button above.

### Azure CLI

```bash
az group create --name myResourceGroup --location eastus

az deployment group create \
  --resource-group myResourceGroup \
  --template-file azuredeploy.json \
  --parameters logicAppName=myLogicApp storageAccountName=mystorageacct
```

### PowerShell

```powershell
New-AzResourceGroup -Name myResourceGroup -Location eastus

New-AzResourceGroupDeployment `
  -ResourceGroupName myResourceGroup `
  -TemplateFile azuredeploy.json `
  -logicAppName myLogicApp `
  -storageAccountName mystorageacct
```

## Post-Deployment: Assign API Permissions

After deploying the template, you **must** grant the Logic App's managed identity the required Microsoft Graph API permissions. Without these permissions, the Logic App will not be able to create upload sessions or upload files.

### Required Permissions

The Logic App's system-assigned managed identity needs the following Microsoft Graph **application permission**:

- `EntitlementManagement.ReadWrite.All`

### Assign Permissions via PowerShell

```powershell
# Input parameters
$subscriptionId = "<your-subscription-id>"
$servicePrincipalId = "<your-logic-app-service-principal-id>"

# Set the active subscription
Set-AzContext -SubscriptionId $subscriptionId

# Get the Microsoft Graph service principal
$graphApp = Get-AzADServicePrincipal -Filter "appId eq '00000003-0000-0000-c000-000000000000'"

# Find the required app role
$appRole = $graphApp.AppRole | Where-Object { $_.Value -eq 'EntitlementManagement.ReadWrite.All' }

# Assign the permission
New-AzADServicePrincipalAppRoleAssignment `
  -ServicePrincipalId $servicePrincipalId `
  -ResourceId $graphApp.Id `
  -AppRoleId $appRole.Id
```

### Assign Permissions via Azure CLI

```bash
# Input parameters
SUBSCRIPTION_ID="<your-subscription-id>"
SERVICE_PRINCIPAL_ID="<your-logic-app-service-principal-id>"

# Set the active subscription
az account set --subscription "$SUBSCRIPTION_ID"

# Get the Microsoft Graph service principal ID
GRAPH_SP_ID=$(az ad sp show --id 00000003-0000-0000-c000-000000000000 --query id -o tsv)

# Get the app role ID for EntitlementManagement.ReadWrite.All
APP_ROLE_ID=$(az ad sp show --id 00000003-0000-0000-c000-000000000000 \
  --query "appRoles[?value=='EntitlementManagement.ReadWrite.All'].id" -o tsv)

# Assign the permission
az rest --method POST \
  --uri "https://graph.microsoft.com/v1.0/servicePrincipals/$GRAPH_SP_ID/appRoleAssignments" \
  --body "{\"principalId\":\"$SERVICE_PRINCIPAL_ID\",\"resourceId\":\"$GRAPH_SP_ID\",\"appRoleId\":\"$APP_ROLE_ID\"}"
```

> You can find the Logic App's service principal ID in the Azure Portal under **Logic App → Identity → System assigned → Object ID**.

## Security

- **SAS authentication is disabled** — the trigger endpoint does not accept SAS tokens
- **AADPOP policies** enforce Proof-of-Possession token validation, ensuring only authorized Entra ID applications (ESI and Access Reviews) can invoke the Logic App
- Claims validated include issuer, audience, appId, HTTP method, host, and resource path
- The Logic App uses a **system-assigned managed identity** for all Microsoft Graph API calls and blob storage access
- The storage account is configured with **no public blob access** and **HTTPS-only** traffic

## Preparing Data Files

Upload your data files to the `byod` container in the deployed storage account. The Logic App will read all files at the root of this container when triggered.

You can upload files using the Azure Portal, Azure CLI, or Azure Storage Explorer:

```bash
az storage blob upload-batch \
  --account-name <your-storage-account> \
  --destination byod \
  --source ./local-data-folder \
  --auth-mode login
```

`Tags: Microsoft.Logic/workflows, Microsoft.Storage/storageAccounts, Microsoft.Web/connections, Request, Http, AADPOP, Identity Governance, Entitlement Management, Access Reviews, BYOD`
