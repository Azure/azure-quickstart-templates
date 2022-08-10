@description('Specifies the name of the Azure Machine Learning workspace which will hold this data asset.')
param workspaceName string

@description('Specifies the name of the data container asset.')
param dataContainerName string

@description('Specifies the name of the data version.')
param dataVersionName string

@description('Specifies the type of data: mltable, uri_file, or uri_folder.')
@allowed([
  'mltable'
  'uri_file'
  'uri_folder'
])
param dataType string = 'uri_file'

@description('Specifies a URI for the data, for testing purposes use: https://azbotstorage.blob.core.windows.net/sample-artifacts/yellow_tripdata_2022-04.parquet')
param dataUri string

@description('Optional: Description of the data asset.')
param dataDescription string = 'Sample data asset'

@description('Optional: Is the asset archived?')
param isArchived bool = false

resource dv 'Microsoft.MachineLearningServices/workspaces/data/versions@2022-05-01' = {
  name: '${workspaceName}/${dataContainerName}/${dataVersionName}'
  properties: {
    dataType: dataType
    dataUri: dataUri
    isArchived: isArchived
    description: dataDescription    
  }
}
