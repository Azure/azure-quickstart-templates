@description('Username you want to use for the VM the template creates')
param adminUsername string

@description('Size of the VM')
param vmSize string = 'Standard_A2_v2'

@description('The DNS name (prefix) you want to use for the VM to map against its public IP')
param dnsNameForPublicIP string = uniqueString(resourceGroup().id)

@description('The SAS URL connection string for the storage account blog where your Application Gateway Access Logs are stored')
param appGwAccessLogsBlobSasUri string

@description('A regex to use to filter the Application Gateway Access Logs to a specific subset. For example, if you have multiple application gateways publishing logs to the same storage account blob, and you only want GoAccess to surface traffic stats for say one of the Application Gateways, you can provide a regex for this field to filter to just that instance.')
param filterRegexForAppGwAccessLogs string = '.*'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated. Use the defaultValue if the staging location is not secured.')
@secure()
param _artifactsLocationSasToken string = ''

@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'sshPublicKey'

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

var vmName = dnsNameForPublicIP
var nicName = '${dnsNameForPublicIP}_vmnic'
var addressPrefix = '10.0.0.0/16'
var subnetPrefix = '10.0.0.0/24'
var subnetName = 'DefaultSubnet'
var publicIPAddressName = '${dnsNameForPublicIP}_publicip'
var virtualNetworkName = '${dnsNameForPublicIP}_vnet'
var networkSecurityGroupName = '${dnsNameForPublicIP}_nsg'
var scriptFileUri = uri(_artifactsLocation, 'scripts/setup_vm.sh${_artifactsLocationSasToken}')
var appGatewayLogProcessorArtifactUri = uri(_artifactsLocation, 'scripts/AppGatewayLogProcessor.zip${_artifactsLocationSasToken}')
var appGwAccessLogsBlobSasUriVar = '"${appGwAccessLogsBlobSasUri}"'
var filterRegexForAppGwAccessLogsVar = '"|${filterRegexForAppGwAccessLogs}|"'
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

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: dnsNameForPublicIP
    }
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'ssh'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 132
          direction: 'Inbound'
        }
      }
      {
        name: 'http'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 131
          direction: 'Inbound'
        }
      }
      {
        name: 'https'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'GoAccessSocket'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '8080'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 129
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
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

resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: nicName
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
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
  dependsOn: [
    virtualNetwork
  ]
}

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  properties: {
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
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}_osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: [
        {
          name: '${vmName}_datadisk1'
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
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
  }
}

resource newUserScript 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  parent: vm
  name: 'newuserscript'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        scriptFileUri
        appGatewayLogProcessorArtifactUri
      ]
      commandToExecute: 'sh setup_vm.sh ${appGwAccessLogsBlobSasUriVar} ${filterRegexForAppGwAccessLogsVar}'
    }
  }
}

output goAccessReportUrl string = '${publicIPAddress.properties.dnsSettings.fqdn}/report.html'
output sshCommand string = 'ssh ${adminUsername}@${publicIPAddress.properties.dnsSettings.fqdn}'
