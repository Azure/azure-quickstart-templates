@description('The location of all resources')
param location string = resourceGroup().location

@description('The name of the Hub vNet')
param vNetHubName string = 'vnet-hub'

@description('The name of the Spoke vNet')
param vNetSpokeName string = 'vnet-spoke'

@description('The name of the Virtual Machine')
param vmName string = 'vm1'

@description('The size of the Virtual Machine')
param vmSize string = 'Standard_D2s_v3'

@description('The administrator username')
param adminUsername string

@description('The administrator password')
@secure()
param adminPassword string

@description('The name of the Azure Bastion host')
param bastionHostName string = 'bastion1'

var vNetHubPrefix = '10.0.0.0/16'
var subnetBastionPrefix = '10.0.0.0/26'
var vNetSpokePrefix = '10.1.0.0/16'
var subnetSpokeName = 'Subnet-1'
var subnetSpokePrefix = '10.1.0.0/24'

resource vNetHub 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vNetHubName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNetHubPrefix
      ]
    }
    subnets: [
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: subnetBastionPrefix
        }
      }
    ]
  }
}

resource vNetSpoke 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vNetSpokeName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNetSpokePrefix
      ]
    }
    subnets: [
      {
        name: subnetSpokeName
        properties: {
          addressPrefix: subnetSpokePrefix
        }
      }
    ]
  }
}

resource vNetHubSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  parent: vNetHub
  name: 'peering-to-${vNetSpokeName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vNetSpoke.id
    }
  }
}

resource vNetSpokeHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  parent: vNetSpoke
  name: 'peering-to-${vNetHubName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vNetHub.id
    }
  }
}

resource bastionPublicIP 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: '${bastionHostName}-pip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2022-07-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        properties: {
          subnet: {
            id: '${vNetHub.id}/subnets/AzureBastionSubnet'
          }
          publicIPAddress: {
            id: bastionPublicIP.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
        name: 'ipconfig1'
      }
    ]
  }
}

resource vmNic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${vmName}-nic-01'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${vNetSpoke.id}/subnets/${subnetSpokeName}'
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}-os-01'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}
