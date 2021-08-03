targetScope = 'subscription'

// PARAMETERS
param monitoringGovernanceId string
param assignmentIdentityLocation string
param assignmentEnforcementMode string

// RESOURCES
resource monitoringGovernanceAssignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: 'monitoringGovernance'
  location: assignmentIdentityLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: 'Monitoring Governance Assignment'
    description: 'Monitoring Governance Assignment'
    enforcementMode: assignmentEnforcementMode
    metadata: {
      source: 'Bicep'
      version: '0.1.0'
    }
    policyDefinitionId: monitoringGovernanceId
    nonComplianceMessages: [
      {
        message: 'Resource is not compliant with the Monitoring Governance Assignment DeployIfNotExists policy'
      }
    ]
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(monitoringGovernanceAssignment.name, monitoringGovernanceAssignment.type, subscription().subscriptionId)
  properties: {
    principalId: monitoringGovernanceAssignment.identity.principalId
    roleDefinitionId: '/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c' // contributor RBAC role for deployIfNotExists effect
  }
}
