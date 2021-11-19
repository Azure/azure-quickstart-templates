@description('Location for the VM, only certain regions support zones.')
param location string = resourceGroup().location

@description('Relative DNS name for the traffic manager profile, must be globally unique')
param uniqueDnsName string

@description('Admin user name for the Virtual Machines.')
param adminUserName string

@description('Relative DNS Name for the Public IPs used to access the Virtual Machines, must be globally unique. An index will be appended for each instance.')
param uniqueDnsNameForPublicIP string

@description('The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version. Allowed values: 18.04-LTS, 16.04-LTS.')
@allowed([
  '18.04-LTS'
  '16.04-LTS'
])
param ubuntuOSVersion string = '18.04-LTS'

@description('Size of the virtual machine')
param vmSize string = 'Standard_D2s_v3'

@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'sshPublicKey'

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

var numVMs = 3
var imageReference = {
  publisher: 'Canonical'
  offer: 'UbuntuServer'
  sku: ubuntuOSVersion
  version: 'latest'
}
var vmName = 'UbuntuVM'
var virtualNetworkName = '${vmName}-vnet'
var networkSecurityGroupName = '${vmName}-nsg'
var traficManagerProfileName = '${vmName}-tm'
var addressPrefix = '10.0.0.0/16'
var subnetPrefix = '10.0.0.0/24'
var subnetName = 'Subnet'
var publicIPAddressType = 'Dynamic'

var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUserName}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2021-03-01' = [for i in range(0, numVMs): {
  name: '${vmName}${i}-pip'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: publicIPAddressType
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: '${uniqueDnsNameForPublicIP}${i}'
    }
  }
}]

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' = {
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
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-03-01' = [for i in range(0, numVMs): {
  name: '${vmName}${i}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip[i].id
          }
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}]

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTP'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = [for i in range(0, numVMs): {
  name: '${vmName}${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: '${vmName}${i}'
      adminUsername: adminUserName
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? json('null') : linuxConfiguration)
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        name: '${vmName}${i}-osdisk'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic[i].id
        }
      ]
    }
  }
}]

resource customScript 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = [for i in range(0, numVMs): {
  name: 'installcustomscript'
  parent: vm[i]
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'sudo bash -c "sudo apt-get install -f -y && sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get install -y apache2 && echo \\"You\'re connected to $(hostname)\\" | sudo tee /var/www/html/index.html"'
    }
  }
}]

resource tmProfile 'Microsoft.Network/trafficmanagerprofiles@2018-08-01' = {
  name: traficManagerProfileName
  location: 'global'
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Weighted'
    dnsConfig: {
      relativeName: uniqueDnsName
      ttl: 30
    }
    monitorConfig: {
      protocol: 'HTTP'
      port: 80
      path: '/'
    }
    endpoints: [for i in range(0, numVMs): {
      name: 'endpoint${i}'
      type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
      properties: {
        targetResourceId: pip[i].id
        endpointStatus: 'Enabled'
        weight: 1
      }
    }]
  }
}
