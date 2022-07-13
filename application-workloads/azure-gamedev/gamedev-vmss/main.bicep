@description('Deployment Location')
param location string = resourceGroup().location

param vmssName           string
param vmssImgName        string
param vmssImgPublisher   string = "microsoftcorporation1602274591143"
param vmssImgProduct     string = "game-dev-vm"
param vmssImgSku         string = "win10_no_engine_1_0"
param vmssImgVersion     string = "latest"
param vmssSku            string
param vmssOsDiskType     string
param vmssInstanceCount  int	= 1

@description('Administrator Login for access')
param administratorLogin string

@description('Administrator Password for access')
@secure()
param passwordAdministratorLogin string

resource vmssName_resource 'Microsoft.Compute/virtualMachineScaleSets@2021-04-01' = {
  name: vmssName
  sku: {
    name: vmssSku
    tier: 'Standard'
    capacity: vmssInstanceCount
  }
  plan: (vmssCustomBaseImgEnabled ? json('null') : {
    name: vmssImgName
    publisher: vmssImgPublisher
    product: vmssImgProduct
  })
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
        computerName: vmName
        adminUsername: administratorLogin
        adminPassword: passwordAdministratorLogin
      }
      priority: 'Low'
      evictionPolicy: 'Delete'
    }
    overprovision: false
  }
}

output id   string = vmssName_resource.id
output name string = vmssName_resource.name
