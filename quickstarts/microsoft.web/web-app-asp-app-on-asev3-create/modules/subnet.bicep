@description('Required. The Virtual Network (vNet) Name.')
param virtualNetworkName string

@description('Required. The subnet Name of ASEv3.')
param subnetName string

@description('Required. The subnet Name of ASEv3.')
param subnetAddressPrefix string

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
    name: '${virtualNetworkName}/${subnetName}'
    properties:{
      addressPrefix: subnetAddressPrefix
      delegations: [
        {
          name: 'Microsoft.Web.hostingEnvironments'
          properties: {
            serviceName: 'Microsoft.Web/hostingEnvironments'
          }
        }
      ]
    }
}
