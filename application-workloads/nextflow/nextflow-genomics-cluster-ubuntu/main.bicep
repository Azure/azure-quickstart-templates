@description('Location for all resources')
param location string = resourceGroup().location

@description('Unique DNS Name for the Public IP used to access the Docker Virtual Machine (master node).')
param dnsNameForJumpBox string = 'jumpbox-${uniqueString(resourceGroup().id)}'

@description('The image to use for VMs created. This can be marketplace or custom image')
@metadata({ link: 'https://docs.microsoft.com/en-us/nodejs/api/azure-arm-compute/imagereference?view=azure-node-2.2.0' })
param vmImageReference object = {
  publisher: 'Canonical'
  offer: 'UbuntuServer'
  sku: '18.04-LTS'
  version: 'latest'
}

@description('Size of VMs in the VM Scale Set.')
param vmNodeSku string = 'Standard_F8s_v2'

@description('Size of the master node.')
param vmMasterSku string = 'Standard_F16s_v2'

@description('Choose between a standard disk for and SSD disk for the master node\'s NFS fileshare')
@allowed([
  'Standard_LRS'
  'StandardSSD_LRS'
  'Premium_LRS'
])
param vmMasterDiskType string = 'Premium_LRS'

@description('The SSD Size to be used for the NFS file share. For pricing details see https://azure.microsoft.com/en-us/pricing/details/managed-disks/')
@allowed([
  32
  64
  128
  256
  512
  1000
  2000
  4000
  10000
])
param vmMasterDiskSize int = 256

@description('An additional installs script (bash run as root) to be run after nodes/master are configured. Can be used to mount additional storage or do additional setup')
param vmAdditionalInstallScriptUrl string = ''

@description('An argument to be passed to the additional install script')
param vmAdditionalInstallScriptArgument string = ''

@description('The install URL for nextflow, this can be used to pin nextflow versions')
param nextflowInstallUrl string = 'https://get.nextflow.io'

@description('Number of cluster VM instances (100 or less).')
@minValue(1)
@maxValue(100)
param instanceCount int = 2

@description('Admin username on all VMs.')
param adminUsername string

@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'password'

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

@description('Name of the virtual network to deploy the scale set into.')
param vnetName string = 'nfvnet'

@description('Name of the subnet to deploy the scale set into.')
param subnetName string = 'nfsubnet'

@description('Azure file share name.')
param shareName string = 'sharedstorage'

@description('Path on VM to mount file shares. \'/datadisks/disk1/\' is a Premium Managed disk with high iops, this will suit most uses.')
param mountpointPath string = '/datadisks/disk1'

@description('Sets the cluster.maxCpus setting on all cluster nodes')
param nodeMaxCpus int = 2

@description('Determines whether to run the custom script extension on a subsequent deployment. Use the defaultValue.')
param forceUpdateTag string = newGuid()

@description('*Advanced* This is best left as default unless you are an advanced user. The base URI where artifacts required by this template are located.')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('*Advanced* This should be left as default unless you are an advanced user. The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated.')
@secure()
param _artifactsLocationSasToken string = ''

@description('*Advanced* This should be left as default unless you are an advanced user. The folder in the artifacts location were shared scripts are stored.')
param _diskInitScriptUri string = 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/shared_scripts/ubuntu/vm-disk-utils-0.1.sh'

@description('*Advanced* This should be left as default unless you are an advanced user. The folder in the artifacts location were nextflow scripts are stored.')
param _artifactsNextflowFolder string = 'scripts'

