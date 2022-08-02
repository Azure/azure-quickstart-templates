param location                 string
param vnetAddressPrefix        string
param subnetAddressPrefix      string
param vnetName                 string
param subnetName               string 
param networkSecurityGroupName string

//By Default the nsg will allow the vnet access and deny all other access
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: networkSecurityGroupName
  location: location
}

module vnet 'br/public:network/virtual-network:1.0.2' = {
  name: vnetName  
  params: {
    name: vnetName
    location: location
    addressPrefixes: [vnetAddressPrefix]
    subnets: [
      {
        name                             : subnetName        
        addressPrefix                    : subnetAddressPrefix
        privateEndpointNetworkPolicies   : 'Disabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
        networkSecurityGroupId           : networkSecurityGroup.id
      }
    ]
  }
}

@description('Network Security Group Resource ID')
output nsgID string = networkSecurityGroup.id
