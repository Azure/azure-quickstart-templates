// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import { HubAppProperties } from 'hub-types.bicep'

//==============================================================================
// Parameters
//==============================================================================

@description('Required. FinOps hub app that storage is getting updated for.')
param app HubAppProperties

@description('Required. Name of the storage container to create or update.')
param container string

@description('Optional. Dictionary of key/value pairs for the files to upload to the specified container. The key is the target path under the container and the value is the contents of the file. Default: {} (no files to upload).')
param files object = {}

@description('Optional. Indicates whether to create the blob manager user assigned identity even if files are not being uploaded. Default: false.')
param forceCreateBlobManagerIdentity bool = false

//==============================================================================
// Variables
//==============================================================================

var fileCount = length(items(files))
var hasFiles = fileCount > 0

//==============================================================================
// Resources
//==============================================================================

// Get storage account instance
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: app.storage

  resource blobService 'blobServices@2022-09-01' existing = {
    name: 'default'

    resource targetContainer 'containers@2022-09-01' = {
      name: container
      properties: {
        publicAccess: 'None'
        metadata: {}
      }
    }
  }
}

// TODO: Enforce retention

// Create blob manager identity for uploads
module identity 'hub-identity.bicep' = if (hasFiles || forceCreateBlobManagerIdentity) {
  name: '${deployment().name}.Identity'
  params: {
    app: app
    identityName: '${app.storage}_blobManager'
    roleAssignmentResourceId: resourceId('Microsoft.Storage/storageAccounts', app.storage)
    roles: [
      // Storage Blob Data Contributor - https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#storage-blob-data-contributor
      // Used by deployment scripts to write data to blob storage
      'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

      // Storage File Data Privileged Contributor - https://learn.microsoft.com/azure/role-based-access-control/built-in-roles/storage#storage-file-data-privileged-contributor
      // https://learn.microsoft.com/azure/azure-resource-manager/templates/deployment-script-template#use-existing-storage-account
      '69566ab7-960f-475b-8e7c-b3118f30c6bd'
    ]
  }
}

// Upload schema file to storage
module uploadFiles 'hub-deploymentScript.bicep' = if (hasFiles) {
  name: '${deployment().name}.Upload'
  params: {
    app: app
    #disable-next-line BCP318 // Null safety warning for conditional resource access
    identityName: identity.outputs.name
    environmentVariables: [
      {
        name: 'storageAccountName'
        value: app.storage
      }
      {
        name: 'containerName'
        value: container
      }
      {
        name: 'files'
        value: string(files)
      }
    ]
    scriptContent: loadTextContent('./scripts/Upload-StorageFile.ps1')
  }
}

//==============================================================================
// Outputs
//==============================================================================

@description('The name of the storage container.')
output containerName string = storageAccount::blobService::targetContainer.name

@description('The number of files uploaded to the storage container.')
output filesUploaded int = fileCount

@description('Resource ID of the user assigned identity used to upload files. Will be empty if no files are uploaded or forceCreateBlobManagerIdentity is false.')
#disable-next-line BCP318 // Null safety warning for conditional resource access
output identityId string = hasFiles || forceCreateBlobManagerIdentity ? identity.outputs.id : ''

@description('Name of the user assigned identity used to upload files. Will be empty if no files are uploaded or forceCreateBlobManagerIdentity is false.')
#disable-next-line BCP318 // Null safety warning for conditional resource access
output identityName string = hasFiles || forceCreateBlobManagerIdentity ? identity.outputs.name : ''

@description('Principal ID of the user assigned identity used to upload files. Will be empty if no files are uploaded or forceCreateBlobManagerIdentity is false.')
#disable-next-line BCP318 // Null safety warning for conditional resource access
output identityPrincipalId string = hasFiles || forceCreateBlobManagerIdentity ? identity.outputs.principalId : ''
