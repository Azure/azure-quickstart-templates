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

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    enableDdosProtection: false
    subnet: [
      {
        name: subnetName
        properties: {
          addressPrefix                    : subnetAddressPrefix
          privateEndpointNetworkPolicies   : 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
    ]
  }
}

output subnetId string = vnet.properties.subnet[0].id
output vnetId   string = vnet.id
output vnet     string = vnet.name
output subnet   object = vnet.properties.subnet
output nsgID    string = networkSecurityGroup.id
