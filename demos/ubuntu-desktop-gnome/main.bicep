@description('Unique DNS Name Prefix for the Storage Account where the Virtual Machine\'s disks will be placed.  StorageAccounts may contain at most variables(\'vmsPerStorageAccount\')')
param newStorageAccountName string

@description('User name for the Virtual Machine.')
param adminUsername string = 'azureuser'

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsNameForPublicIP string

@description('The VM role size of the jump box')
param vmSize string = 'Standard_D2s_v3'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'sshPublicKey'

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

var vmName = 'jumpbox'
var availabilitySetNodesName = 'avail-set'
var osImagePublisher = 'Canonical'
var osImageOffer = 'UbuntuServer'
var osImageSKU = '18.04-LTS'
var publicIPAddressName = 'myPublicIP'
var publicIPAddressType = 'Dynamic'
var customScriptLocation = 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/demos/ubuntu-desktop-gnome/'
var wgetCommandPrefix = 'wget --tries 20 --retry-connrefused --waitretry=15 -qO- ${customScriptLocation}configure-ubuntu.sh | nohup /bin/bash -s '
var wgetCommandPostfix = ' > /var/log/azure/firstinstall.log 2>&1 &\''
var commandPrefix = '/bin/bash -c \''
var virtualNetworkName = 'VNET'
var subnetName = 'Subnet'
var addressPrefix = '10.0.0.0/16'
var subnetPrefix = '10.0.0.0/24'
var nsgName = 'node-nsg'
var nsgID = nsg.id
var storageAccountType = 'Standard_LRS'
var nodesLbName = 'nodeslb'
var nodesLbBackendPoolName = 'node-pool'
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}

resource newStorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: newStorageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
}

resource availabilitySetNodes 'Microsoft.Compute/availabilitySets@2022-11-01' = {
  name: availabilitySetNodesName
  location: location
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 5
  }
  sku: {
    name: 'Aligned'
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIPAddressType
    dnsSettings: {
      domainNameLabel: dnsNameForPublicIP
    }
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: nsgID
          }
        }
      }
    ]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'ssh'
        properties: {
          description: 'SSH'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource vmName_nic 'Microsoft.Network/networkInterfaces@2022-09-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfigNode'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '${split(subnetPrefix, '0/24')[0]}100'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', nodesLbName, nodesLbBackendPoolName)
            }
          ]
          loadBalancerInboundNatRules: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/inboundNatRules', nodesLbName, 'SSH-${vmName}')
            }
          ]
        }
      }
    ]
  }
  dependsOn: [
    nodesLb
    virtualNetwork
  ]
}

resource nodesLb 'Microsoft.Network/loadBalancers@2022-09-01' = {
  name: nodesLbName
  location: location
  properties: {
    frontendIPConfigurations: [
      {
        name: 'NodesLBFrontEnd'
        properties: {
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: nodesLbBackendPoolName
      }
    ]
    inboundNatRules: [
      {
        name: 'SSH-${vmName}'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', nodesLbName, 'NodesLBFrontEnd')
          }
          protocol: 'Tcp'
          frontendPort: 22
          backendPort: 22
          enableFloatingIP: false
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: vmName
  location: location
  properties: {
    availabilitySet: {
      id: availabilitySetNodes.id
    }
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)
    }
    storageProfile: {
      imageReference: {
        publisher: osImagePublisher
        offer: osImageOffer
        sku: osImageSKU
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmName_nic.id
        }
      ]
    }
  }
  dependsOn: [
    newStorageAccount

  ]
}

resource vmName_configuremaster 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = {
  parent: vm
  name: 'configuremaster'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: '${commandPrefix}${wgetCommandPrefix}${adminUsername}${wgetCommandPostfix}'
    }
  }
}
