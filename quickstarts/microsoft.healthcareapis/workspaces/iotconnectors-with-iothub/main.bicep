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

@description('OPTIONAL - A Principal ID for a user that will be granted FHIR Data Contributor access to the FHIR service. If you do not choose to use the **fhirContributorPrincipalId** option, clear the field of any entries. To learn more about how to acquire an Azure AD user object ID, see [Find the user object ID](https://learn.microsoft.com/partner-center/find-ids-and-domain-names#find-the-user-object-id)')
param fhirContributorPrincipalId string = ''

@description('The mapping JSON that determines how incoming device data is normalized.')
param deviceMapping object = {
  templateType: 'CollectionContent'
  template: [
    {
      templateType: 'IotJsonPathContent'
      template: {
        typeName: 'HeartRate'
        typeMatchExpression: '$..[?(@Body.HeartRate)]'
        patientIdExpression: '$.Body.PatientId'
        values: [
          {
            required: true
            valueExpression: '$.Body.HeartRate'
            valueName: 'HeartRate'
          }
        ]
      }
    }
    {
      templateType: 'IotJsonPathContent'
      template: {
        typeName: 'HeartRateVariability'
        typeMatchExpression: '$..[?(@Body.HeartRateVariability)]'
        patientIdExpression: '$.Body.PatientId'
        values: [
          {
            required: true
            valueExpression: '$.Body.HeartRateVariability'
            valueName: 'HeartRateVariability'
          }
        ]
      }
    }
    {
      templateType: 'IotJsonPathContent'
      template: {
        typeName: 'RespiratoryRate'
        typeMatchExpression: '$..[?(@Body.RespiratoryRate)]'
        patientIdExpression: '$.Body.PatientId'
        values: [
          {
            required: true
            valueExpression: '$.Body.RespiratoryRate'
            valueName: 'RespiratoryRate'
          }
        ]
      }
    }
    {
      templateType: 'IotJsonPathContent'
      template: {
        typeName: 'BodyTemperature'
        typeMatchExpression: '$..[?(@Body.BodyTemperature)]'
        patientIdExpression: '$.Body.PatientId'
        values: [
          {
            required: true
            valueExpression: '$.Body.BodyTemperature'
            valueName: 'BodyTemperature'
          }
        ]
      }
    }
    {
      templateType: 'IotJsonPathContent'
      template: {
        typeName: 'BloodPressure'
        typeMatchExpression: '$..[?(@Body.BloodPressure.Systolic && @Body.BloodPressure.Diastolic)]'
        patientIdExpression: '$.Body.PatientId'
        values: [
          {
            required: true
            valueExpression: '$.Body.BloodPressure.Systolic'
            valueName: 'Systolic'
          }
          {
            required: true
            valueExpression: '$.Body.BloodPressure.Diastolic'
            valueName: 'Diastolic'
          }
        ]
      }
    }
  ]
}

