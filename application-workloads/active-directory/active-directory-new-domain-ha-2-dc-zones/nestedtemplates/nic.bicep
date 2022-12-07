@metadata({
  Description: 'The name of the NIC to Create or Update'
})
param nicName string

@metadata({
  Description: 'The IP configurations of the NIC'
})
param ipConfigurations array

@metadata({
  Description: 'The DNS Servers of the NIC'
})
param dnsServers array

@description('Location for all resources.')
param location string

resource nicName_resource 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: ipConfigurations
    dnsSettings: {
      dnsServers: dnsServers
    }
  }
}
