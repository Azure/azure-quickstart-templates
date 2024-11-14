@description('Name of the VNET to inject Cloud Shell into.')
param vnetName string

@description('Name of Network Security Group.')
param nsgName string = 'cloudshellnsg'

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
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
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
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
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
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        id: resourceId('Microsoft.Network/networkSecurityGroups', nsgName)
        name: 'DenyIntraSubnetTraffic'
        properties: {
          description: 'Deny traffic between container groups in cloudshellsubnet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: containerSubnetAddressPrefix
          destinationAddressPrefix: containerSubnetAddressPrefix
          access: 'Deny'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

output vnetName string = vnetName
output containerSubnetName string = containerSubnetName
output storageSubnetName string = storageSubnetName
