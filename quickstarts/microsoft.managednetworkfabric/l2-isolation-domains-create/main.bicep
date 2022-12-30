@description('Name of the L2 Isolation Domain')
param l2DomainName string

@description('Azure Region for deployment of the L2 Isolation Domain and associated resources')
param location string = resourceGroup().location

var networkFabricId = '/subscriptions/d854f6e5-7f11-4515-9d58-2ef770a77ee2/resourceGroups/rahul-rg/providers/Microsoft.ManagedNetworkFabric/networkFabrics/rahulnf1'
var vlanId = 678
var mtu = 1654

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
