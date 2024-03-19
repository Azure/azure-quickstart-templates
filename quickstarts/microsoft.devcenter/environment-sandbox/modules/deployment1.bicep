param resourceLocation string
param devcenterName string
param projectName string
param environmentTypeName string
param principalId string
param guidSeed string

resource devcenter 'Microsoft.DevCenter/devcenters@2023-04-01' = {
  name: devcenterName
  location: resourceLocation
  identity: {
    type: 'SystemAssigned'
  }
}

resource catalog 'Microsoft.DevCenter/devcenters/catalogs@2023-04-01' = {
  parent: devcenter
  name: 'quickstart-environment-definitions'
  properties: {
    gitHub: {
      uri: 'https://github.com/microsoft/devcenter-catalog.git'
      branch: 'main'
      path: 'Environment-Definitions'
    }
  }
}

resource devcenterEnvironmentType 'Microsoft.DevCenter/devcenters/environmentTypes@2023-04-01' = {
  parent: devcenter
  name: environmentTypeName
}

resource project 'Microsoft.DevCenter/projects@2023-04-01' = {
  name: projectName
  location: resourceLocation
  dependsOn: [
    devcenterEnvironmentType
  ]
  properties: {
    devCenterId: devcenter.id
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: project
  name: guid('Deployment Environment User', guidSeed)
  properties: {
    description: 'Provides access to manage environment resources.'
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '18e40d4e-8d2e-438d-97e1-9528336e149c')
  }
}

resource projectEnvironmentType 'Microsoft.DevCenter/projects/environmentTypes@2023-04-01' = {
  parent: project
  name: environmentTypeName
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    status: 'Enabled'
    deploymentTargetId: subscription().id
    creatorRoleAssignment: {
      roles: {
        '8e3af657-a8ff-443c-a75c-2fe8c4bcb635': {}
      }
    }
  }
}
