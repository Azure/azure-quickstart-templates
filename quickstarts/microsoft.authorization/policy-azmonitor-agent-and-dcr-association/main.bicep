targetScope = 'subscription'

// PARAMETERS
param assignmentIdentityLocation string
param assignmentEnforcementMode string = 'Default'
param dcrResourceID string

// RESOURCES
module policy './policyDefinition.bicep' = {
  name: 'policy'
  params: {
    dcrResourceID: dcrResourceID
  }
}

module assignment './policyAssignment.bicep' = {
  name: 'assignment'
  params: {
    monitoringGovernanceId: policy.outputs.monitoringGovernanceId
    assignmentIdentityLocation: assignmentIdentityLocation
    assignmentEnforcementMode: assignmentEnforcementMode
  }
}
