@description(' sample description')
param resourceSymbolicName string


resource symbolicname 'Microsoft.Maintenance/configurationAssignments@2023-04-01' = {
  name: 'string'
  location: 'string'
  scope: resourceSymbolicName
  properties: {
    filter: {
      locations: [
        'string'
      ]
      osTypes: [
        'string'
      ]
      resourceGroups: [
        'string'
      ]
      resourceTypes: [
        'string'
      ]
      tagSettings: {
        filterOperator: 'string'
        tags: {}
      }
    }
    maintenanceConfigurationId: 'string'
    resourceId: 'string'
  }
}
