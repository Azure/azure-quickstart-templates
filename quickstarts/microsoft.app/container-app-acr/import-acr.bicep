@description('The name of the Azure Container Registry')
param acrName string

@description('The location to deploy the resources to')
param location string = resourceGroup().location

@description('How the deployment script should be forced to execute')
param forceUpdateTag  string = utcNow()

@description('Azure RoleId that are required for the DeploymentScript resource to import images')
param rbacRoleNeeded string = 'b24988ac-6180-42a0-ab88-20f7382dd24c' //Contributor is needed to import ACR

@description('Does the Managed Identity already exists, or should be created')
param useExistingManagedIdentity bool = false

@description('Name of the Managed Identity resource')
param managedIdentityName string = 'id-ContainerRegistryImport'

@description('For an existing Managed Identity, the Subscription Id it is located in')
param existingManagedIdentitySubId string = subscription().subscriptionId

@description('For an existing Managed Identity, the Resource Group it is located in')
param existingManagedIdentityResourceGroupName string = resourceGroup().name

@description('An array of fully qualified images names to import')
param images array

@description('A delay before the script import operation starts. Primarily to allow Azure AAD Role Assignments to propagate')
param initialScriptDelay string = '30s'

@allowed([
  'OnSuccess'
  'OnExpiration'
  'Always'
])
@description('When the script resource is cleaned up')
param cleanupPreference string = 'OnSuccess'

resource acr 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' existing = {
  name: acrName
}

resource newDepScriptId 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = if (!useExistingManagedIdentity) {
  name: managedIdentityName
  location: location
}

resource existingDepScriptId 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = if (useExistingManagedIdentity ) {
  name: managedIdentityName
  scope: resourceGroup(existingManagedIdentitySubId, existingManagedIdentityResourceGroupName)
}

resource rbac 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = if (!empty(rbacRoleNeeded)) {
  name: guid(acr.id, rbacRoleNeeded, useExistingManagedIdentity ? existingDepScriptId.id : newDepScriptId.id)
  scope: acr
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', rbacRoleNeeded)
    principalId: useExistingManagedIdentity ? existingDepScriptId.properties.principalId : newDepScriptId.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource createImportImage 'Microsoft.Resources/deploymentScripts@2020-10-01' = [for image in images: {
  name: 'ACR-Import-${acr.name}-${last(split(replace(image,':',''),'/'))}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${useExistingManagedIdentity ? existingDepScriptId.id : newDepScriptId.id}': {}
    }
  }
  kind: 'AzureCLI'
  dependsOn: [
    rbac
  ]
  properties: {
    forceUpdateTag: forceUpdateTag
    azCliVersion: '2.30.0'
    timeout: 'PT30M'
    retentionInterval: 'P1D'
    environmentVariables: [
      {
        name: 'acrName'
        value: acrName
      }
      {
        name: 'imageName'
        value: image
      }
      {
        name: 'initialDelay'
        value: initialScriptDelay
      }
      {
        name: 'retryMax'
        value: '2'
      }
      {
        name: 'retrySleep'
        value: '5s'
      }
    ]
    scriptContent: '''
      #!/bin/bash
      set -e

      echo "Waiting on RBAC replication ($initialDelay)"
      sleep $initialDelay
      
      #Retry loop to catch errors (usually RBAC delays, but 'Error copying blobs' is also not unheard of)
      retryLoopCount=0
      until [ $retryLoopCount -ge $retryMax ]
      do
        echo "Importing Image: $imageName into ACR: $acrName"
        az acr import -n $acrName --source $imageName --force \
          && break

        sleep $retrySleep
        retryLoopCount=$((retryLoopCount+1))
      done

    '''
    cleanupPreference: cleanupPreference
  }
}]

@description('An array of the imported imageUris')
output images array = [for image in images: {
  originalImage : image
  acrHostedImage : '${acr.properties.loginServer}${string(skip(image, indexOf(image,'/')))}'
  //Brians suggestion: uri('https://${acr.properties.loginServer}', string(skip(image, indexOf(image, '/')))) 
}]
