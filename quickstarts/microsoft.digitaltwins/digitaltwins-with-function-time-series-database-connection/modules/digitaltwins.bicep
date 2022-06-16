@description('Name of new Digital Twin resource name')
param digitalTwinsName string

@description('Location of to be created resource')
param location string

// Creates Digital Twins instance
resource digitalTwins 'Microsoft.DigitalTwins/digitalTwinsInstances@2022-05-31' = {
  name: digitalTwinsName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}
