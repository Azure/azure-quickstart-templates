@description('Name of the L2 Isolation Domain')
param l2DomainName string

@description('Azure Region for deployment of the L2 Isolation Domain and associated resources')
param location string = resourceGroup().location

@description('Resource Id of the Network Fabric, is should be in the format of /subscriptions/<Sub ID>/resourceGroups/<Resource group name>/providers/Microsoft.ManagedNetworkFabric/networkFabrics/<networkFabric name>')
param networkFabricId string

@description('Vlan identifier value')
param vlanId int

@description('Maximum transmission unit')
param mtu int

@description('Create L2 Isolation Domain Resource')
resource l2IsolationDomains 'Microsoft.ManagedNetworkFabric/l2IsolationDomains@2022-01-15-privatepreview' = {
  name: l2DomainName
  location: location
  properties: {
    networkFabricId: networkFabricId
    vlanId: vlanId
    mtu: mtu
  }
}

output id string = l2IsolationDomains.id
