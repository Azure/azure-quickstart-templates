@description('Specifies the name of the Azure Machine Learning workspace where job will be created.')
param workspaceName string

@description('Specifies the name of the Azure Machine Learning compute instance/cluster on which job will be run.')
param computeName string

@description('Specifies the name of the Azure Machine Learning experiment under which job will be created.')
param experimentName string

@description('Specifies the name of the Azure Machine Learning job to be created.')
param jobName string

@description('The base URI where artifacts required by this template are located including a trailing \'/\'.')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.')
@secure()
param _artifactsLocationSasToken string = ''

@description('Specifies execution contraints for the job.')
param limitSettings object = {
  maxTrials: 5
  maxConcurrentTrials: 1
  maxCoresPerTrial: -1
  enableEarlyTermination: true
  timeout: 'PT10H'
  trialTimeout: 'PT20M'
}

@description('Specifies training related configuration for the job.')
param trainingSettings object = {
  blockedTrainingAlgorithms: [
    'LogisticRegression'
  ]
  enableModelExplainability: true
  enableOnnxCompatibleModels: false
  enableStackEnsemble: true
  enableVoteEnsemble: true
  ensembleModelDownloadTimeout: 'PT5M'
  enableDnnTraining: false
}

var compute = resourceId('Microsoft.MachineLearningServices/workspaces/computes', workspaceName, computeName)

resource jobResource 'Microsoft.MachineLearningServices/workspaces/jobs@2022-06-01-preview' = {
  name: '${workspaceName}/${jobName}'
  properties: {
    jobType: 'AutoML'
    tags: {
      referenceNotebook: 'https://github.com/Azure/azureml-examples/blob/main/sdk/jobs/automl-standalone-jobs/automl-classification-task-bankmarketing'
    }
    experimentName: experimentName
    computeId: compute
    taskDetails: {
      logVerbosity: 'Info'
      taskType: 'Classification'
      primaryMetric: 'Accuracy'
      targetColumnName: 'y'
      trainingData: {
        uri: uri(_artifactsLocation, 'data/training-mltable-folder/${_artifactsLocationSasToken}')
        jobInputType: 'MLTable'
      }
      validationData: {
        uri: uri(_artifactsLocation, 'data/validation-mltable-folder/${_artifactsLocationSasToken}')
        jobInputType: 'MLTable'
      }
      featurizationSettings: {
        mode: 'auto'
      }
      limitSettings: limitSettings
      trainingSettings: trainingSettings
    }
  }
}

output Job_Studio_Endpoint string = jobResource.properties.services.Studio.endpoint
