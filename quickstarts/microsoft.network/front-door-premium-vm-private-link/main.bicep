@description('The location into which the Azure Storage resources should be deployed. When using Private Link origins with Front Door Premium during the preview period, there is a limited set of regions available for use. See https://docs.microsoft.com/en-us/azure/frontdoor/standard-premium/concept-private-link#limitations for more details.')
@allowed([
  'eastus'
  'westus2'
  'southcentralus'
])
param location string

@description('The IP address prefix (CIDR range) to use when deploying the virtual network.')
param vnetIPPrefix string = '10.0.0.0/16'

@description('The IP address prefix (CIDR range) to use when deploying the VM subnet within the virtual network.')
param vmSubnetIPPrefix string = '10.0.0.0/24'

@description('The IP address prefix (CIDR range) to use when deploying the Private Link service subnet within the virtual network.')
param privateLinkServiceSubnetIPPrefix string = '10.0.1.0/24'

@description('The name of the SKU to use when creating the virtual machine.')
param vmSize string = 'Standard_DS1_v2'

@description('The name of the operating system to deploy on the virtual machine.')
@allowed([
  'Windows2016Datacenter'
  'Windows2019Datacenter'
])
param vmOSName string = 'Windows2019Datacenter'

@description('The type of disk and storage account to use for the virtual machine\'s OS disk.')
param vmOSDiskStorageAccountType string = 'StandardSSD_LRS'

@description('The administrator username to use for the virtual machine.')
param vmAdminUsername string

@description('The administrator password to use for the virtual machine.')
@secure()
param vmAdminPassword string

@description('The name of the Front Door endpoint to create. This must be globally unique.')
param frontDoorEndpointName string = 'afd-${uniqueString(resourceGroup().id)}'

var vmImageReference = {
  Windows2019Datacenter: {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: '2019-Datacenter'
    version: 'latest'
  }
  Windows2016Datacenter: {
    publisher: 'MicrosoftWindowsServer'
    offer: 'WindowsServer'
    sku: '2016-Datacenter'
    version: 'latest'
  }
}
var frontDoorSkuName = 'Premium_AzureFrontDoor' // This sample uses Private Link, which requires the premium SKU of Front Door.

module network 'modules/network.bicep' = {
  name: 'network'
  params: {
    location: location
    vnetIPPrefix: vnetIPPrefix
    vmSubnetIPPrefix: vmSubnetIPPrefix
    privateLinkServiceSubnetIPPrefix: privateLinkServiceSubnetIPPrefix
  }
}

module loadBalancer 'modules/load-balancer.bicep' = {
  name: 'load-balancer'
  params: {
    location: location
    subnetResourceId: network.outputs.vmSubnetResourceId
  }
}

module vm 'modules/vm.bicep' = {
  name: 'vm'
  params: {
    location: location
    subnetResourceId: network.outputs.vmSubnetResourceId
    vmImageReference: vmImageReference[vmOSName]
    vmSize: vmSize
    vmOSDiskStorageAccountType: vmOSDiskStorageAccountType
    vmAdminUsername: vmAdminUsername
    vmAdminPassword: vmAdminPassword
    loadBalancerBackendAddressPoolResourceId: loadBalancer.outputs.backendAddressPoolResourceId
  }
}

module privateLinkService 'modules/private-link-service.bicep' = {
  name: 'private-link-service'
  params: {
    location: location
    subnetResourceId: network.outputs.privateLinkServiceSubnetResourceId
    loadBalancerFrontendIpConfigurationResourceId: loadBalancer.outputs.frontendIPConfigurationResourceId
  }
}

module frontDoor 'modules/front-door.bicep' = {
  name: 'front-door'
  params: {
    skuName: frontDoorSkuName
    endpointName: frontDoorEndpointName
    originHostName: loadBalancer.outputs.frontendIPAddress
    originForwardingProtocol: 'HttpOnly'
    privateEndpointResourceId: privateLinkService.outputs.privateLinkServiceResourceId
    privateLinkResourceType: '' // This should be blank for Private Link service.
    privateEndpointLocation: location
  }
}

output frontDoorEndpointHostName string = frontDoor.outputs.frontDoorEndpointHostName
