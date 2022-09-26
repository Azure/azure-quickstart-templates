@description('Specifies the name of the Azure Machine Learning workspace where the command job will be created.')
param workspaceName string

@description('Specifies the location for all resources.')
param location string = resourceGroup().location

@description('Specifies the name of the Azure Machine Learning compute instance/cluster on which job will be run.')
param computeName string

@description('Specifies the name of the Azure Machine Learning experiment name for the job.')
param experimentName string

@description('Specifies the name of the Azure Machine Learning job name.')
param jobName string

@description('Specifies the name of the Azure Machine Learning experiment under which job will be created.')
param experimentName string

@description('The name for the storage account to created and associated with the workspace.')
param storageAccountName string

@description('Specifies the name of the Azure Machine Learning job to be created.')
param jobName string

// creating codeVersion resource
module codeVersion 'modules/codeversion.bicep' = {
  name: 'blob'
  params: {
    location: location
    workspaceName: workspaceName
    storageAccountName: storageAccountName
  }
}

// param environmentId string
@description('Specifies the curated environment to run sweep job.')
param environmentName string = 'AzureML-lightgbm-3.2-ubuntu18.04-py37-cpu'

// fetching existing curated environment resource object
resource environmemt 'Microsoft.MachineLearningServices/workspaces/environments@2022-05-01' existing = {
  name: '${workspaceName}/${environmentName}'
}

var compute = resourceId('Microsoft.MachineLearningServices/workspaces/computes', workspaceName, computeName)

resource environmentResource 'Microsoft.MachineLearningServices/workspaces/environments@2022-06-01-preview' = {
  name: '${workspaceName}/baseEnvironment'
  properties: {
    description: 'The base environment to be used'
    properties: {
      name: 'AzureML-ACPT-pytorch-1.11-py38-cuda11.3-gpu'
      version: '3'
      asset: 'azureml://registries/azureml/environments/AzureML-ACPT-pytorch-1.11-py38-cuda11.3-gpu/versions/3'
    }
  }
}

resource jobResource 'Microsoft.MachineLearningServices/workspaces/jobs@2022-06-01-preview' = {
  name: '${workspaceName}/${jobName}'
  properties: {
    jobType: 'Command'
    experimentName: experimentName
    command: 'python hello_world.py'
    codeId: codeVersion.outputs.codeId
    environmentId: resourceId('Microsoft.MachineLearningServices/workspaces/environments/versions', workspaceName, environmentName, environmemt.properties.latestVersion)
    computeId: compute
  }
}

output Job_Studio_Endpoint string = jobResource.properties.services.Studio.endpoint
