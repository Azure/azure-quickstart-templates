param vmssname string = 'myVmssFlex'
param location string = resourceGroup().location
param zones array = []

param vmSize string = 'Standard_DS1_v2'
@allowed([
  1
  2
  3
  5
])
param platformFaultDomainCount int = 1
@minValue(0)
@maxValue(1000)
param vmCount int = 3

@allowed([
  'ubuntulinux'
  'windowsserver'
])
param os string = 'ubuntulinux'

param subnetId string
param lbBackendPoolArray array = []

param adminUsername string
@allowed([
  'password'
  'sshPublicKey'
])
param authenticationType string = 'password'

@secure()
param adminPasswordOrKey string

var networkApiVersion = '2020-11-01'
var linuxConfiguration = {
  disablePasswordAuthentication: true
  provisionVMAgent: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}



var linuxImageReference = {
  publisher: 'Canonical'
  offer: 'UbuntuServer'
  sku: '18_04-LTS-Gen2'
  version: 'latest'
}
var windowsImageReference = {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2019-Datacenter'
  version: 'latest'
}
var windowsConfiguration =  {
  timeZone: 'Pacific Standard Time'
}

var imageReference = (os == 'ubuntulinux' ? linuxImageReference : windowsImageReference)

resource vmssflex 'Microsoft.Compute/virtualMachineScaleSets@2021-04-01' = {
  name: vmssname
  location: location
  zones: zones
  sku: {
    name: vmSize
    tier: 'Standard'
    capacity: vmCount
  }
  properties: {
    orchestrationMode: 'Flexible'
    singlePlacementGroup: false
    platformFaultDomainCount: platformFaultDomainCount

    virtualMachineProfile: {
 
      osProfile: {
        computerNamePrefix: 'myVm'
        adminUsername: adminUsername
        adminPassword: (authenticationType== 'password' ? adminPasswordOrKey: null)
        linuxConfiguration: (os=='ubuntulinux' && authenticationType == 'sshPublicKey'? linuxConfiguration : null)
        windowsConfiguration: (os=='windowsserver' ? windowsConfiguration : null)
      }
      networkProfile: {
        networkApiVersion: networkApiVersion
        networkInterfaceConfigurations: [
            {
            name: '${vmssname}NicConfig01'
            properties: {
              primary: true
              enableAcceleratedNetworking: false
              ipConfigurations: [
                {
                  name: '${vmssname}IpConfig'
                  properties: {
                    publicIPAddressConfiguration: {
                      name: '${vmssname}PipConfig'
                      properties:{
                        publicIPAddressVersion: 'IPv4'
                        idleTimeoutInMinutes: 5
                      }
                    }
                    privateIPAddressVersion: 'IPv4'
                    subnet: {
                      id: subnetId
                    }
                    loadBalancerBackendAddressPools: lbBackendPoolArray
                  }
                }
              ]
            }
          }
        ]
      }
      diagnosticsProfile: {
        bootDiagnostics: {
          enabled: true
        }
      }
      storageProfile: {
        osDisk: {
          createOption: 'FromImage'
          caching: 'ReadWrite'
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
        }
        imageReference: imageReference
      }
    }
  }
}

output vmssid string = vmssflex.id
output vmssAdminUsername string = adminUsername