@description('The mapping JSON that determines how normalized data is converted into FHIR Observations.')
param destinationMapping object = {
  templateType: 'CollectionFhir'
  template: [
    {
      templateType: 'CodeValueFhir'
      template: {
        codes: [
          {
            system: 'http://loinc.org'
            code: '8867-4'
            display: 'Heart rate'
          }
        ]
        typeName: 'HeartRate'
        value: {
          system: 'http://unitsofmeasure.org'
          code: 'count/min'
          unit: 'count/min'
          valueName: 'HeartRate'
          valueType: 'Quantity'
        }
      }
    }
    {
      templateType: 'CodeValueFhir'
      template: {
        codes: [
          {
            system: 'http://loinc.org'
            code: '80404-7'
            display: 'R-R interval.standard deviation (Heart rate variability)'
          }
        ]
        typeName: 'HeartRateVariability'
        value: {
          system: 'http://unitsofmeasure.org'
          code: 'ms'
          unit: 'ms'
          valueName: 'HeartRateVariability'
          valueType: 'Quantity'
        }
      }
    }
    {
      templateType: 'CodeValueFhir'
      template: {
        codes: [
          {
            system: 'http://loinc.org'
            code: '9279-1'
            display: 'Respiratory rate'
          }
        ]
        typeName: 'RespiratoryRate'
        value: {
          system: 'http://unitsofmeasure.org'
          code: 'count/min'
          unit: 'count/min'
          valueName: 'RespiratoryRate'
          valueType: 'Quantity'
        }
      }
    }
    {
      templateType: 'CodeValueFhir'
      template: {
        codes: [
          {
            system: 'http://loinc.org'
            code: '8310-5'
            display: 'Body temperature'
          }
        ]
        typeName: 'BodyTemperature'
        value: {
          system: 'http://unitsofmeasure.org'
          code: 'degC'
          unit: 'degC'
          valueName: 'BodyTemperature'
          valueType: 'Quantity'
        }
      }
    }
    {
      templateType: 'CodeValueFhir'
      template: {
        codes: [
          {
            display: 'Blood pressure panel'
            code: '35094-2'
            system: 'http://loinc.org'
          }
        ]
        typeName: 'BloodPressure'
        components: [
          {
            codes: [
              {
                system: 'http://loinc.org'
                code: '8462-4'
                display: 'Diastolic blood pressure'
              }
            ]
            value: {
              system: 'http://unitsofmeasure.org'
              code: 'mmHg'
              unit: 'mmHg'
              valueName: 'Diastolic'
              valueType: 'Quantity'
            }
          }
          {
            codes: [
              {
                system: 'http://loinc.org'
                code: '8480-6'
                display: 'Systolic blood pressure'
              }
            ]
            value: {
              system: 'http://unitsofmeasure.org'
              code: 'mmHg'
              unit: 'mmHg'
              valueName: 'Systolic'
              valueType: 'Quantity'
            }
          }
        ]
      }
    }
  ]
}

var fhirWriterRoleId = resourceId('Microsoft.Authorization/roleDefinitions', '3f88fce4-5892-4214-ae73-ba5294559913')
var fhirContributorRoleId = resourceId('Microsoft.Authorization/roleDefinitions', '5a1fc7df-4bf1-4951-a576-89034ee01acd')
var eventHubSenderRoleId = resourceId('Microsoft.Authorization/roleDefinitions', '2b629674-e913-4c01-ae53-ef4638d8f975')
var eventHubReceiverRoleId = resourceId('Microsoft.Authorization/roleDefinitions', 'a638d3c7-ab3a-418d-83e6-5f17a39d4fde')

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'id-${basename}'
  location: location
}

resource eventhubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: 'en-${basename}'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 2
  }
  properties: {
    disableLocalAuth: true
    zoneRedundant: true
    isAutoInflateEnabled: true
    maximumThroughputUnits: 8
    kafkaEnabled: false
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

resource iotHub 'Microsoft.Devices/IotHubs@2021-07-02' = {
  name: 'ih-${basename}'
  location: location
  sku: {
    name: 'S1'
    capacity: 1
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 1
        partitionCount: 4
      }
    }
    routing: {
      endpoints: {
        eventHubs: [
          {
            name: 'ih-endpoint-${basename}'
            endpointUri: uri('sb://en-${basename}.servicebus.windows.net', '') 
            entityPath: eventHub.name
            authenticationType:'identityBased'
            identity: {
              userAssignedIdentity: identity.id
            }
            id: guid(eventHub.id)
            subscriptionId: subscription().subscriptionId
            resourceGroup: resourceGroup().name
          }
        ]
      }
      routes: [
        {
          name: 'ih-route-${basename}'
          source: 'DeviceMessages'
          condition: 'true'
          endpointNames: [
            'ih-endpoint-${basename}'
          ]
          isEnabled: true
        }
      ]
      fallbackRoute: {
        name: '$fallback'
        source: 'DeviceMessages'
        condition: 'true'
        endpointNames: [
          'events'
        ]
        isEnabled: true
      }
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

resource FhirContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (fhirContributorPrincipalId != '') {
  scope: fhirService
  name: guid(fhirContributorRoleId, iotConnector.id, fhirService.id)
  properties: {
    roleDefinitionId: fhirContributorRoleId
    principalId: fhirContributorPrincipalId
    principalType: 'User'
  }
}

resource EventHubDatasender 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: eventHub
  name: guid(eventHubSenderRoleId, identity.id, eventHub.id)
  properties: {
    roleDefinitionId: eventHubSenderRoleId
    principalId: identity.properties.principalId
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
