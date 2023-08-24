param vWANname string
param vWANhubs array

resource IPGroupHub1SpokeVnet1 'Microsoft.Network/ipGroups@2023-04-01' = {
  name: 'IPGroup-${vWANname}-${vWANhubs[0].spoke1.name}'
  location: vWANhubs[0].location
  properties: {
    ipAddresses: [
      vWANhubs[0].spoke1.addressSpace
    ]
  }
}

resource IPGroupHub1SpokeVnet2 'Microsoft.Network/ipGroups@2023-04-01' = {
  name: 'IPGroup-${vWANname}-${vWANhubs[0].spoke2.name}'
  location: vWANhubs[0].location
  properties: {
    ipAddresses: [
      vWANhubs[0].spoke2.addressSpace
    ]
  }
  #disable-next-line no-unnecessary-dependson // This is required to avoid conflicts with multiple concurrent updates on IPGroups
  dependsOn: [IPGroupHub1SpokeVnet1]
}

resource IPGroupHub2SpokeVnet1 'Microsoft.Network/ipGroups@2023-04-01' = {
  name: 'IPGroup-${vWANname}-${vWANhubs[1].spoke1.name}'
  location: vWANhubs[1].location
  properties: {
    ipAddresses: [
      vWANhubs[1].spoke1.addressSpace
    ]
  }
  #disable-next-line no-unnecessary-dependson // This is required to avoid conflicts with multiple concurrent updates on IPGroups
  dependsOn: [IPGroupHub1SpokeVnet2]
}

resource IPGroupHub2SpokeVnet2 'Microsoft.Network/ipGroups@2023-04-01' = {
  name: 'IPGroup-${vWANname}-${vWANhubs[1].spoke2.name}'
  location: vWANhubs[1].location
  properties: {
    ipAddresses: [
      vWANhubs[1].spoke2.addressSpace
    ]
  }
  #disable-next-line no-unnecessary-dependson // This is required to avoid conflicts with multiple concurrent updates on IPGroups
  dependsOn: [IPGroupHub2SpokeVnet1]
}

output IPGroupsIDs array = [
  IPGroupHub1SpokeVnet1.id
  IPGroupHub1SpokeVnet2.id
  IPGroupHub2SpokeVnet1.id
  IPGroupHub2SpokeVnet2.id
]
