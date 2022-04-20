@description('Region in which the mobile network is deployed (must match the resource group region)')
param location string = resourceGroup().location

@description('Name of the mobile network for which you are provisioning SIMs')
param existingMobileNetworkName string

@description('An array containing properties of the SIM(s) you wish to create. See [Provision Sims](https://docs.microsoft.com/en-gb/azure/private-5g-core/provision-sims-azure-portal) for a full description of the required properties and their format.')
param simResources array

resource existingMobileNetwork 'Microsoft.MobileNetwork/mobileNetworks@2022-03-01-preview' existing = {
  name: existingMobileNetworkName
}

resource exampleSimResources 'Microsoft.MobileNetwork/sims@2022-03-01-preview' = [for item in simResources: {
  name: item.simName
  location: location
  properties: {
    integratedCircuitCardIdentifier: item.integratedCircuitCardIdentifier
    internationalMobileSubscriberIdentity: item.internationalMobileSubscriberIdentity
    authenticationKey: item.authenticationKey
    operatorKeyCode: item.operatorKeyCode
    deviceType: item.deviceType
    mobileNetwork: {
      id: existingMobileNetwork.id
    }
  }
}]
