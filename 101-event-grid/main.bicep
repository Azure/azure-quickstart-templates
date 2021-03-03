@description('The name of the Event Grid custom topic.')
param eventGridTopicName string = 'topic-${uniqueString(resourceGroup().id)}'

@description('The name of the Event Grid custom topic\'s subscription.')
param eventGridSubscriptionName string = 'sub-${uniqueString(resourceGroup().id)}'

@description('The webhook URL to send the subscription events to. This URL must be valid and must be prepared to accept the Event Grid webhook URL challenge request.')
param eventGridSubscriptionUrl string

@description('The location in which the Event Grid resources should be deployed.')
param location string = resourceGroup().location

resource eventGridTopic 'Microsoft.EventGrid/topics@2020-06-01' = {
  name: eventGridTopicName
  location: location
}

resource eventGridSubscription 'Microsoft.EventGrid/eventSubscriptions@2020-06-01' = {
  name: eventGridSubscriptionName
  scope: eventGridTopic
  properties: {
    destination: {
      endpointType: 'WebHook'
      properties: {
        endpointUrl: eventGridSubscriptionUrl
      }
    }
  }
}
