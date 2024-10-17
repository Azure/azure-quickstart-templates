@description('Location for all resources.')
param location string = resourceGroup().location

@description('Is the AVD FSLogix enabled or not')
param fslogixEnabled bool

@description('Virtual network resource Subnet Id.')
param subnetId string
@description('Number of session host to create')
param numberOfSessionHost int = 2
@description('Virtual machine resource name')
param virtualMachine object
@secure()
@description('Virtual machine resource admin username')
param adminUsername string
@secure()
@description('Virtual machine resource admin password')
param adminPassword string
@description('Host pool resource name')
param hostPoolName string
@description('Enable Active directory authentication')
param activeDirectoryAuthenticationEnabled bool
@description('Domain name to join')
param DomainName string?
@description('OUPath for the domain join')
param DomainJoinOUPath string?
@description('The username for the domain admin.')
param ADAdministratorAccountUsername string?
@description('The password that corresponds to the existing domain username.')
@secure()
param ADAdministratorAccountPassword string?

param artifactsLocation string
@description('Host pool registration token')
param hostPoolRegistrationInfoToken string

resource networkInterface 'Microsoft.Network/networkInterfaces@2024-01-01' = [for i in range(0, numberOfSessionHost) : {
  location: location
  name: '${virtualMachine.name}-nic${i + 1}'
  properties: {
    enableAcceleratedNetworking: true
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}]

resource vms 'Microsoft.Compute/virtualMachines@2024-03-01' = [for i in range(0, numberOfSessionHost) : {
  location: location
  name: '${virtualMachine.name}${i + 1}'
  properties: {
    licenseType: virtualMachine.licenseType
    hardwareProfile: {
      vmSize: virtualMachine.vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: virtualMachine.osDisk.createOption
        managedDisk: {
          storageAccountType: virtualMachine.osDisk.storageAccountType
        }
        deleteOption: virtualMachine.osDisk.deleteOption
      }
      imageReference: {
        publisher: virtualMachine.imageReference.publisher
        offer: virtualMachine.imageReference.offer
        sku: virtualMachine.imageReference.sku
        version: virtualMachine.imageReference.version
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface[i].id
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
      computerName: '${virtualMachine.name}${i + 1}'
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

resource entraIdJoin 'Microsoft.Compute/virtualMachines/extensions@2024-03-01' = [for i in range(0, numberOfSessionHost) : if (!activeDirectoryAuthenticationEnabled || !fslogixEnabled) {
  parent: vms[i]
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

resource dcs 'Microsoft.Compute/virtualMachines/extensions@2024-03-01' = [for i in range(0, numberOfSessionHost) : {
  parent: vms[i]
  name: 'MicrosoftPowershellDSC'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.83'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: artifactsLocation
      configurationFunction: 'Configuration.ps1\\AddSessionHost'
      properties: {
        hostPoolName: hostPoolName
        aadJoin: true
      }
    }
    protectedSettings: {
      properties: {
        registrationInfoToken: hostPoolRegistrationInfoToken
      }
    }
  }
  dependsOn: [
    entraIdJoin
  ]
}]

resource adomainJoin 'Microsoft.Compute/virtualMachines/extensions@2024-03-01' = [for i in range(0, numberOfSessionHost) :if (activeDirectoryAuthenticationEnabled || fslogixEnabled)  {
  parent: vms[i]
  name: 'ActiveDirectoryDomainJoin'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      name: DomainName
      ouPath: DomainJoinOUPath
      user: ADAdministratorAccountUsername
      restart: true
      options: 3
    }
    protectedSettings: {
      password: ADAdministratorAccountPassword
    }
  }
  dependsOn: [
    dcs
  ]
}]
