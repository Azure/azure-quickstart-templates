@description('Specifies the name of the existing Azure Machine Learning workspace where the command job will be created.')
param workspaceName string

@description('Specifies the name of the existing Azure Machine Learning compute instance/cluster on which job will be run.')
param computeName string

@description('The name for the existing storage account to created and associated with the workspace.')
param storageAccountName string

@description('Specifies the name of the Azure Machine Learning experiment under which job will be created.')
param experimentName string = 'sampleExperiment'

@description('Specifies the name of the Azure Machine Learning job to be created.')
param jobName string = 'sampleJob'

@description('The base URI where artifacts required by this template are located including a trailing \'/\'.')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.')
@secure()
param _artifactsLocationSasToken string = ''

var compute = resourceId('Microsoft.MachineLearningServices/workspaces/computes', workspaceName, computeName)

// creating codeVersion resource
module codeVersion 'modules/codeversion.bicep' = {
  name: 'blob'
  params: {
    workspaceName: workspaceName
    storageAccountName: storageAccountName
    _artifactsLocation: _artifactsLocation
    _artifactsLocationSasToken: _artifactsLocationSasToken
  }
}

resource jobResource 'Microsoft.MachineLearningServices/workspaces/jobs@2022-06-01-preview' = {
  name: '${workspaceName}/${jobName}'
  properties: {
    jobType: 'Command'
    experimentName: experimentName
    command: 'python hello_world.py'
    codeId: codeVersion.outputs.codeVersionResourceId
    environmentId: codeVersion.outputs.codeVersionResourceId
    computeId: compute
  }
}

output Job_Studio_Endpoint string = jobResource.properties.services.Studio.endpoint
