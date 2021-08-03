param location string = resourceGroup().location
param wanname string

@allowed([
  'Standard'
  'Basic'
])
@description('Specifies the type of Virtual WAN.')
param wantype string = 'Standard'

resource wan 'Microsoft.Network/virtualWans@2020-06-01' = {
  name: wanname
  location: location
  properties: {
    type: wantype
    disableVpnEncryption: false
    allowBranchToBranchTraffic: true
    office365LocalBreakoutCategory: 'None'
  }
}

output id string = wan.id
