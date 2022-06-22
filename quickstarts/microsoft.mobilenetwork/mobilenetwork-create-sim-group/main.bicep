@description('Region where the SIM group will be deployed (must match the resource group region).')
param location string

@description('The name for the SIM group.')
param simGroupName string

@description('An Azure key vault key to encrypt the SIM(s) data that belongs to this SIM group.')
param encryptionKeyUrl string

@description('Name of the mobile network to which you are adding the SIM group')
param existingMobileNetworkName string

resource existingMobileNetwork 'Microsoft.MobileNetwork/mobileNetworks@2022-04-01-preview' existing = {
  name: existingMobileNetworkName
}

resource exampleSimGroupResource 'Microsoft.MobileNetwork/simGroups@2022-04-01-preview' = {
  name: simGroupName
  location: location
  properties: {
    encryptionKey: {
      keyUrl: encryptionKeyUrl
	}
    mobileNetwork: {
      id: existingMobileNetwork.id
    }
  }
}
