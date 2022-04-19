@description('Region where the Mobile Network will be deployed (must match the resource group region)')
param location string = resourceGroup().location

@description('The name for the private mobile network')
param mobileNetworkName string

@description('The mobile country code for the private mobile network')
param mobileCountryCode string = '001'

@description('The mobile network code for the private mobile network')
param mobileNetworkCode string = '01'

@description('The name of the slice')
param sliceName string = 'slice-1'

@description('The name of the data network')
param dataNetworkName string = 'internet'

resource exampleMobileNetwork 'Microsoft.MobileNetwork/mobileNetworks@2022-03-01-preview' = {
  name: mobileNetworkName
  location: location
  properties: {
    publicLandMobileNetworkIdentifier: {
      mcc: mobileCountryCode
      mnc: mobileNetworkCode
    }
  }

  resource exampleDataNetwork 'dataNetworks@2022-03-01-preview' = {
    name: dataNetworkName
    location: location
    properties: {}
  }

  resource exampleSlice 'slices@2022-03-01-preview' = {
    name: sliceName
    location: location
    properties: {
      snssai: {
        sst: 1
      }
    }
  }
}
