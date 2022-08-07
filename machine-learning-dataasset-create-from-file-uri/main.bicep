@description('Specifies the name of the Azure Machine Learning workspace which will hold this data asset.')
param workspaceName string

@description('Specifies the name of the data container asset.')
param dataContainerName string

@description('Specifies the name of the data version.')
param dataVersionName string = '1'

@description('Specifies the type of data: mltable, uri_file, or uri_folder.')
@allowed([
  'mltable'
  'uri_file'
  'uri_folder'
])
param dataType string = 'uri_file'

@description('Specifies a URI for the data')
param dataUri string = 'https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2022-04.parquet'

@description('Optional: Description of the data asset.')
param dataDescription string = 'Sample data asset'

@description('Optional: Is the asset archived?')
param isArchived bool = false

resource dc 'Microsoft.MachineLearningServices/workspaces/data@2022-05-01' = {
  name: '${workspaceName}/${dataContainerName}'
  properties: {
    dataType: dataType
    isArchived: isArchived
  }
}

resource dv 'Microsoft.MachineLearningServices/workspaces/data/versions@2022-05-01' = {
  name: '${workspaceName}/${dataContainerName}/${dataVersionName}'
  dependsOn: [dc]
  properties: {
    dataType: dataType
    dataUri: dataUri
    isArchived: isArchived
    description: dataDescription    
  }
}
