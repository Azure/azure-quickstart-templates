param udrName string
param location string
param addressPrefix string = ''
param nextHopAddress string = ''

resource udr 'Microsoft.Network/routeTables@2020-06-01' = {
  name: udrName
  location: location
  properties: {
    // conditionally deploy route
    routes: any(addressPrefix == '' ? null : [
      {
        name: 'Nested-VMs'
        properties: {
          addressPrefix: addressPrefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: nextHopAddress
        }
      }
    ])
  }
}

output udrId string = udr.id
