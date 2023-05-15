@description('Region where the Mobile Network will be deployed (must match the resource group region)')
param location string = resourceGroup().location

@description('The name for the private mobile network')
param mobileNetworkName string

@description('The mobile country code for the private mobile network')
param mobileCountryCode string = '001'

@description('The mobile network code for the private mobile network')
param mobileNetworkCode string = '01'

@description('The name for the AzureStackEdgeName')
param azureStackEdgeName string

@description('The name of the data network')
param dataNetworkName string = 'internet'

resource exampleAzureStackEdge 'Microsoft.DataBoxEdge/DataBoxEdgeDevices@2020-01-01' = {
  name: azureStackEdgeName
  location: location
}

#disable-next-line BCP081
resource exampleMobileNetwork 'Microsoft.MobileNetwork/mobileNetworks@2022-04-01-preview' = {
  name: mobileNetworkName
  location: location
  properties: {
    publicLandMobileNetworkIdentifier: {
      mcc: mobileCountryCode
      mnc: mobileNetworkCode
    }
  }
}

#disable-next-line BCP081
resource exampleDataNetwork 'Microsoft.MobileNetwork/mobileNetworks/dataNetworks@2022-04-01-preview' = {
  parent: exampleMobileNetwork
  name: dataNetworkName
  location: location
  properties: {}
}

output aseID string = exampleAzureStackEdge.id
output existingMobileNetworkName string = mobileNetworkName
output existingDataNetworkName string = dataNetworkName
