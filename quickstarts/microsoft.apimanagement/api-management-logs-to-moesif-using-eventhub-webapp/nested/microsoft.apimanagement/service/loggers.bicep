@description('Name of existing Api Management service. eg: \'blue-api-mgmt-v2\'')
param existingApiMgmtName string

@description('The name of log-to-eventhub \'logger-id\' referred to in policy xml')
param logToEventhubLoggerName string

@description('Name of Eventhub Namespace')
param eventHubNS string

@description('Name of the Eventhub')
param eventHubName string

@description('Name of Eventhub Send Policy')
param eventHubSendPolicyName string

var credentialsName = 'credentials-${logToEventhubLoggerName}'

resource rule 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2022-01-01-preview' existing = {
  name: '${eventHubNS}/${eventHubName}/${eventHubSendPolicyName}'
}

resource logger 'Microsoft.ApiManagement/service/loggers@2022-04-01-preview' = {
  name: '${existingApiMgmtName}/${logToEventhubLoggerName}'
  properties: {
    loggerType: 'azureEventHub'
    description: 'This logger logs to event hub'
    credentials: {
      name: credentialsName
      connectionString: rule.listkeys().primaryConnectionString
    }
  }
}

output logToEventhubLoggerName string = logToEventhubLoggerName
output resourceId string = logger.id
