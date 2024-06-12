@description('Region where the SIM group will be deployed (must match the resource group region).')
param location string

@description('The name of the mobile network to which you are adding the SIM group.')
param existingMobileNetworkName string

@description('The name of the SIM policy to be assigned to the SIM(s).')
param existingSimPolicyName string

@description('The name for the SIM group.')
param simGroupName string

@description('A unversioned key vault key to encrypt the SIM data that belongs to this SIM group. For example: https://contosovault.vault.azure.net/keys/azureKey.')
param existingEncryptionKeyUrl string = ''

@description('User-assigned identity is an identity in Azure Active Directory that can be used to give access to other Azure resource such as Azure Key Vault. This identity should have Get, Wrap key, and Unwrap key permissions on the key vault.')
param existingUserAssignedIdentityResourceId string = ''

@description('An array containing properties of the SIM(s) you wish to create. See [Provision proxy SIM(s)](https://docs.microsoft.com/en-gb/azure/private-5g-core/provision-sims-azure-portal) for a full description of the required properties and their format.')
param simResources array

#disable-next-line BCP081
resource existingMobileNetwork 'Microsoft.MobileNetwork/mobileNetworks@2024-04-01' existing = {
  name: existingMobileNetworkName
}

#disable-next-line BCP081
resource existingSimPolicy 'Microsoft.MobileNetwork/mobileNetworks/simPolicies@2024-04-01' existing = {
  parent: existingMobileNetwork
  name: existingSimPolicyName
}

#disable-next-line BCP081
resource exampleSimGroupResource 'Microsoft.MobileNetwork/simGroups@2024-04-01' = {
  name: simGroupName
  location: location
  properties: {
    mobileNetwork: {
      id: existingMobileNetwork.id
    }
    encryptionKey: {
      keyUrl: existingEncryptionKeyUrl
    }
  }
  identity: !empty(existingUserAssignedIdentityResourceId) ? {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${existingUserAssignedIdentityResourceId}': {}
    }
  } : {
    type: 'None'
  }

  #disable-next-line BCP081
  resource exampleSimResources 'sims@2024-04-01' = [for item in simResources: {
    name: item.simName
    properties: {
      integratedCircuitCardIdentifier: item.integratedCircuitCardIdentifier
      internationalMobileSubscriberIdentity: item.internationalMobileSubscriberIdentity
      authenticationKey: item.authenticationKey
      operatorKeyCode: item.operatorKeyCode
      deviceType: item.deviceType
      simPolicy: {
        id: existingSimPolicy.id
      }
    }
  }]
}
