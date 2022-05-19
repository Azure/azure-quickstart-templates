@description('Location for the resources.')
param location string = resourceGroup().location

@description('Stream Analytics Job Name, can contain alphanumeric characters and hypen and must be 3-63 characters long')
@minLength(3)
@maxLength(63)
param streamAnalyticsJobName string

@description('Number of Streaming Units')
@minValue(1)
@maxValue(48)
@allowed([
  1
  3
  6
  12
  18
  24
  30
  36
  42
  48
])
param numberOfStreamingUnits int

resource streamingJob 'Microsoft.StreamAnalytics/streamingjobs@2021-10-01-preview' = {
  name: streamAnalyticsJobName
  location: location
  properties: {
    sku: {
      name: 'Standard'
    }
    outputErrorPolicy: 'Stop'
    eventsOutOfOrderPolicy: 'Adjust'
    eventsOutOfOrderMaxDelayInSeconds: 0
    eventsLateArrivalMaxDelayInSeconds: 5
    dataLocale: 'en-US'
    transformation: {
      name: 'Transformation'
      properties: {
        streamingUnits: numberOfStreamingUnits
        query: 'SELECT\r\n    *\r\nINTO\r\n    [YourOutputAlias]\r\nFROM\r\n    [YourInputAlias]'
      }
    }
  }
}
