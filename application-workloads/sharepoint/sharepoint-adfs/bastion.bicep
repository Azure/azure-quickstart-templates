param virtualNetworkName string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  scope: resourceGroup()
  name: virtualNetworkName
}

module bastionHost 'br/public:avm/res/network/bastion-host:0.6.1' = {
  scope: resourceGroup()
  name: 'bastion-module-avm'
  params: {
    name: 'bastion'
    virtualNetworkResourceId: virtualNetwork.id
    skuName: 'Developer'
  }
}