var nextflowInitScript = uri(_artifactsLocation, '${_artifactsNextflowFolder}/init.sh${_artifactsLocationSasToken}')
var jumpboxNICName = 'jumpboxNIC'
var addressPrefix = '10.0.0.0/16'
var subnetPrefix = '10.0.0.0/24'
var vmssName = 'cluster${uniqueString(dnsNameForJumpBox)}'
var storageAccountType = 'Standard_LRS'
var storageAccountName = 'nfstorage${uniqueString(resourceGroup().id)}'
var storageSuffix = environment().suffixes.storage
var publicIPAddressName = 'jumpboxPublicIP'
var publicIPAddressType = 'Dynamic'
var jumpboxVMName = 'jumpboxVM'
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
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
var networkSecurityGroupName = 'default-NSG'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  kind: 'Storage'
  sku: {
    name: storageAccountType
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIPAddressType
    dnsSettings: {
      domainNameLabel: dnsNameForJumpBox
    }
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
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

resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: vnetName
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
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

resource jumpboxNIC 'Microsoft.Network/networkInterfaces@2022-09-01' = {
  name: jumpboxNICName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
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

resource jumpboxVM 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: jumpboxVMName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmMasterSku
    }
    osProfile: {
      computerName: jumpboxVMName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)
    }
    storageProfile: {
      imageReference: vmImageReference
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          lun: 0
          name: 'jumpboxdatadisk'
          diskSizeGB: vmMasterDiskSize
          caching: 'None'
          createOption: 'Empty'
          managedDisk: {
            storageAccountType: vmMasterDiskType
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: jumpboxNIC.id
        }
      ]
    }
  }
  dependsOn: [
    storageAccount

  ]
}

resource jumpboxVMName_nfinit 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = {
  parent: jumpboxVM
  name: 'nfinit'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    forceUpdateTag: forceUpdateTag
    settings: {
      fileUris: [
        nextflowInitScript
        _diskInitScriptUri
      ]
    }
    protectedSettings: {
      commandToExecute: 'bash init.sh ${storageAccountName} "${storageAccount.listKeys().keys[0].value}" ${shareName} ${storageSuffix} ${mountpointPath} false ${adminUsername} 0 ${nextflowInstallUrl} ${vmAdditionalInstallScriptUrl} ${vmAdditionalInstallScriptArgument}'
    }
  }
}

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2022-11-01' = {
  name: vmssName
  location: location
  sku: {
    name: vmNodeSku
    capacity: instanceCount
  }
  properties: {
    overprovision: true
    upgradePolicy: {
      mode: 'Manual'
    }
    virtualMachineProfile: {
      storageProfile: {
        osDisk: {
          createOption: 'FromImage'
          caching: 'ReadWrite'
        }
        imageReference: vmImageReference
      }
      osProfile: {
        computerNamePrefix: vmssName
        adminUsername: adminUsername
        adminPassword: adminPasswordOrKey
        linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'nic'
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: 'ipconfig'
                  properties: {
                    subnet: {
                      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
                    }
                  }
                }
              ]
            }
          }
        ]
      }
      extensionProfile: {
        extensions: [
          {
            name: 'filesextension'
            properties: {
              publisher: 'Microsoft.Azure.Extensions'
              type: 'CustomScript'
              typeHandlerVersion: '2.0'
              autoUpgradeMinorVersion: true
              forceUpdateTag: forceUpdateTag
              settings: {
                fileUris: [
                  nextflowInitScript
                  _diskInitScriptUri
                ]
              }
              protectedSettings: {
                commandToExecute: 'bash init.sh ${storageAccountName} "${storageAccount.listKeys().keys[0].value}" ${shareName} ${storageSuffix} ${mountpointPath} true ${adminUsername} ${nodeMaxCpus} ${nextflowInstallUrl} ${vmAdditionalInstallScriptUrl} ${vmAdditionalInstallScriptArgument}'
              }
            }
          }
        ]
      }
    }
  }
  dependsOn: [
    vnet

  ]
}

output JumpboxConnectionString string = 'ssh ${adminUsername}@${publicIPAddress.properties.dnsSettings.fqdn}'
output ExampleNextflowCommand string = 'nextflow run hello -process.executor ignite -cluster.join path:${mountpointPath}/cifs/cluster -with-timeline runtimeline.html -with-trace -cluster.maxCpus 0'
output ExampleNextflowCommandWithDocker string = 'nextflow run nextflow-io/rnatoy -with-docker -process.executor ignite -cluster.join path:${mountpointPath}/cifs/cluster -with-timeline runtimeline.html -with-trace -cluster.maxCpus 0'
