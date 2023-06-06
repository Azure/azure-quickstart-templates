param location string
param spokeName string 
param spokeVnetPrefix string

// only these VNETs are tagged and will be added to the dynamic Network Group by Policy
var taggedVNETs = [
  'spokeA'
  'spokeB'
  'spokeC'
]

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: 'vnet-${location}-${toLower(spokeName)}'
  location: location
  // add tags to the vnet names in variable tagged vnets - for dynamic group membership
  tags: contains(taggedVNETs,spokeName) ? {
    _avnm_quickstart_deployment: 'spoke'
  } : {}
  properties: {
    addressSpace: {
      addressPrefixes: [
        spokeVnetPrefix
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: replace(spokeVnetPrefix, '.0.0/22', '.1.0/24')
        }
      }
    ]
  }
}

output vnetId string = vnet.id
