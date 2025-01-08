@description('Specifies the name of the Azure Machine Learning workspace where sweep job will be deployed')
param workspaceName string

@description('Name of the blob as it is stored in the blob container')
param filename string = 'main.py'

@description('Name of the blob container')
param containerName string = 'hdscript'

@description('Azure region where resources should be deployed')
param location string = resourceGroup().location

@description('Desired name of the storage account')
param storageAccountName string

@description('Specifies the env version for sweep job.')
param codeVersion string = '1'

@description('Specifies the env for sweep job.')
param codeId string = 'code'

// fetching existing storage account
resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
  // creating blob service in storage account
  resource blobService 'blobServices' = {
    name: 'default'
    // creating blob container in storage account
    resource container 'containers' = {
      name: containerName
      properties: {
        publicAccess: 'Container'
      }
    }
  }
}

// creating deployment script to upload hyperdrive script 'main.py' to blob container
resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployscript-upload-blob-${uniqueString(storage::blobService::container.id)}'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.26.1'
    timeout: 'PT5M'
    retentionInterval: 'PT1H'
    environmentVariables: [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: storage.name
      }
      {
        name: 'AZURE_STORAGE_KEY'
        secureValue: storage.listKeys().keys[0].value
      }
      {
        name: 'CONTENT'
        value: loadTextContent('../scripts/main.py')
      }
    ]
    scriptContent: 'echo "$CONTENT" > ${filename} && az storage blob upload -f ${filename} -c ${containerName} -n ${filename}'
  }
}

// creating codeVersion resource using uploaded hyperdrive script blob url
resource codeVersionResource 'Microsoft.MachineLearningServices/workspaces/codes/versions@2022-05-01' = {
  dependsOn: [ deploymentScript ]
  name: '${workspaceName}/${codeId}-${uniqueString(storage::blobService::container.id)}/${codeVersion}'
  properties: {
    codeUri: uri('https://${storageAccountName}.blob.${environment().suffixes.storage}/', '${containerName}/')
    isAnonymous: false
  }
}

// output the codeId from codeVersion resource
output codeId string = codeVersionResource.id
