targetScope = 'subscription'

@description('The resource ID of the existing virtual enclave whose network will be joined.')
param virtualEnclaveResourceId string

var virtualEnclaveResourceIdSegments = split(virtualEnclaveResourceId, '/')
var virtualEnclaveResourceIdIsValid = length(virtualEnclaveResourceIdSegments) == 9 && empty(virtualEnclaveResourceIdSegments[0]) && toLower(virtualEnclaveResourceIdSegments[1]) == 'subscriptions' && !empty(virtualEnclaveResourceIdSegments[2]) && toLower(virtualEnclaveResourceIdSegments[3]) == 'resourcegroups' && !empty(virtualEnclaveResourceIdSegments[4]) && toLower(virtualEnclaveResourceIdSegments[5]) == 'providers' && toLower(virtualEnclaveResourceIdSegments[6]) == 'microsoft.mission' && toLower(virtualEnclaveResourceIdSegments[7]) == 'virtualenclaves' && !empty(virtualEnclaveResourceIdSegments[8])
var validatedVirtualEnclaveResourceId = virtualEnclaveResourceIdIsValid
  ? virtualEnclaveResourceId
  : fail('The virtual enclave resource ID is invalid. Expected /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Mission/virtualEnclaves/{name}.')
var validatedVirtualEnclaveResourceIdSegments = split(validatedVirtualEnclaveResourceId, '/')
var virtualEnclaveSubscriptionId = validatedVirtualEnclaveResourceIdSegments[2]
var virtualEnclaveResourceGroupName = validatedVirtualEnclaveResourceIdSegments[4]
var virtualEnclaveName = validatedVirtualEnclaveResourceIdSegments[8]

#disable-next-line BCP081
resource virtualEnclave 'Microsoft.Mission/virtualEnclaves@2026-03-01-preview' existing = {
  name: virtualEnclaveName
  scope: resourceGroup(virtualEnclaveSubscriptionId, virtualEnclaveResourceGroupName)
}

var maintenanceMode = toLower(virtualEnclave.properties.?maintenanceModeConfiguration.?mode ?? '')
var networkJoinAllowed = contains([
  'general'
  'advanced'
], maintenanceMode)

output validatedVirtualEnclaveResourceId string = networkJoinAllowed
  ? validatedVirtualEnclaveResourceId
  : fail('The selected virtual enclave must use General maintenance mode with the deploying identity listed in maintenance mode principals, or Advanced maintenance mode, before this deployment can attach resources to its virtual network. Current mode: ${empty(maintenanceMode) ? 'unknown' : maintenanceMode}.')
