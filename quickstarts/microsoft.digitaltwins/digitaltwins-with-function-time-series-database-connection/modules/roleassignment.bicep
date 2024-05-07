@description('Existing Digital Twin resource name')
param digitalTwinsName string

@description('The principal id associated with identity on the Digital Twins resource')
param digitalTwinsIdentityPrincipalId string

@description('The tenant id associated with identity on the Digital Twins resource')
param digitalTwinsIdentityTenantId string

@description('Existing Event Hubs namespace resource name')
param eventHubsNamespaceName string

@description('Existing event hub name')
param eventHubName string

@description('Existing Azure Data Explorer cluster resource name')
param adxClusterName string

@description('Existing database name')
param databaseName string

@description('The id that will be given data owner permission for the Digital Twins resource')
param principalId string

@description('The type of the given principal id')
param principalType string

// Azure RBAC Guid Source: https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var azureRbacContributor = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
var azureRbacAzureEventHubsDataOwner = 'f526a384-b230-433a-b45c-95f59c4a2dec'
var azureRbacAzureDigitalTwinsDataOwner = 'bcd981a7-7f74-457b-83e1-cceb9e632ffe'

// Gets Digital Twins resource
resource digitalTwins 'Microsoft.DigitalTwins/digitalTwinsInstances@2022-10-31' existing = {
  name: digitalTwinsName
}

// Gets event hub in Event Hubs namespace
resource eventhub 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' existing = {
  name: '${eventHubsNamespaceName}/${eventHubName}'
}

// Gets database under the Azure Data Explorer cluster
resource database 'Microsoft.Kusto/clusters/databases@2022-11-11' existing = {
  name: '${adxClusterName}/${databaseName}'
}

// Assigns the given principal id input data owner of Digital Twins resource
resource givenIdToDigitalTwinsRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(digitalTwins.id, principalId, azureRbacAzureDigitalTwinsDataOwner)
  scope: digitalTwins
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureRbacAzureDigitalTwinsDataOwner)
    principalType: principalType
  }
}

// Assigns Digital Twins resource data owner of event hub
resource digitalTwinsToEventHubRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(eventhub.id, principalId, azureRbacAzureEventHubsDataOwner)
  scope: eventhub
  properties: {
    principalId: digitalTwinsIdentityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureRbacAzureEventHubsDataOwner)
    principalType: 'ServicePrincipal'
  }
}

// Assigns Digital Twins resource admin assignment to database
resource digitalTwinsToDatabasePrincipalAssignment 'Microsoft.Kusto/clusters/databases/principalAssignments@2022-11-11' = {
  parent: database
  name: guid(database.id, principalId, 'Admin')
  properties: {
    principalId: digitalTwinsIdentityPrincipalId
    role: 'Admin'
    tenantId: digitalTwinsIdentityTenantId
    principalType: 'App'
  }
}

// Assigns Digital Twins resource contributor assignment to database
resource digitalTwinsToDatabaseRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(database.id, principalId, azureRbacContributor)
  scope: database
  properties: {
    principalId: digitalTwinsIdentityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureRbacContributor)
    principalType: 'ServicePrincipal'
  }
}
