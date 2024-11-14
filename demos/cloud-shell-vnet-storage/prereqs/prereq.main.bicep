@description('Name of the VNET to inject Cloud Shell into.')
param vnetName string

@description('Address space of the subnet to add.')
param vnetAddressPrefix string

@description('Name of the default subnet.')
param defaultSubnetName string = 'default'

@description('Address space of the default subnet.')
param defaultSubnetAddressPrefix string

@description('Name of the subnet to use for Cloud Shell containers.')
param containerSubnetName string = 'cloudshellsubnet'

@description('Address space of the subnet to add for Cloud Shell.')
param containerSubnetAddressPrefix string

@description('Name of the subnet to use for storage account.')
param storageSubnetName string = 'storagesubnet'

@description('Address space of the subnet to add for storage.')
param storageSubnetAddressPrefix string

@description('Location for all resources.')
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vnetName
  location: location
  tags: {
    displayName: 'The VNET'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: defaultSubnetName
        properties: {
          addressPrefix: defaultSubnetAddressPrefix
        }
      }
      {
        name: containerSubnetName
        properties: {
          addressPrefix: containerSubnetAddressPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                location
              ]
            }
          ]
          delegations: [
            {
              name: 'CloudShellDelegation'
              properties: {
                serviceName: 'Microsoft.ContainerInstance/containerGroups'
              }
            }
          ]
        }
      }
      {
        name: storageSubnetName
        properties: {
          addressPrefix: storageSubnetAddressPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                location
              ]
            }
          ]
        }
      }
    ]
  }
}

output vnetName string = vnetName
output containerSubnetName string = containerSubnetName
output storageSubnetName string = storageSubnetName
