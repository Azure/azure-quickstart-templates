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

module vnet 'br/public:network/virtual-network:1.0' = {
  name: vnetName
  location: location
  params: {
    name: vnetName
    addressPrefixes: vnetAddressPrefix
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

@description('The resource group the virtual network was deployed into')
output resourceGroupName string = resourceGroup().name

@description('The resource ID of the virtual network')
output resourceId string = vnet.outputs.resourceId

@description('The name of the virtual network')
output name string = vnet.outputs.name

@description('The names of the deployed subnets')
output subnetNames array = vnet.outputs.subnetNames

@description('The resource IDs of the deployed subnets')
output subnetResourceIds array = vnet.outputs.subnetResourceIds
