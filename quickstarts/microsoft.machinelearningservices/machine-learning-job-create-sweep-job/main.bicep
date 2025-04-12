// Sweep Job Resource using ARM Template
@description('Specifies the location for all resources.')
param location string = resourceGroup().location

@description('Specifies the name of the Azure Machine Learning workspace where sweep job will be deployed')
param workspaceName string

@description('Specifies the unique name for sweep job.')
param jobName string

@description('Specifies the name of the Azure Machine Learning amlcompute cluster on which job will be run.')
param computeName string

@description('The name for the storage account to created and associated with the workspace.')
param storageAccountName string

@description('Specifies the name of the Azure Machine Learning experiment under which job will be created.')
param experimentName string

@description('The base URI where artifacts required by this template are located including a trailing \'/\'.')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.')
@secure()
param _artifactsLocationSasToken string = ''

@description('Specifies dictionary of inputs search for sweep job.')
param inputs object = {
  iris_csv: {
    mode: 'ReadOnlyMount'
    uri: uri(_artifactsLocation, 'data/iris.csv${_artifactsLocationSasToken}')
    jobInputType: 'uri_file'
  }
}

@description('Specifies execution contraints for sweep job.')
param limits object = {
  jobLimitsType: 'Sweep'
  timeout: 'PT20M'
  trialTimeout: 'PT50S'
  maxConcurrentTrials: 3
  maxTotalTrials: 5
}

@description('Specifies objective for sweep job.')
param objective object = {
  goal: 'maximize'
  primaryMetric: 'result'
}

@description('Specifies sampling algorithm for sweep job.')
param samplingAlgorithmType string = 'Random'

@description('Specifies different search space for sweep job.')
param searchSpace object = {
  learning_rate: [ 'uniform', [ json('0.01'), json('0.9') ] ]
  boosting: [ 'choice', [ [ 'gbdt', 'dart' ] ] ]
}

@description('Specifies command to be executed by trials of sweep job.')
param command string = '''python main.py --iris-csv ${{inputs.iris_csv}} --learning-rate ${{search_space.learning_rate}} --boosting ${{search_space.boosting}}'''

@description('Specifies the curated environment to run sweep job.')
param environmentName string = 'AzureML-lightgbm-3.2-ubuntu18.04-py37-cpu'

// creating codeVersion resource
module codeVersion 'modules/codeversion.bicep' = {
  name: 'blob'
  params: {
    location: location
    workspaceName: workspaceName
    storageAccountName: storageAccountName
  }
}

// fetching existing curated environment resource object
resource environmemt 'Microsoft.MachineLearningServices/workspaces/environments@2022-05-01' existing = {
  name: '${workspaceName}/${environmentName}'
}

// creating sweep job resource
resource sweepjobResource 'Microsoft.MachineLearningServices/workspaces/jobs@2022-06-01-preview' = {
  name: '${workspaceName}/${jobName}'
  properties: {
    description: 'Sweep Job Resource from ARM Template'
    properties: {}
    tags: {
      referenceNotebook: 'https://github.com/Azure/azureml-examples/blob/main/sdk/jobs/single-step/lightgbm/iris/lightgbm-iris-sweep.ipynb'
    }
    computeId: resourceId('Microsoft.MachineLearningServices/workspaces/computes', workspaceName, computeName)
    displayName: 'Sweep Job Resource'
    experimentName: experimentName
    isArchived: false
    jobType: 'Sweep'
    inputs: inputs
    limits: limits
    objective: objective
    samplingAlgorithm: {
      samplingAlgorithmType: samplingAlgorithmType
    }
    searchSpace: searchSpace
    trial: {
      codeId: codeVersion.outputs.codeId
      command: command
      environmentId: resourceId('Microsoft.MachineLearningServices/workspaces/environments/versions', workspaceName, environmentName, environmemt.properties.latestVersion)
      environmentVariables: {}
    }
  }
}

// output the azure machine learning studio experiment url
output Job_Studio_Endpoint string = sweepjobResource.properties.services.Studio.endpoint
