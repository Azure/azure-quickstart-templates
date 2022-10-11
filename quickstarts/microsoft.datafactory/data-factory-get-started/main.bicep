@description('Data Factory Name')
param dataFactoryName string = 'datafactory${uniqueString(resourceGroup().id)}'

@description('Location of the data factory.')
param location string = resourceGroup().location

var contentUri = uri('https://azbotstorage.blob.${environment().suffixes.storage}', '/sample-artifacts/data-factory/moviesDB2.csv')
var csvFilename = last(split(contentUri, '/'))
var storageAccountName = 'storage${uniqueString(resourceGroup().id)}'
var dataFactoryLinkedServiceName = 'ArmtemplateStorageLinkedService'
var dataFactoryDataSetInName = 'ArmtemplateTestDatasetIn'
var dataFactoryDataSetOutName = 'ArmtemplateTestDatasetOut'
var pipelineName = 'ArmtemplateSampleCopyPipeline'
var csvInputFolder = 'input'
var csvOutputFolder = 'output'
var blobContainerName = 'datafactory'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: '${storageAccountName}/default/${blobContainerName}'
  dependsOn: [
    storageAccount
  ]
}

resource runPowerShellInlineWithOutput 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'copyFile'
  location: location
  kind: 'AzurePowerShell'
  dependsOn: [
    blobContainer
  ]
  properties: {
    azPowerShellVersion: '8.0'
    environmentVariables: [
      {
        name: 'storageKey'
        secureValue: storageAccount.listKeys().keys[0].value
      }
      {
        name: 'SAName'
        value: storageAccountName
      }
      {
        name: 'ContainerName'
        value: blobContainerName
      }
      {
        name: 'contentUri'
        value: contentUri
      }
      {
        name: 'csvFileName'
        value: csvFilename
      }
      {
        name: 'csvInputFolder'
        value: csvInputFolder
      }
    ]
    scriptContent: loadTextContent('./scripts/copy-data.ps1')
    timeout: 'PT1H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}

resource linkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: dataFactory
  name: dataFactoryLinkedServiceName
  properties: {
    type: 'AzureBlobStorage'
    typeProperties: {
      connectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.listKeys().keys[0].value}'
    }
  }
}

resource datasetIn 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactory
  name: dataFactoryDataSetInName
    dependsOn: [
    linkedService
  ]
  properties: {
    linkedServiceName: {
      referenceName: dataFactoryLinkedServiceName
      type: 'LinkedServiceReference'
    }
    type: 'Binary'
    typeProperties: {
      location: {
        type: 'AzureBlobStorageLocation'
        container: blobContainerName
        folderPath: csvInputFolder
        fileName: csvFilename
      }
    }
  }
}

resource datasetOut 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactory
  name: dataFactoryDataSetOutName
    dependsOn: [

    linkedService
  ]
  properties: {
    linkedServiceName: {
      referenceName: dataFactoryLinkedServiceName
      type: 'LinkedServiceReference'
    }
    type: 'Binary'
    typeProperties: {
      location: {
        type: 'AzureBlobStorageLocation'
        container: blobContainerName
        folderPath: csvOutputFolder
      }
    }
  }
}

resource pipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  parent: dataFactory
  name: pipelineName
    dependsOn: [
    datasetIn
    datasetOut
  ]
  properties: {
    activities: [
      {
        name: 'MyCopyActivity'
        type: 'Copy'
        typeProperties: {
          source: {
            type: 'BinarySource'
            storeSettings: {
              type: 'AzureBlobStorageReadSettings'
              recursive: true
            }
          }
          sink: {
            type: 'BinarySink'
            storeSettings: {
              type: 'AzureBlobStorageWriteSettings'
            }
          }
          enableStaging: false
        }
        inputs: [
          {
            referenceName: dataFactoryDataSetInName
            type: 'DatasetReference'
          }
        ]
        outputs: [
          {
            referenceName: dataFactoryDataSetOutName
            type: 'DatasetReference'
          }
        ]
      }
    ]
  }
}
