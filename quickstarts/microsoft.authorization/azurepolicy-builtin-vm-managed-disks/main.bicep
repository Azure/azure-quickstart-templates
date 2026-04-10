@description('Policy assignment name used in assignment\'s resource ID')
param policyAssignmentName string = 'audit-vm-managed-disks'

@description('Policy definition ID')
param policyDefinitionID string = '/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d'

@description('Display name for Azure portal')
param policyDisplayName string = 'Audit VM managed disks'

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2023-04-01' = {
  name: policyAssignmentName
  properties: {
    policyDefinitionId: policyDefinitionID
    description: 'Policy assignment to resource group scope created with ARM template'
    displayName: policyDisplayName
    nonComplianceMessages: [
      {
        message: 'Virtual machines should use managed disks'
      }
    ]
  }
}

output assignmentId string = policyAssignment.id
