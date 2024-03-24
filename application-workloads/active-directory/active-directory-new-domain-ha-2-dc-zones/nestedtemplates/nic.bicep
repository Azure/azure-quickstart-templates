@description('The name of the NIC to Create or Update')
param nicName string

@description('The IP configurations of the NIC')
param ipConfigurations array

@description('The DNS Servers of the NIC')
param dnsServers array

@description('Location for all resources.')
param location string

resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: ipConfigurations
    dnsSettings: {
      dnsServers: dnsServers
    }
  }
}
