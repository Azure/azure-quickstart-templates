param nicName string
param location string
param subnetId string
param pipId string = ''

@allowed([
  'Dynamic'
  'Static'
])
param ipAllocationMethod string = 'Dynamic'

param staticIpAddress string = ''
param enableIPForwarding bool = false

resource nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          primary: true
          privateIPAllocationMethod: ipAllocationMethod
          // pip is optional
          privateIPAddress: staticIpAddress
          subnet: {
            id: subnetId
          }
          // pip looks to be optional
          publicIPAddress: any((pipId == '') ? null : {
            id: pipId
          })
        }
      }
    ]
    enableIPForwarding: enableIPForwarding
  }
}

output nicId string = nic.id
output assignedIp string = nic.properties.ipConfigurations[0].properties.privateIPAddress
