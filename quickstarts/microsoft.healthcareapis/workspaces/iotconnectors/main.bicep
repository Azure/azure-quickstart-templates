@description('Basename that is used to name provisioned resources. Should be alphanumeric, at least 3 characters and up to or less than 16 characters.')
@minLength(3)
@maxLength(16)
param basename string

@description('The location where the resources are deployed. This can be a different Azure region than where the resource group was deployed. For a list of Azure regions where Azure Health Data Services are available, see [Products available by regions](https://azure.microsoft.com/explore/global-infrastructure/products-by-region/?products=health-data-services)')
@allowed([
  'australiaeast'
  'canadacentral'
  'centralindia'
  'eastus'
  'eastus2'
  'francecentral'
  'germanywestcentral'
  'japaneast'
  'koreacentral'
  'northcentralus'
  'northeurope'
  'qatarcentral'
  'southcentralus'
  'southeastasia'
  'swedencentral'
  'switzerlandnorth'
  'westcentralus'
  'westeurope'
  'westus2'
  'westus3'
  'uksouth'
])
param location string

@description('The mapping JSON that determines how incoming device data is normalized.')
param deviceMapping object = {
  templateType: 'CollectionContent'
  template: []
}

@description('The mapping JSON that determines how normalized data is converted into FHIR Observations.')
param destinationMapping object = {
  templateType: 'CollectionFhir'
  template: []
}

var fhirWriterRoleId = resourceId('Microsoft.Authorization/roleDefinitions', '3f88fce4-5892-4214-ae73-ba5294559913')
var eventHubReceiverRoleId = resourceId('Microsoft.Authorization/roleDefinitions', 'a638d3c7-ab3a-418d-83e6-5f17a39d4fde')

resource eventhubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: 'en-${basename}'
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
    disableLocalAuth: true
  }
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2021-11-01' = {
  name: 'devicedata'
  parent: eventhubNamespace
  properties: {
    messageRetentionInDays: 1
    partitionCount: 8
  }
}

resource eventHubAuthRule 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2021-11-01' = {
  name: 'devicedatasender'
  parent: eventHub
  properties: {
    rights: [
      'Send'
    ]
  }
}

resource workspace 'Microsoft.HealthcareApis/workspaces@2022-05-15' = {
  name: replace('hw-${basename}', '-', '')
  location: location
  properties: {
  }
}

resource fhirService 'Microsoft.HealthcareApis/workspaces/fhirservices@2022-05-15' = {
  name: 'fs-${basename}'
  parent: workspace
  location: location
  kind: 'fhir-R4'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    authenticationConfiguration: {
      authority: '${environment().authentication.loginEndpoint}${subscription().tenantId}'
      audience: 'https://${workspace.name}-fs-${basename}.fhir.azurehealthcareapis.com'
      smartProxyEnabled: false
    }
  }
}

resource iotConnector 'Microsoft.HealthcareApis/workspaces/iotconnectors@2022-05-15' = {
  name: 'hi-${basename}'
  parent: workspace
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    ingestionEndpointConfiguration: {
      eventHubName: eventHub.name
      consumerGroup: '$Default'
      fullyQualifiedEventHubNamespace: 'en-${basename}.servicebus.windows.net'
    }
    deviceMapping: {
      content: deviceMapping
    }
  }
}

resource fhirDestination 'Microsoft.HealthcareApis/workspaces/iotconnectors/fhirdestinations@2022-05-15' = {
  name: 'hd-${basename}'
  parent: iotConnector
  location: location
  properties: {
    resourceIdentityResolutionType: 'Create'
    fhirServiceResourceId: fhirService.id
    fhirMapping: {
      content: destinationMapping
    }
  }
}

resource FhirWriter 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: fhirService
  name: guid(fhirWriterRoleId, iotConnector.id, fhirService.id)
  properties: {
    roleDefinitionId: fhirWriterRoleId
    principalId: iotConnector.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource EventHubDataReceiver 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: eventHub
  name: guid(eventHubReceiverRoleId, iotConnector.id, eventHub.id)
  properties: {
    roleDefinitionId: eventHubReceiverRoleId
    principalId: iotConnector.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
