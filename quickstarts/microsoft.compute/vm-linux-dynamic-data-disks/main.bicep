@description('The base URI where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated.')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated.')
@secure()
param _artifactsLocationSasToken string = ''

@description('Unique public dns prefix where the  node will be exposed')
param dnsLabelPrefix string

@description('User name for the Virtual Machine. Pick a valid username otherwise there will be a BadRequest error.')
param adminUsername string = 'azureuser'

@description('openlogic/Canonical are the respective CentOS/Ubuntu Distributor in Azure Market Place')
@allowed([
  'Canonical'
  'openlogic'
])
param imagePublisher string = 'openlogic'

@description('New CentOS/UbuntuServer Image Offer')
@allowed([
  'CentOS'
  'UbuntuServer'
])
param imageOffer string = 'CentOS'

@description('P.S: OpenLogic CentOS version to use **docker usage Only for 7.1/7.2 kernels 3.10 and above **')
@allowed([
  '16.04.0-LTS'
  '6.5'
  '6.6'
  '7.1'
  '7.2'
])
param imageSku string = '7.2'

@description('This field must be a valid SSH public key. ssh with this RSA public key')
@secure()
param sshPublicKey string

@description('The Folder system to be auto-mounted.')
param mountFolder string = '/data'

@description('Size of the node.')
param nodeSize string = 'Standard_D2s_v3'

@description('The docker version **Only for 7.1/7.2 kernels 3.10 and above **')
param dockerVer string = '1.12'

@description('The Docker Compose Version **Only for 7.1/7.2 kernels 3.10 and above **')
param dockerComposeVer string = '1.9.0-rc2'

@description('The docker-machine version **Only for 7.1/7.2 kernels 3.10 and above **')
param dockerMachineVer string = '0.8.2'

@description('The size in GB of each data disk that is attached to the VM.  A MDADM RAID0  is created with all data disks auto-mounted,  that is dataDiskSize * dataDiskCount in size n the Storage .')
param dataDiskSize int = 10

@description('The Name of the VM.')
@allowed([
  'centos'
  'ubuntuserver'
])
param masterVMName string = 'centos'

@description('This parameter allows the user to select the number of disks wanted')
@minValue(0)
@maxValue(64)
param numDataDisks int = 4

@description('Location for all resources.')
param location string = resourceGroup().location

var avSetName = 'avSet'
var diskCaching = 'ReadWrite'
var networkSettings = {
  virtualNetworkName: 'virtualnetwork'
  addressPrefix: '10.0.0.0/16'
  subnet: {
    dse: {
      name: 'dse'
      prefix: '10.0.0.0/24'
      vnet: 'virtualnetwork'
    }
  }
  statics: {
    master: '10.0.0.254'
  }
}
var nicName = 'nic'
var publicIPAddressName = 'publicips'
var publicIPAddressType = 'Dynamic'
var subnetRef = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  networkSettings.virtualNetworkName,
  networkSettings.subnet.dse.name
)
var installationCLI = 'bash azuredeploy.sh ${masterVMName} ${mountFolder} ${numDataDisks} ${dockerVer} ${dockerComposeVer} ${adminUsername} ${imageSku} ${dockerMachineVer}'
var sshKeyPath = '/home/${adminUsername}/.ssh/authorized_keys'
var networkSecurityGroupName = 'default-NSG'

resource avSet 'Microsoft.Compute/availabilitySets@2023-09-01' = {
  name: avSetName
  location: location
  sku: {
    name: 'Aligned'
  }
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 5
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-22'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '22'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: networkSettings.virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        networkSettings.addressPrefix
      ]
    }
    subnets: [
      {
        name: networkSettings.subnet.dse.name
        properties: {
          addressPrefix: networkSettings.subnet.dse.prefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIPAddressType
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: networkSettings.statics.master
          publicIPAddress: {
            id: publicIPAddress.id
          }
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
  }
  dependsOn: [
    vnet
  ]
}

resource masterVM 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: masterVMName
  location: location
  properties: {
    availabilitySet: {
      id: avSet.id
    }
    hardwareProfile: {
      vmSize: nodeSize
    }
    osProfile: {
      computerName: masterVMName
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: sshKeyPath
              keyData: sshPublicKey
            }
          ]
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: 'latest'
      }
      osDisk: {
        name: '${masterVMName}_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
      dataDisks: [
        for j in range(0, numDataDisks): {
          caching: diskCaching
          diskSizeGB: dataDiskSize
          lun: j
          name: '${masterVMName}-datadisk${j}'
          createOption: 'Empty'
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
  }
}

resource installation 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  parent: masterVM
  name: 'Installation'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        uri(_artifactsLocation, 'scripts/azuredeploy.sh${_artifactsLocationSasToken}')
      ]
      commandToExecute: installationCLI
    }
  }
}
