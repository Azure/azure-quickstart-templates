@description('The name of the Digital Twins instance')
param digitalTwinsInstanceName string

@description('Location of the Digital Twins instance')
param digitalTwinsInstanceLocation string

resource digitalTwinsInstance 'Microsoft.DigitalTwins/digitalTwinsInstances@2023-01-31' = {
  name: digitalTwinsInstanceName
  location: digitalTwinsInstanceLocation
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}

output id string = digitalTwinsInstance.id
output endpoint string = digitalTwinsInstance.properties.hostName
