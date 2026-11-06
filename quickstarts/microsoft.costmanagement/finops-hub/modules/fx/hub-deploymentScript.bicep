// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

import { HubAppProperties } from 'hub-types.bicep'

type EnvironmentVariable = {
  name: string
  value: string
}


//==============================================================================
// Parameters
//==============================================================================

@description('Required. FinOps hub app the deployment script is being run for.')
param app HubAppProperties

@description('Required. Name of the managed identity to create.')
param identityName string

@description('Optional. Name of the deployment script to create. Default = (same as deployment).')
param scriptName string = deployment().name

@description('Required. Name of the deployment script to create.')
param scriptContent string

@description('Optional. Additional arguments to pass into the deployment script.')
param arguments string = ''

@description('Optional. Environment variables to use for the deployment script.')
param environmentVariables EnvironmentVariable[] = []

@description('Optional. Forces the script to run again when the value changes. Default = empty (only reruns when properties change).')
param forceUpdateTag string = ''


//==============================================================================
// Variables
//==============================================================================

// See https://learn.microsoft.com/azure/azure-resource-manager/templates/deployment-script-template#use-existing-storage-account
var privateEndpointDeploymentRoles = !app.hub.options.privateRouting ? [] : [
  '69566ab7-960f-475b-8e7c-b3118f30c6bd' // Storage File Data Privileged Contributor - https://learn.microsoft.com/azure/role-based-access-control/built-in-roles/storage#storage-file-data-privileged-contributor
]
var containerGroupName = replace(replace(replace(scriptName, '/', '-'), '.', '-'), '_', '-')
var privateEndpointDeploymentProperties = !app.hub.options.privateRouting ? {} : {
  storageAccountSettings: {
    storageAccountName: app.hub.routing.scriptStorage ?? ''
  }
  containerSettings: {
    containerGroupName: length(containerGroupName) > 63 ? substring(containerGroupName, 0, 62) : containerGroupName
    subnetIds: [
      {
        id: app.hub.routing.subnets.scripts ?? ''
      }
    ]
  }
}


//==============================================================================
// Resources
//==============================================================================

//------------------------------------------------------------------------------
// Create identity to run deployment scripts
//------------------------------------------------------------------------------

// Create managed identity to run deployment scripts
// TODO: Use hub-identity.bicep
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  tags: union(app.tags, app.hub.tagsByResource[?'Microsoft.ManagedIdentity/userAssignedIdentities'] ?? {})
  location: app.hub.location
}

// Get script storage account for private endpoint deployment scripts
resource scriptStorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing =  if (app.hub.options.privateRouting) {
  name: app.hub.routing.scriptStorage ?? ''
}

// Assign the identity access to the script storage account
// TODO: Use hub-identity.bicep
resource identityRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for role in privateEndpointDeploymentRoles: if (app.hub.options.privateRouting) {
  name: guid(role, identity.id)
  scope: scriptStorageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}]


//------------------------------------------------------------------------------
// Upload schema file to storage
//------------------------------------------------------------------------------

resource script 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: scriptName
  dependsOn: [
    identityRoleAssignments
  ]
  kind: 'AzurePowerShell'
  // chinaeast2 is the only region in China that supports deployment scripts
  location: startsWith(app.hub.location, 'china') ? 'chinaeast2' : app.hub.location  // cSpell:ignore chinaeast
  tags: union(app.tags, app.hub.tagsByResource[?'Microsoft.Resources/deploymentScripts'] ?? {})
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    ...privateEndpointDeploymentProperties
    azPowerShellVersion: '11.0'
    retentionInterval: 'PT1H'
    cleanupPreference: 'OnSuccess'
    scriptContent: scriptContent
    arguments: arguments
    environmentVariables: environmentVariables
    forceUpdateTag: empty(forceUpdateTag) ? null : forceUpdateTag
  }
}


//==============================================================================
// Outputs
//==============================================================================

@description('Values the script set in $DeploymentScriptOutputs. Empty if the script did not set any.')
output scriptOutputs object = script.properties.?outputs ?? {}
