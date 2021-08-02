@description('The name of the account. Read more about limits at https://aka.ms/iot-hub-device-update-limits')
@minLength(3)
@maxLength(24)
param accountName string = take('adu-quickstart-${uniqueString(resourceGroup().id)}', 24)

@description('The location of the account.')
@allowed([
  'westus2'
  'northeurope'
  'southeastasia'
])
param location string

@description('The name of the instance.')
@minLength(3)
@maxLength(36)
param instanceName string = guid(resourceGroup().id)

@description('The name of the hub.')
@minLength(3)
@maxLength(50)
param iotHubName string = take('iot-hub-${uniqueString(resourceGroup().id)}', 50)

var iotHubResourceId = iotHub.id
var iotHubKeyName = 'deviceupdateservice'
var iotHubKeyIndex = 5
var consumerGroupName = 'adum'

resource iotHub 'Microsoft.Devices/iotHubs@2021-03-31' = {
  name: iotHubName
  location: location
  sku: {
    name: 'S1'
    capacity: 1
  }
  properties: {
    authorizationPolicies: [
      {
        keyName: 'iothubowner'
        rights: 'RegistryWrite, ServiceConnect, DeviceConnect'
      }
      {
        keyName: 'service'
        rights: 'ServiceConnect'
      }
      {
        keyName: 'device'
        rights: 'DeviceConnect'
      }
      {
        keyName: 'registryRead'
        rights: 'RegistryRead'
      }
      {
        keyName: 'registryReadWrite'
        rights: 'RegistryWrite'
      }
      {
        keyName: 'deviceupdateservice'
        rights: 'RegistryRead, ServiceConnect, DeviceConnect'
      }
    ]
    cloudToDevice: {
      maxDeliveryCount: 10
      defaultTtlAsIso8601: 'PT1H'
      feedback: {
        lockDurationAsIso8601: 'PT1M'
        ttlAsIso8601: 'PT1H'
        maxDeliveryCount: 10
      }
    }
    enableFileUploadNotifications: false
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 1
        partitionCount: 4
      }
    }
    features: 'None'
    messagingEndpoints: {
      fileNotifications: {
        lockDurationAsIso8601: 'PT1M'
        ttlAsIso8601: 'PT1H'
        maxDeliveryCount: 10
      }
    }
    routing: {
      routes: [
        {
          name: 'DeviceUpdate.DeviceTwinChanges'
          source: 'TwinChangeEvents'
          condition: '(opType = \'updateTwin\' OR opType = \'replaceTwin\') AND IS_DEFINED($body.tags.ADUGroup)'
          endpointNames: [
            'events'
          ]
          isEnabled: true
        }
        {
          name: 'DeviceUpdate.DigitalTwinChanges'
          source: 'DigitalTwinChangeEvents'
          condition: 'true'
          endpointNames: [
            'events'
          ]
          isEnabled: true
        }
        {
          name: 'DeviceUpdate.DeviceLifeCycle'
          source: 'DeviceLifecycleEvents'
          condition: 'opType = \'deleteDeviceIdentity\' OR opType = \'deleteModuleIdentity\''
          endpointNames: [
            'events'
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

resource iotHub_consumerGroup 'Microsoft.Devices/iotHubs/eventhubEndpoints/consumerGroups@2021-03-31' = {
  name: '${iotHubName}/events/${consumerGroupName}'
  properties: {
    name: consumerGroupName
  }
  dependsOn: [
    iotHub
  ]
}

resource account 'Microsoft.DeviceUpdate/accounts@2020-03-01-preview' = {
  name: accountName
  location: location
}

resource instance 'Microsoft.DeviceUpdate/accounts/instances@2020-03-01-preview' = {
  parent: account
  name: instanceName
  location: location
  properties: {
    iotHubs: [
      {
        resourceId: iotHubResourceId
        ioTHubConnectionString: 'HostName=${reference(iotHubResourceId, '2021-03-31').hostName};SharedAccessKeyName=${iotHubKeyName};SharedAccessKey=${listkeys(iotHubResourceId, '2021-03-31').value[iotHubKeyIndex].primaryKey}'
        eventHubConnectionString: 'Endpoint=${reference(iotHubResourceId, '2021-03-31').eventHubEndpoints.events.endpoint};SharedAccessKeyName=${iotHubKeyName};SharedAccessKey=${listKeys(iotHubResourceId, '2021-03-31').value[iotHubKeyIndex].primaryKey};EntityPath=${reference(iotHubResourceId, '2021-03-31').eventHubEndpoints.events.path}'
      }
    ]
  }
}