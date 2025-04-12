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

resource account 'Microsoft.DeviceUpdate/accounts@2020-03-01-preview' = {
  name: accountName
  location: location
}
