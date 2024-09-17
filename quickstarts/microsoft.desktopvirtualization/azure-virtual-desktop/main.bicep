@description('Location for all resources.')
param location string = resourceGroup().location

@description('Set this to true if creating a new network')
param newVirtualNetwork bool

@description('Exisiting Virtual network resource group.')
param virtualNetworkRG string

@description('Virtual network resource name.')
param virtualNetworkName string

@description('Virtual network resource Address Space.')
param virtualNetworkAddressSpace string

@description('Virtual network resource Subnet name.')
param subnetName string

@description('Virtual network resource Subnet Address Prefix.')
param subnetAddressPrefix string

@description('Host pool resource name')
param hostPoolName string
@description('Application groups resource name')
param applicationGroupName string
@description('Workspace resource name')
param workspaceName string
@description('Virtual machine resource name')
param virtualMachines array
@description('Virtual machine resource admin username')
param adminUsername string

@secure()
@description('Virtual machine resource admin password')
param adminPassword string
param artifactsLocation string

@description('Host pool resource property configuration')
param hostPoolProperties object = {
  friendlyName: hostPoolName
  description: 'Azure Virtual Desktop host pool'
  hostPoolType: 'Personal'
  personalDesktopAssignmentType: 'Direct'
  maxSessionLimit: 999999
  loadBalancerType: 'Persistent'
  validationEnvironment: true
  preferredAppGroupType: 'Desktop'
  publicNetworkAccess: 'Enabled'
  customRdpProperty: 'targetisaadjoined:i:1;drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;redirectwebauthn:i:1;use multimon:i:1;'
  directUDP: 'Default'
  managedPrivateUDP: 'Default'
  managementType: 'Standard'
  publicUDP: 'Default'
  relayUDP: 'Default'
  startVMOnConnect: false
  registrationInfo: {
    expirationTime: dateTimeAdd('2024-09-17 00:00:00Z', 'P2D')
    registrationTokenOperation: 'Update'
  }
}
@description('Application group resource property configuration')
param applicationGroupProperties object = {
  applicationGroupType: 'Desktop'
  friendlyName: applicationGroupName
  description: 'Azure Virtual Desktop application group'
}
@description('Workspace resource property configuration')
param workspaceProperties object = {
  description: 'Azure Virtual Desktop workspace'
  friendlyName: workspaceName
  publicNetworkAccess: 'Enabled'
}

resource existingVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' existing = if(!(newVirtualNetwork)) {
  scope: az.resourceGroup(virtualNetworkRG)
  name: virtualNetworkName
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = if(newVirtualNetwork) {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [virtualNetworkAddressSpace]
    }
  }
}

resource existingSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' existing = if(!(newVirtualNetwork)) {
  parent: existingVirtualNetwork
  name: subnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = if(newVirtualNetwork) {
  parent: virtualNetwork
  name: subnetName
  properties: {
    addressPrefix: subnetAddressPrefix
    privateEndpointNetworkPolicies: 'Enabled'
  }
}

resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2021-01-14-preview' = {
  location: location
  name: hostPoolName
  properties: hostPoolProperties
}

resource applicationGroups 'Microsoft.DesktopVirtualization/applicationGroups@2024-04-08-preview' = {
  location: location
  name: applicationGroupName
  properties: union(applicationGroupProperties, {hostPoolArmPath: hostPool.id})
}

resource workspace 'Microsoft.DesktopVirtualization/workspaces@2024-04-08-preview' = {
  location: location
  name: workspaceName
  properties: union(workspaceProperties, {applicationGroupReferences: [applicationGroups.id]})
}

resource networkinterface 'Microsoft.Network/networkInterfaces@2024-01-01' = [for (vm, ind) in virtualMachines: {
  location: location
  name: '${vm.name}${ind}-nic'
  properties: {
    enableAcceleratedNetworking: true
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: newVirtualNetwork ? subnet.id : existingSubnet.id
          }
        }
      }
    ]
  }
}]

resource virtualMachine 'Microsoft.Compute/virtualMachines@2024-03-01' = [for (vm, ind) in virtualMachines: {
  location: location
  name: '${vm.name}${ind}'
  properties: {
    licenseType: vm.licenseType
    hardwareProfile: {
      vmSize: vm.vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        publisher: 'microsoftwindowsdesktop'
        offer: 'windows-11'
        sku: 'win11-22h2-pro'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkinterface[ind].id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
    additionalCapabilities: {
      hibernationEnabled: false
    }
    osProfile: {
      computerName: '${vm.name}${ind}'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}]

resource entraIdJoin 'Microsoft.Compute/virtualMachines/extensions@2024-03-01' = [for (vm, ind) in virtualMachines: {
  parent: virtualMachine[ind]
  name: 'AADLoginForWindows'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADLoginForWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: false
  }
}]

resource dcs 'Microsoft.Compute/virtualMachines/extensions@2024-03-01' = [for (vm, ind) in virtualMachines: {
  parent: virtualMachine[ind]
  name: 'MicrosoftPowershellDSC'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.73'
    settings: {
      modulesUrl: artifactsLocation
      configurationFunction: 'Configuration.ps1\\AddSessionHost'
      properties: {
        hostPoolName: hostPool.name
        aadJoin: true
      }
    }
    protectedSettings: {
      properties: {
        registrationInfoToken: reference(hostPool.id).registrationInfo.token
      }
    }
  }
  dependsOn: [
    entraIdJoin
  ]
}]

//output registrationInfo1 string = reference(hostPool.id).registrationInfo.token
