---
description: This template deploys a Logic App that automates BYOD (Bring Your Own Data) file uploads for Azure AD Identity Governance Access Reviews. It provisions a Storage Account with a blob container and a Logic App that polls Access Review instances, creates upload sessions, and uploads files from blob storage.
page_type: sample
products:
- azure
- azure-resource-manager
- azure-logic-apps
- azure-storage
- azure-active-directory
urlFragment: byod-trigger-logicapp
languages:
- json
- bicep
---

# Deploy a Logic App for Automated BYOD File Uploads to Access Reviews

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/byod-logic-app/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/byod-logic-app/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/byod-logic-app/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/byod-logic-app/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/byod-logic-app/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/byod-logic-app/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fbyod-logic-app%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fbyod-logic-app%2Fazuredeploy.json)   


## Overview

This template deploys an automated BYOD (Bring Your Own Data) solution for Azure AD Identity Governance Access Reviews. It creates a complete infrastructure including:

- **Storage Account**: A Standard_RAGRS storage account with a dedicated `byod` blob container for file storage
- **Logic App**: An automated workflow that integrates with Microsoft Graph API to handle Access Review data uploads
- **Azure Blob Connection**: A managed identity-based connection for secure blob operations
- **Role Assignments**: Automatic configuration of Storage Blob Data Contributor role for the Logic App

## Architecture

The Logic App workflow performs the following operations:

1. **Trigger**: Receives HTTP POST requests with Access Review details and file paths
2. **Poll Access Review**: Queries Microsoft Graph API to get the latest Access Review instance
3. **Wait for Initialization**: Polls the Access Review status until it's ready for data upload
4. **Create Upload Session**: Initiates a BYOD upload session with the Access Review service
5. **Upload Files**: Iterates through file paths, retrieves content from blob storage, and uploads to the session
6. **Complete Session**: Marks the upload session as complete

## Prerequisites

- An Azure subscription
- Azure AD Identity Governance with Access Reviews enabled
- Appropriate permissions to deploy resources and assign roles
- Microsoft Graph API permissions for the Logic App's managed identity:
  - `AccessReview.ReadWrite.All`
  - `EntitlementManagement.ReadWrite.All`

## Parameters

| Parameter | Type | Description | Default Value |
|-----------|------|-------------|---------------|
| `location` | string | Location for all resources | Resource group location |
| `storageAccountName` | string | Name of the storage account (must be globally unique, 3-24 characters, lowercase letters and numbers only) | Required |
| `logicAppName` | string | Name of the Logic App | Required |
| `connections_azureblob_name` | string | Name of the Azure Blob Storage connection | Required |

## Deployment

### Azure Portal

Click the "Deploy to Azure" button above to deploy this template through the Azure Portal.

### Azure CLI

```bash
az group create --name myResourceGroup --location eastus

az deployment group create \
  --resource-group myResourceGroup \
  --template-file azuredeploy.json \
  --parameters azuredeploy.parameters.json
```

### PowerShell

```powershell
New-AzResourceGroup -Name myResourceGroup -Location eastus

New-AzResourceGroupDeployment `
  -ResourceGroupName myResourceGroup `
  -TemplateFile azuredeploy.json `
  -TemplateParameterFile azuredeploy.parameters.json
```

## Post-Deployment Steps

After deploying the template, complete these additional configuration steps:

1. **Grant Microsoft Graph Permissions**:
   - Navigate to the Logic App in Azure Portal
   - Go to Identity → System assigned
   - Note the Object (principal) ID
   - In Azure AD, grant the required API permissions:
     - `AccessReview.ReadWrite.All`
     - `IdentityGovernance.ReadWrite.All`

2. **Configure Access Review Resource**:
   - Set up your Access Review definition in Azure AD Identity Governance
   - Note the `definitionId`, `catalogId`, and `resourceId`
   - Configure the resource to use disconnected apps/BYOD

3. **Upload Files to Blob Storage**:
   - Upload your data files to the `byod` container in the storage account
   - Note the full blob paths (e.g., `byod/data.csv`)

4. **Trigger the Logic App**:
   - Get the HTTP POST URL from the Logic App trigger
   - Send a POST request with the following JSON body:
   ```json
   {
     "definitionId": "your-access-review-definition-id",
     "catalogId": "your-catalog-id",
     "resourceId": "your-resource-id",
     "filePaths": ["byod/file1.csv", "byod/file2.csv"]
   }
   ```

## Security Considerations

- The Logic App uses **System-Assigned Managed Identity** for authentication
- Storage account access is secured with **Storage Blob Data Contributor** role assignment
- Blob public access is disabled by default
- The Azure Blob connection uses managed identity authentication (no keys stored)

## Resources Deployed

- **Microsoft.Storage/storageAccounts**: Storage account with blob and file services
- **Microsoft.Storage/storageAccounts/blobServices/containers**: BYOD blob container
- **Microsoft.Web/connections**: Azure Blob Storage API connection
- **Microsoft.Logic/workflows**: Logic App workflow
- **Microsoft.Authorization/roleAssignments**: Storage Blob Data Contributor role for Logic App

## Tags

`Tags: Microsoft.Logic/workflows, Request, Http, InitializeVariable, SetVariable, ParseJson, Until, Wait, Foreach, ApiConnection, Microsoft.Storage/storageAccounts, Microsoft.Web/connections, Microsoft.Authorization/roleAssignments, Managed Identity, Identity Governance, Access Reviews, BYOD`
