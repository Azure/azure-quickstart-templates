@description('Specifies the name of the Azure Machine Learning workspace where the command job will be created.')
param workspaceName string

@description('Specifies the location for all resources.')
param location string = resourceGroup().location

@description('Specifies the name of the Azure Machine Learning compute instance/cluster on which job will be run.')
param computeName string

@description('Specifies the name of the Azure Machine Learning experiment under which job will be created.')
param experimentName string

@description('The name for the storage account to created and associated with the workspace.')
param storageAccountName string

@description('Specifies the name of the Azure Machine Learning job to be created.')
param jobName string

var compute = resourceId('Microsoft.MachineLearningServices/workspaces/computes', workspaceName, computeName)

@description('Specifies the curated environment to run sweep job.')
param environmentName string = 'AzureML-lightgbm-3.2-ubuntu18.04-py37-cpu'

resource environmemt 'Microsoft.MachineLearningServices/workspaces/environments@2022-05-01' existing = {
  name: '${workspaceName}/${environmentName}'
}

resource jobResource 'Microsoft.MachineLearningServices/workspaces/jobs@2022-06-01-preview' = {
  name: '${workspaceName}/${jobName}'
  properties: {
    jobType: 'Command'
    experimentName: experimentName
    command: 'echo "hello_world"'
    environmentId: resourceId('Microsoft.MachineLearningServices/workspaces/environments/versions', workspaceName, environmentName, environmemt.properties.latestVersion)
    computeId: compute
  }
}

output Job_Studio_Endpoint string = jobResource.properties.services.Studio.endpoint
