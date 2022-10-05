@description('Specifies the name of the Azure Machine Learning workspace where sweep job will be deployed')
param workspaceName string

@description('Name of the blob as it is stored in the blob container')
param filename string = 'hello_world.py'

@description('Name of the blob container')
param containerName string = 'workspaceblobstore'

@description('Azure region where resources should be deployed')
param location string = resourceGroup().location

@description('Desired name of the storage account')
param storageAccountName string

@description('Specifies the env version for sweep job.')
param codeVersion string = '1'

@description('Specifies the env for command job.')
param codeId string = 'code'

@description('The base URI where artifacts required by this template are located including a trailing \'/\'.')
param _artifactsLocation string = 'https://github.com/DannyMireles/azure-quickstart-templates/tree/master/quickstarts/microsoft.machinelearningservices/machine-learning-job-create-or-update-job/data'

@description('The sasToken required to access _artifactsLocation.')
@secure()
param _artifactsLocationSasToken string = ''


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


// creating codeVersion resource for command job
resource codeVersionResource 'Microsoft.MachineLearningServices/workspaces/codes/versions@2022-05-01' = {
  name: '${workspaceName}/${codeId}-${uniqueString(storage::blobService::container.id)}/${codeVersion}'
  properties: {
    codeUri: uri(_artifactsLocation, 'data/${_artifactsLocationSasToken}')
    isAnonymous: false
  }
}

// output the codeId from codeVersion resource
output codeId string = codeVersionResource.id
