// Assigns the necessary roles to the AI project

param UAIPrincipalId string
param suffix string

// Documentation: https://learn.microsoft.com/en-us/azure/ai-studio/concepts/rbac-ai-studio#azure-ai-administrator-role
resource openAIAdmin 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'b78c5d69-af96-48a3-bf8d-a8b4d589de94'
  scope: resourceGroup()
}

resource openAIContributorContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(suffix, openAIAdmin.id, resourceGroup().id)
  properties: {
    principalId: UAIPrincipalId
    roleDefinitionId: openAIAdmin.id
    principalType: 'ServicePrincipal'
  }
}
