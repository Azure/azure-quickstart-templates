param existingDataFactoryName string
param IntegrationRuntimeName string

resource integrationRuntime 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  name: '${existingDataFactoryName}/${IntegrationRuntimeName}'
  properties: {
    type: 'SelfHosted'
    description: 'Self-hosted Integration runtime created using ARM template'
  }
}

output irId string = integrationRuntime.id
