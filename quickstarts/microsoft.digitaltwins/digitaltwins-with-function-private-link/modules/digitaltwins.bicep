@description('The name of the Digital Twins instance')
param digitalTwinsInstanceName string

@description('Location of the Digital Twins instance')
param digitalTwinsInstanceLocation string

resource digitalTwinsInstance 'Microsoft.DigitalTwins/digitalTwinsInstances@2020-12-01' = {
  name: digitalTwinsInstanceName
  location: digitalTwinsInstanceLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}

output id string = digitalTwinsInstance.id
output endpoint string = digitalTwinsInstance.properties.hostName
