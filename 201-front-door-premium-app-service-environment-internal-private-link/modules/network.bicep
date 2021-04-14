@description('The location into which the virtual network resources should be deployed.')
param location string

@description('The IP address prefix (CIDR range) to use when deploying the virtual network.')
param vnetIPPrefix string

@description('The IP address prefix (CIDR range) to use when deploying the App Service environment subnet within the virtual network.')
param appServiceEnvironmentSubnetIPPrefix string

var vnetName = 'VNet'
var appServiceEnvironmentSubnetName = 'ase'
var nsgName = 'MyNSG'

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetIPPrefix
      ]
    }
    subnets: [
      {
        name: appServiceEnvironmentSubnetName
        properties: {
          addressPrefix: appServiceEnvironmentSubnetIPPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      // Rules for App Service Environments as documented here: https://docs.microsoft.com/en-us/azure/app-service/environment/network-info#ase-subnet-size
      {
        name: 'Allow_inbound_App_Service_Management_traffic'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '454-455'
          sourceAddressPrefix: 'AppServiceManagement'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow_inbound_load_balancer_traffic'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '16001'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow_outbound_DNS_and_NTP_traffic'
        properties: {
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '53'
            '123'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        // This is used for CRL, Windows updates, Linux dependencies, Azure services.
        name: 'Allow_outbound_HTTP_and_HTTPS_traffic'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '80'
            '443'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
      {
        name: 'Allow_outbound_Azure_SQL_traffic'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Sql'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'Allow_outbound_monitoring_traffic'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '12000'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
    ]
  }
}

output vnetName string = vnetName
output appServiceEnvironmentSubnetResourceId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, appServiceEnvironmentSubnetName)
