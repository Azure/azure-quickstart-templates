@description('Specifies the name of the Azure Machine Learning workspace where sweep job will be deployed')
param workspaceName string

@description('Name of the blob container')
param containerName string = 'workspaceblobstore'

@description('Desired name of the storage account')
param storageAccountName string

@description('Specifies the env version for sweep job.')
param codeVersion string = '1'

@description('Specifies the env for command job.')
param codeId string = 'code'

@description('The base URI where artifacts required by this template are located including a trailing \'/\'.')
param _artifactsLocation string

@description('The sasToken required to access _artifactsLocation.')
@secure()
param _artifactsLocationSasToken string

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' existing = {
  name: '${storageAccountName}/default/${containerName}'
}

// creating codeVersion resource for command job
resource codeVersionResource 'Microsoft.MachineLearningServices/workspaces/codes/versions@2022-05-01' = {
  name: '${workspaceName}/${codeId}-${uniqueString(container.id)}/${codeVersion}'
  properties: {
    codeUri: uri(_artifactsLocation, 'data/${_artifactsLocationSasToken}')
    isAnonymous: false
  }
}

// output the codeId from codeVersion resource
output codeVersionResourceId string = codeVersionResource.id
