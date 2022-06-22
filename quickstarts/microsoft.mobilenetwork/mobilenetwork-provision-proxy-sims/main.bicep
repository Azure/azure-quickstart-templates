@description('An array containing properties of the SIM(s) you wish to create. See [Provision proxy SIM(s)](https://docs.microsoft.com/en-gb/azure/private-5g-core/provision-sims-azure-portal) for a full description of the required properties and their format.')
param simResources array

resource exampleSimResources 'Microsoft.MobileNetwork/simGroups/sims@2022-04-01-preview' = [for item in simResources: {
  name: item.simName
  properties: {
    integratedCircuitCardIdentifier: item.integratedCircuitCardIdentifier
    internationalMobileSubscriberIdentity: item.internationalMobileSubscriberIdentity
    authenticationKey: item.authenticationKey
    operatorKeyCode: item.operatorKeyCode
    deviceType: item.deviceType
  }
}]
