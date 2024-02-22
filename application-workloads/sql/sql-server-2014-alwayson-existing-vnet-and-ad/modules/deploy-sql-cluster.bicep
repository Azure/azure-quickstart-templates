param namePrefix string
param domainName string
param dnsServerName string
param adminUsername string

@secure()
param adminPassword string
param sqlServerServiceAccountUserName string

@secure()
param sqlServerServiceAccountPassword string

@allowed([
  'Standard_LRS'
  'StandardSSD_LRS'
  'Premium_LRS'
])
param diskType string = 'StandardSSD_LRS'
param nicSubnetUri string
param lbSubnetUri string
param sqlLBIPAddress string
param sqlVMSize string
param sqlWitnessVMSize string
param _artifactsLocation string

@secure()
param _artifactsLocationSasToken string
param windowsImagePublisher string = 'MicrosoftSQLServer'
param windowsImageOffer string = 'SQL2014SP2-WS2012R2'
param windowsImageSKU string = 'Enterprise'
param windowsImageVersion string = 'latest'

@description('Location for all resources.')
param location string

var sqlDiskSize = 1000
var sqlWitnessDiskSize = 128
var sqlNamePrefix = '${namePrefix}-sql-'
var sqlAvailabilitySetName = '${sqlNamePrefix}as'
var sqlLBName = '${sqlNamePrefix}ilb'
var lbFE1 = '${sqlNamePrefix}ilbfe1'
var lbBE = '${sqlNamePrefix}ilbbe'
var sqlLBFEConfigID1 = resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', sqlLBName, lbFE1)
var sqlLBBEAddressPoolID = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', sqlLBName, lbBE)
var sqlAOProbe1 = '${sqlNamePrefix}ilbp1'
var sqlLBProbeID1 = resourceId('Microsoft.Network/loadBalancers/probes/', sqlLBName, sqlAOProbe1)
var deploySqlWitnessShareName = 'deploySqlWitnessShare'
var sqlWitnessSharePath = '${namePrefix}-fsw'
var sqlWitnessVMName = '${sqlNamePrefix}w'
var deploySqlAlwaysOnName = 'deploySqlAlwaysOn'
var sqlAOEPName = '${namePrefix}-agep'
var sqlAOAGName1 = '${namePrefix}-ag1'
var sqlAOListener1 = '${namePrefix}-agl1'

resource sqlAvailabilitySet 'Microsoft.Compute/availabilitySets@2023-09-01' = {
  name: sqlAvailabilitySetName
  location: location
  properties: {
    platformUpdateDomainCount: 20
    platformFaultDomainCount: 2
  }
  sku: {
    name: 'Aligned'
  }
}

resource sqlLB 'Microsoft.Network/loadBalancers@2023-09-01' = {
  name: sqlLBName
  location: location
  properties: {
    frontendIPConfigurations: [
      {
        name: lbFE1
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: sqlLBIPAddress
          subnet: {
            id: lbSubnetUri
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: lbBE
      }
    ]
    loadBalancingRules: [
      {
        name: sqlAOListener1
        properties: {
          frontendIPConfiguration: {
            id: sqlLBFEConfigID1
          }
          backendAddressPool: {
            id: sqlLBBEAddressPoolID
          }
          probe: {
            id: sqlLBProbeID1
          }
          protocol: 'Tcp'
          frontendPort: 1433
          backendPort: 1433
          enableFloatingIP: true
        }
      }
    ]
    probes: [
      {
        name: sqlAOProbe1
        properties: {
          protocol: 'Tcp'
          port: 59999
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
}

resource sqlNic 'Microsoft.Network/networkInterfaces@2023-09-01' = [for i in range(0, 2): {
  name: '${sqlNamePrefix}${i}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: nicSubnetUri
          }
          loadBalancerBackendAddressPools: [
            {
              id: sqlLBBEAddressPoolID
            }
          ]
        }
      }
    ]
  }
  dependsOn: [
    sqlLB
  ]
}]

