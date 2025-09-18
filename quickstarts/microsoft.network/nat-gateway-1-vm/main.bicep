@description('Name of the virtual machine')
param vmname string = 'vm-1'

@description('Size of the virtual machine')
param vmsize string = 'Standard_D2s_v3'

@description('Name of the virtual network')
param vnetname string = 'vnet-1'

@description('Name of the subnet for virtual network')
param subnetname string = 'subnet-1'

@description('Address space for virtual network')
param vnetaddressspace string = '10.0.0.0/16'

@description('Subnet prefix for virtual network')
param vnetsubnetprefix string = '10.0.0.0/24'

@description('Name of the NAT gateway')
param natgatewayname string = 'nat-gateway'

@description('Name of the virtual machine nic')
param networkinterfacename string = 'nic-1'

@description('Name of the NAT gateway public IP')
param publicipname string = 'public-ip-nat'

@description('Name of the Bastion host')
param bastionName string = 'bastion-host'

@description('Name of the virtual machine NSG')
param nsgname string = 'nsg-1'

@description('Administrator username for virtual machine')
param adminusername string

@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'sshPublicKey'

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

@description('Name of resource group')
param location string = resourceGroup().location

var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminusername}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: nsgname
  location: location
  properties: {}
}

resource publicip 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: publicipname
  location: location
  sku: {
    name: 'StandardV2'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmname
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmsize
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: '${vmname}_disk1'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        diskSizeGB: 30
      }
    }
    osProfile: {
      computerName: vmname
      adminUsername: adminusername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkinterface.id
        }
      ]
    }
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetname
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetaddressspace
      ]
    }
    subnets: [
      {
        name: subnetname
        properties: {
          addressPrefix: vnetsubnetprefix
          natGateway: {
            id: natgateway.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource natgateway 'Microsoft.Network/natGateways@2024-01-01' = {
  name: natgatewayname
  location: location
  sku: {
    name: 'StandardV2'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: publicip.id
      }
    ]
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
  parent: vnet
  name: 'subnet-1'
  properties: {
    addressPrefix: vnetsubnetprefix
    natGateway: {
      id: natgateway.id
    }
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource networkinterface 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: networkinterfacename
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig-1'
        properties: {
          privateIPAddress: '10.0.0.4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2024-01-01' = {
  name: bastionName
  location: location
  sku: {
    name: 'Developer'
  }
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
  }
}

output location string = location
output name string = natgateway.name
output resourceGroupName string = resourceGroup().name
output resourceId string = natgateway.id
