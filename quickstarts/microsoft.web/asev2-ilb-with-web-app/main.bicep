@description('Name of the App Service Environment')
param aseName string

@description('The name of the vnet')
param virtualNetworkName string

@description('The resource group name that contains the vnet')
param vnetResourceGroupName string

@description('Subnet name that will contain the App Service Environment')
param subnetName string

@description('Location for the resources')
param location string = resourceGroup().location

@description('None: public VIP only. Publishing: only ports 80/443 are mapped to ILB VIP. Web: only FTP ports are mapped to ILB VIP:  Web,Publishing: ports 80/443 and FTP ports are mapped to an ILB VIP.')
@allowed([
  'None'
  'Publishing'
  'Web'
  'Web, Publishing'
])
param internalLoadBalancingMode string = 'Web, Publishing'

@description('Used when deploying an ILB enabled ASE.  Set this to the root domain associated with the ASE.  For example: contoso.com')
param dnsSuffix string = ''

@description('The name of the web app that will be created.')
param siteName string

@description('The name of the App Service plan to use for hosting the web app.')
param appServicePlanName string

@description('The owner of the resource will be used for tagging.')
param owner string

@description('Defines the number of workers from the worker pool that will be used by the app service plan.')
param numberOfWorkers int = 1

@description('Defines which worker pool\'s (WP1, WP2 or WP3) resources will be used for the app service plan.')
@allowed([
  '1'
  '2'
  '3'
])
param workerPool string = '1'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  scope: resourceGroup(vnetResourceGroupName)
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  parent: virtualNetwork
  name: subnetName
}

resource hostingEnvironment 'Microsoft.Web/hostingEnvironments@2020-12-01' = {
  name: aseName
  kind: 'ASEV2'
  location: location
  tags: {
    displayName: 'ASE Environment'
    usage: 'Hosting PaaS applications'
    category: 'Environment'
    owner: owner
  }
  properties: {
    ipsslAddressCount: 0
    internalLoadBalancingMode: internalLoadBalancingMode
    dnsSuffix: dnsSuffix
    virtualNetwork: {
      id: subnet.id
    }
  }
}

resource serverFarm 'Microsoft.Web/serverFarms@2020-12-01' = {
  name: appServicePlanName
  location: location
  tags: {
    displayName: 'ASE Hosting Plan'
    usage: 'Hosting Plan within ASE'
    category: 'Hosting'
    owner: owner
  }
  properties: {
    hostingEnvironmentProfile: {
      id: hostingEnvironment.id
    }
  }
  sku: {
    name: 'I${workerPool}'
    tier: 'Isolated'
    size: 'I${workerPool}'
    family: 'I'
    capacity: numberOfWorkers
  }
}

resource website 'Microsoft.Web/sites@2020-12-01' = {
  name: siteName
  location: location
  tags: {
    displayName: 'ASE Web App'
    usage: 'Web App Hosted within ASE'
    category: 'Web App'
    owner: owner
  }
  properties: {
    serverFarmId: serverFarm.id
    hostingEnvironmentProfile: {
      id: hostingEnvironment.id
    }
  }
}
