@description('Specifies the name of the Azure Machine Learning workspace where the command job will be created.')
param workspaceName string

@description('Specifies the name of the Azure Machine Learning compute instance/cluster on which job will be run.')
param computeName string

@description('Specifies the name of the Azure Machine Learning experiment under which job will be created.')
param experimentName string

@description('Specifies the name of the Azure Machine Learning job to be created.')
param jobName string

var compute = resourceId('Microsoft.MachineLearningServices/workspaces/computes', workspaceName, computeName)

resource jobResource 'Microsoft.MachineLearningServices/workspaces/jobs@2022-06-01-preview' = {
  name: '${workspaceName}/${jobName}'
  properties: {
    jobType: 'Command'
    experimentName: experimentName
    command: 'python hello_gdl.py'
    environmentId: 'azureml://registries/azureml/environments/AzureML-ACPT-pytorch-1.11-py38-cuda11.3-gpu/versions/2'
    computeId: compute
  }
}

output Job_Studio_Endpoint string = jobResource.properties.services.Studio.endpoint
