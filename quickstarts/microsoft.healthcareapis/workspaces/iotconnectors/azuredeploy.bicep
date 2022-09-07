@description('Base name that is used to name provisioned resources. Should be alphanumeric, at least 3 characters and up to or less than 16 characters.')
@minLength(3)
@maxLength(16)
param basename string

@description('The location where the resources(s) are deployed. This can be a different Azure region than where the Resource Group was deployed.')
@allowed([
  'australiaeast'
  'canadacentral'
  'centralindia'
  'eastus'
  'eastus2'
  'germanywestcentral'
  'japaneast'
  'northcentralus'
  'northeurope'
  'southafricanorth'
  'southcentralus'
  'southeastasia'
  'switzerlandnorth'
  'uksouth'
  'ukwest'
  'westcentralus'
  'westeurope'
  'westus2'
  'westus3'
])
param location string

@description('The mapping JSON that determines how incoming device data is normalized.')
param deviceMapping object = {
  templateType: 'CollectionContent'
  template: []
}

@description('The mapping JSON that determines how normalized data is converted to FHIR Observations.')
param destinationMapping object = {
  templateType: 'CollectionFhir'
  template: []
}

var eventHubName = 'devicedata'
var eventhubNamespaceName = 'en-${basename}'
var eventHubFullName = '${eventhubNamespaceName}/${eventHubName}'
var eventHubAuthRuleName = '${eventHubFullName}/devicedatasender'
var workspaceName = replace('hw-${basename}', '-', '')
var fhirServiceName = '${workspaceName}/fs-${basename}'
var iotConnectorName = '${workspaceName}/hi-${basename}'
var fhirDestinationName = '${iotConnectorName}/hd-${basename}'
var fhirServiceResourceId = resourceId('Microsoft.HealthcareApis/workspaces/fhirservices', workspaceName, split(fhirServiceName, '/')[1])
var iotConnectorResourceId = resourceId('Microsoft.HealthcareApis/workspaces/iotconnectors', workspaceName, split(iotConnectorName, '/')[1])
var fhirWriterRoleId = resourceId('Microsoft.Authorization/roleDefinitions', '3f88fce4-5892-4214-ae73-ba5294559913')
var eventHubReceiverRoleId = resourceId('Microsoft.Authorization/roleDefinitions', 'a638d3c7-ab3a-418d-83e6-5f17a39d4fde')

resource eventhubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: eventhubNamespaceName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 2
  }
  properties: {
    zoneRedundant: true
    isAutoInflateEnabled: true
    maximumThroughputUnits: 8
    kafkaEnabled: false
  }
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  name: eventHubFullName
  properties: {
    messageRetentionInDays: 1
    partitionCount: 8
  }
  dependsOn: [
    eventhubNamespace
  ]
}

resource eventHubAuthRule 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2021-11-01' = {
  name: eventHubAuthRuleName
  properties: {
    rights: [
      'Send'
    ]
  }
  dependsOn: [
    eventHub
  ]
}

resource workspace 'Microsoft.HealthcareApis/workspaces@2022-05-15' = {
  name: workspaceName
  location: location
  properties: {
  }
}

resource fhirService 'Microsoft.HealthcareApis/workspaces/fhirservices@2022-05-15' = {
  name: fhirServiceName
  location: location
  kind: 'fhir-R4'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    authenticationConfiguration: {
      authority: '${environment().authentication.loginEndpoint}${subscription().tenantId}'
      audience: 'https://${workspaceName}-fs-${basename}.fhir.azurehealthcareapis.com'
      smartProxyEnabled: false
    }
  }
  dependsOn: [
    workspace
  ]
}

resource iotConnector 'Microsoft.HealthcareApis/workspaces/iotconnectors@2022-05-15' = {
  name: iotConnectorName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    ingestionEndpointConfiguration: {
      eventHubName: eventHubName
      consumerGroup: '$Default'
      fullyQualifiedEventHubNamespace: 'en-${basename}.servicebus.windows.net'
    }
    deviceMapping: {
      content: deviceMapping
    }
  }
  dependsOn: [
    workspace
  ]
}

resource fhirDestination 'Microsoft.HealthcareApis/workspaces/iotconnectors/fhirdestinations@2022-05-15' = {
  name: fhirDestinationName
  location: location
  properties: {
    resourceIdentityResolutionType: 'Create'
    fhirServiceResourceId: fhirServiceResourceId
    fhirMapping: {
      content: destinationMapping
    }
  }
  dependsOn: [
    workspace
    iotConnector
  ]
}

resource FhirWriter 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: fhirService
  name: guid('${resourceGroup().id}-FhirWriter')
  properties: {
    roleDefinitionId: fhirWriterRoleId
    principalId: reference(iotConnectorResourceId, '2022-05-15', 'Full').identity.principalId
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    iotConnector
  ]
}

resource EventHubDataReceiver 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: eventHub
  name: guid('${resourceGroup().id}-EventHubDataReceiver')
  properties: {
    roleDefinitionId: eventHubReceiverRoleId
    principalId: reference(iotConnectorResourceId, '2022-05-15', 'Full').identity.principalId
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    iotConnector
  ]
}
