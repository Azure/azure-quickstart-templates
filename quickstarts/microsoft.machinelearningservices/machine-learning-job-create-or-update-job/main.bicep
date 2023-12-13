@description('Specifies the name of the Azure Machine Learning workspace where the command job will be created.')
param workspaceName string

@description('Specifies the name of the Azure Machine Learning compute instance/cluster on which job will be run.')
param computeName string

@description('Specifies the name of the Azure Machine Learning experiment under which job will be created.')
param experimentName string

@description('Specifies the name of the Azure Machine Learning job to be created.')
param jobName string

@description('Specifies the curated environment to run sweep job.')
param environmentName string = 'AzureML-lightgbm-3.2-ubuntu18.04-py37-cpu'

resource environment 'Microsoft.MachineLearningServices/workspaces/environments@2022-05-01' existing = {
  name: '${workspaceName}/${environmentName}'
}

resource environmentVersion 'Microsoft.MachineLearningServices/workspaces/environments/versions@2022-05-01' existing = {
  parent: environment
  name: environment.properties.latestVersion
}

resource compute 'Microsoft.MachineLearningServices/workspaces/computes@2022-05-01' existing = {
  name: '${workspaceName}/${computeName}'
}

resource jobResource 'Microsoft.MachineLearningServices/workspaces/jobs@2022-10-01' = {
  name: '${workspaceName}/${jobName}'
  properties: {
    jobType: 'Command'
    experimentName: experimentName
    command: 'echo "hello_world"'
    environmentId: environmentVersion.id
    computeId: compute.id
  }
}

output Job_Studio_Endpoint string = jobResource.properties.services.Studio.endpoint
