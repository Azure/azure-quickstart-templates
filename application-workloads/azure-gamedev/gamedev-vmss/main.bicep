@description('Deployment Location')
param location string = resourceGroup().location

@description('Name of VMSS Cluster')
param vmssName string

@description('GameDev Sku')
param vmssSku string = ''

@allowed([
  'microsoftcorporation1602274591143'
  'azure-gaming'
])
@description('GameDev Image Publisher')
param vmssImgPublisher string = 'microsoftcorporation1602274591143'

@allowed([
  'game-dev-vm'
])
@description('GameDev Image Product Id')
param vmssImgProduct string = 'game-dev-vm'

@allowed([
  'win10_no_engine_1_0'
  'ws2019_no_engine_1_0'
  'win10_unreal_4_27_2'
  'ws2019_unreal_4_27_2'
  'win10_unreal_5_0_1'
  'ws2019_unreal_5_0_1'
])
@description('GameDev Image Sku')
param vmssImgSku string = 'win10_no_engine_1_0'

@description('GameDev Image Product Id')
param vmssImgVersion string = 'latest'

@description('GameDev Disk Type')
param vmssOsDiskType string = 'Premium_LRS'

@description('VMSS Instance Count')
@maxValue(100)
param vmssInstanceCount int = 1

@description('Administrator Login for access')
param administratorLogin string

@description('Administrator Password for access')
@secure()
param passwordAdministratorLogin string

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2021-04-01' = {
  name: vmssName
  sku: {
    name: vmssSku
    tier: 'Standard'
    capacity: vmssInstanceCount
  }
  plan: {
    name: vmssImgSku
    publisher: vmssImgPublisher
    product: vmssImgProduct
  }
  location: location
  properties: {
    singlePlacementGroup: false
    upgradePolicy: {
      mode: 'Manual'
    }
    virtualMachineProfile: {
      storageProfile: {
        osDisk: {
          createOption: 'FromImage'
          caching: 'ReadWrite'
          managedDisk: {
            storageAccountType: vmssOsDiskType
          }
        }
        imageReference: {
          publisher: vmssImgPublisher
          offer: vmssImgProduct
          sku: vmssImgSku
          version: vmssImgVersion
	}
      }
      osProfile: {
        computerNamePrefix: vmssName
        adminUsername: administratorLogin
        adminPassword: passwordAdministratorLogin
	windowsConfiguration: {
          provisionVMAgent: true
        }
      }
      priority: 'Low'
      evictionPolicy: 'Delete'
    }
    overprovision: false
  }
}

output id   string = vmss.id
output name string = vmss.name