resource sqlWitnessVMNic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: '${sqlWitnessVMName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: nicSubnetUri
          }
        }
      }
    ]
  }
}

resource sqlVm 'Microsoft.Compute/virtualMachines@2023-09-01' = [for i in range(0, 2): {
  name: '${sqlNamePrefix}${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: sqlVMSize
    }
    availabilitySet: {
      id: sqlAvailabilitySet.id
    }
    osProfile: {
      computerName: '${sqlNamePrefix}${i}'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: windowsImagePublisher
        offer: windowsImageOffer
        sku: windowsImageSKU
        version: windowsImageVersion
      }
      osDisk: {
        name: '${sqlNamePrefix}${i}_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: diskType
        }
      }
      dataDisks: [
        {
          lun: 0
          name: '${sqlNamePrefix}${i}_datadisk1'
          createOption: 'Empty'
          diskSizeGB: sqlDiskSize
          caching: 'None'
          managedDisk: {
            storageAccountType: diskType
          }
        }
        {
          lun: 1
          name: '${sqlNamePrefix}${i}_logdisk1'
          createOption: 'Empty'
          diskSizeGB: sqlDiskSize
          caching: 'None'
          managedDisk: {
            storageAccountType: diskType
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: sqlNic[i].id
        }
      ]
    }
  }
}]

resource sqlWitnessVM 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: sqlWitnessVMName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: sqlWitnessVMSize
    }
    availabilitySet: {
      id: sqlAvailabilitySet.id
    }
    osProfile: {
      computerName: sqlWitnessVMName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: windowsImagePublisher
        offer: windowsImageOffer
        sku: windowsImageSKU
        version: windowsImageVersion
      }
      osDisk: {
        name: '${sqlWitnessVMName}_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: diskType
        }
      }
      dataDisks: [
        {
          name: '${sqlWitnessVMName}_datadisk1'
          caching: 'None'
          createOption: 'Empty'
          diskSizeGB: sqlWitnessDiskSize
          lun: 0
          managedDisk: {
            storageAccountType: diskType
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: sqlWitnessVMNic.id
        }
      ]
    }
  }
}

module deploySqlWitnessShare 'deploy-sql-witness.bicep' = {
  name: deploySqlWitnessShareName
  params: {
    sqlWitnessVMName: sqlWitnessVMName
    domainName: domainName
    sharePath: sqlWitnessSharePath
    adminUsername: adminUsername
    adminPassword: adminPassword
    _artifactsLocation: _artifactsLocation
    _artifactsLocationSasToken: _artifactsLocationSasToken
    location: location
  }
  dependsOn: [
    sqlWitnessVM
  ]
}

module deploySqlAlwaysOn 'deploy-sql-alwayson.bicep' = {
  name: deploySqlAlwaysOnName
  params: {
    sqlNamePrefix: sqlNamePrefix
    domainName: domainName
    namePrefix: namePrefix
    sharePath: sqlWitnessSharePath
    sqlWitnessVMName: sqlWitnessVMName
    sqlLBName: sqlLBName
    sqlLBIPAddress: sqlLBIPAddress
    dnsServerName: dnsServerName
    sqlServerServiceAccountUserName: sqlServerServiceAccountUserName
    sqlServerServiceAccountPassword: sqlServerServiceAccountPassword
    adminUsername: adminUsername
    adminPassword: adminPassword
    _artifactsLocation: _artifactsLocation
    _artifactsLocationSasToken: _artifactsLocationSasToken
    sqlAlwaysOnEndpointName: sqlAOEPName
    sqlAlwaysOnAvailabilityGroupName1: sqlAOAGName1
    sqlAlwaysOnAvailabilityGroupListenerName1: sqlAOListener1
    location: location
  }
  dependsOn: [
    sqlVm[0]
    sqlVm[1]
    deploySqlWitnessShare
  ]
}
