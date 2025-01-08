targetScope = 'managementGroup'

@description('An Array of Target Management Group')
param targetMGs array

@description('An array of the allowed locations, all other locations will be denied by the created policy.')
param allowedLocations array = [
  'australiaeast'
  'australiasoutheast'
  'australiacentral'
]

var policyDefinitionName = 'LocationRestriction'
resource policyDef 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: policyDefinitionName  
  properties: {
    policyType: 'Custom'
    mode: 'All'
    parameters: {}
    policyRule: {
      if: {
        not: {
          field: 'location'
          in: allowedLocations
        }
      }
      then: {
        effect: 'deny'
      }
    }
  }
}

module getManagementGroupNameDeploy 'modules/empty.bicep' = {
  // temporary fix
  // this is a no-op to get the name of the managementGroup for the policyDefintion, i.e. the name of the mg for this deployment'
  name: 'getManagementGroupName'
  scope: managementGroup()
}

module assignmentLoop 'modules/location-lock-assignment.bicep' = [for targetMG in targetMGs: {
  name: 'deploy-assignment-to-${targetMG}'
  scope: managementGroup(targetMG)
  params: {
    policyDefinitionId: extensionResourceId(tenantResourceId('Microsoft.Management/managementGroups', split(reference(getManagementGroupNameDeploy.name, '2020-10-01', 'Full').scope, '/')[2]), 'Microsoft.Authorization/policyDefinitions', policyDefinitionName)
  }
}]
