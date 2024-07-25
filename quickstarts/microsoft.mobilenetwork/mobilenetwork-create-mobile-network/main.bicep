@description('Region where the Mobile Network will be deployed (must match the resource group region)')
param location string

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

#disable-next-line BCP081
resource exampleMobileNetwork 'Microsoft.MobileNetwork/mobileNetworks@2024-04-01' = {
  name: mobileNetworkName
  location: location
  properties: {
    publicLandMobileNetworkIdentifier: {
      mcc: mobileCountryCode
      mnc: mobileNetworkCode
    }
  }

  #disable-next-line BCP081
  resource exampleDataNetwork 'dataNetworks@2024-04-01' = {
    name: dataNetworkName
    location: location
    properties: {}
  }

  #disable-next-line BCP081
  resource exampleSlice 'slices@2024-04-01' = {
    name: sliceName
    location: location
    properties: {
      snssai: {
        sst: 1
      }
    }
  }
}
