param location string = resourceGroup().location
param hubname string

@description('Specifies the Virtual Hub Address Prefix.')
param hubaddressprefix string = '10.10.0.0/24'

@description('Virtual WAN ID')
param wanid string

resource hub 'Microsoft.Network/virtualHubs@2020-06-01' = {
  name: hubname
  location: location
  properties: {
    addressPrefix: hubaddressprefix
    virtualWan: {
      id: wanid
    }
  }
}

output id string = hub.id
output name string = hub.name
output vhubaddress string = hub.properties.addressPrefix
