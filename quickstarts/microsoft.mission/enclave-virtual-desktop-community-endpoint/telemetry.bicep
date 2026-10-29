param enableTelemetry bool
param name string

#disable-next-line no-deployments-resources
resource telemetryDeployment 'Microsoft.Resources/deployments@2024-03-01' = if (enableTelemetry) {
  name: name
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
      outputs: {
        telemetry: {
          type: 'String'
          value: ''
        }
      }
    }
  }
}
