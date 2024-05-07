@description('Storage Account name')
param storagename string = 'storage${uniqueString(resourceGroup().id)}'

@description('VM DNS label prefix')
param vm_dns string = 'docker-${uniqueString(resourceGroup().id)}'

@description('Admin user for VM')
param adminUser string

@description('Password for admin user (VM and Portainer)')
@secure()
param adminPassword string

@description('VM size for VM')
param vmsize string = 'Standard_D4_v4'

@description('Your public SSH key')
param publicSshKey string

@description('SKU of the Windows Server')
@allowed([
  '2019-datacenter-core-g2'
  '2019-datacenter-core-smalldisk-g2'
  '2022-datacenter-core-g2'
  '2022-datacenter-core-smalldisk-g2'
  '2022-datacenter-azure-edition-core'
  '2022-datacenter-azure-edition-core-smalldisk'
])
param vmSku string = '2022-datacenter-core-smalldisk-g2'

@description('SKU of the attached data disk (Standard HDD, Standard SSD or Premium SSD)')
@allowed([
  'Standard_LRS'
  'StandardSSD_LRS'
  'Premium_LRS'
])
param diskSku string = 'StandardSSD_LRS'

@description('Size of the attached data disk in GB')
param diskSizeGB int = 256

@description('Deployment location')
param location string = resourceGroup().location

@description('Email address for Let\'s Encrypt setup in Traefik')
@minLength(1)
param email string

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('SAS Token for accessing script path')
@secure()
param _artifactsLocationSasToken string = ''

var setupScriptUrl = uri(_artifactsLocation, 'setup.ps1${_artifactsLocationSasToken}')
var initScriptUrl = uri(_artifactsLocation, 'initialize.ps1${_artifactsLocationSasToken}')
var installDockerScriptUrl = uri(_artifactsLocation, 'InstallOrUpdateDockerEngine.ps1${_artifactsLocationSasToken}')
var templateUrl = uri(_artifactsLocation, 'configs/docker-compose.yml.template${_artifactsLocationSasToken}')
var sshdConfigUrl = uri(_artifactsLocation, 'configs/sshd_config_wopwd${_artifactsLocationSasToken}')

resource storage 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: toLower(storagename)
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  tags: {
    displayName: 'Storage account'
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: 'publicIP'
  location: location
  tags: {
    displayName: 'PublicIPAddress'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: vm_dns
    }
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: 'nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'rdp'
        properties: {
          description: 'description'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'https'
        properties: {
          description: 'description'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'ssh'
        properties: {
          description: 'description'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: 'virtualNetwork'
  location: location
  tags: {
    displayName: 'Virtual Network'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: 'nic'
  location: location
  tags: {
    displayName: 'Network Interface'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddress.id
          }
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

resource disk 'Microsoft.Compute/disks@2022-07-02' = {
  name: 'datadisk'
  location: location
  properties: {
    diskSizeGB: diskSizeGB
    creationData: {
      createOption: 'Empty'
    }
  }
  sku: {
    name: diskSku
  }
}

resource dockerhost 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: 'dockerhost'
  location: location
  tags: {
    displayName: 'Docker host with Portainer and Traefik'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmsize
    }
    osProfile: {
      computerName: 'dockerhost'
      adminUsername: adminUser
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: vmSku
        version: 'latest'
      }
      osDisk: {
        name: 'osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          createOption: 'Attach'
          lun: 0
          managedDisk: {
            id: disk.id
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storage.properties.primaryEndpoints.blob
      }
    }
  }
}

resource dockerhost_setupScript 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  parent: dockerhost
  name: 'setupScript'
  location: location
  tags: {
    displayName: 'Setup script for portainer and Traefik'
  }
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        setupScriptUrl
        initScriptUrl
        installDockerScriptUrl
        sshdConfigUrl
        templateUrl
      ]
    }
    protectedSettings: {
      commandToExecute: 'powershell -ExecutionPolicy Bypass -file initialize.ps1 -mail ${email} -publicdnsname ${publicIPAddress.properties.dnsSettings.fqdn} -adminPwd ${adminPassword} -publicSshKey "${publicSshKey}"'
    }
  }
}

output dockerhost_dns string = publicIPAddress.properties.dnsSettings.fqdn
