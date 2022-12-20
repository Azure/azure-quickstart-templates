@description('Deployment Location')
param location string = resourceGroup().location

@description('Name of VMSS Cluster')
param vmssName string

@description('GameDev Sku')
param vmssSku string = 'Standard_D4ds_v4'

@description('GameDev Image Publisher')
@allowed([
  'microsoftcorporation1602274591143'
  'azure-gaming'
])
param vmssImgPublisher string = 'microsoftcorporation1602274591143'

@description('GameDev Image Product Id')
@allowed([
  'game-dev-vm'
])
param vmssImgProduct string = 'game-dev-vm'

@description('GameDev Image Sku')
@allowed([
  'win10_no_engine_1_0'
  'ws2019_no_engine_1_0'
  'win10_unreal_4_27_2'
  'ws2019_unreal_4_27_2'
  'win10_unreal_5_0_1'
  'ws2019_unreal_5_0_1'
])
param vmssImgSku string = 'win10_unreal_4_27_2'

@description('GameDev Image Product Id')
param vmssImgVersion string = 'latest'

@description('GameDev Disk Type')
param vmssOsDiskType string = 'Premium_LRS'

@description('VMSS Instance Count')
@maxValue(100)
@minValue(1)
param vmssInstanceCount int = 1

@description('Administrator Login for access')
param administratorLogin string

@description('Administrator Password for access')
@secure()
param passwordAdministratorLogin string

@description('File Share Storage Account name')
param fileShareStorageAccount string = ''

@description('File Share Storage Account key')
@secure()
param fileShareStorageAccountKey string = ''

@description('File Share name')
param fileShareName string = ''

@description('Perforce Port address')
param p4Port string = ''

@description('Perforce User')
param p4Username string = ''

@description('Perforce User password')
@secure()
param p4Password string = ''

@description('Perforce Client Workspace')
param p4Workspace string = ''

@description('Perforce Stream')
param p4Stream string = ''

@description('Perforce Depot Client View mappings')
param p4ClientViews string = ''

@description('Incredibuild License Key')
@secure()
param ibLicenseKey string = ''

@description('GDK Version')
param gdkVersion string = 'June_2021_Update_4'

@description('Use VM to sysprep an image from')
param useVmToSysprepCustomImage bool = false

@description('Remote Access technology')
@allowed([
  'RDP'
  'Teradici'
  'Parsec'
])
param remoteAccessTechnology string = 'RDP'

@description('Teradici Registration Key')
@secure()
param teradiciRegKey string = ''

@description('Parsec Team ID')
param parsecTeamId string = ''

@description('Parsec Team Key')
@secure()
param parsecTeamKey string = ''

@description('Parsec Hostname')
param parsecHost string = ''

@description('Parsec User Email')
param parsecUserEmail string = ''

@description('Parsec Is Guest Access')
param parsecIsGuestAccess bool = false

@description('Virtual Network Resource Name')
param vnetName string = 'vnet-${vmssName}'

@description('Virtual Network Subnet Name')
param subnetName string = 'subnet${vmssName}'

@description('Virtual Network Security Group Name')
param networkSecurityGroupName string = 'nsg-${vmssName}'

@description('Virtual Network Address Prefix')
param vnetAddressPrefix string = '172.17.72.0/24' //Change as needed

@description('Virtual Network Subnet Address Prefix')
param subnetAddressPrefix string = '172.17.72.0/25' // 172.17.72.[0-128] is part of this subnet

var customData = format('''
fileShareStorageAccount={0}
fileShareStorageAccountKey={1}
fileShareName={2}
p4Port={3}
p4Username={4}
p4Password={5}
p4Workspace={6}
p4Stream={7}
p4ClientViews={8}
ibLicenseKey={9}
gdkVersion={10}
useVmToSysprepCustomImage={11}
remoteAccessTechnology={12}
teradiciRegKey={13}
parsecTeamId={14}
parsecTeamKey={15}
parsecHost={16}
parsecUserEmail={17}
parsecIsGuestAccess={18}
deployedFromSolutionTemplate={19}
''', fileShareStorageAccount, fileShareStorageAccountKey, fileShareName, p4Port, p4Username, p4Password, p4Workspace, p4Stream, p4ClientViews, ibLicenseKey, gdkVersion, useVmToSysprepCustomImage, remoteAccessTechnology, teradiciRegKey, parsecTeamId, parsecTeamKey, parsecHost, parsecUserEmail, parsecIsGuestAccess, false)


module vnet './nestedtemplates/virtualNetworks.bicep'  = {
  name:                       vnetName
  params: {
    location:                 location
    vnetName:                 vnetName
    subnetName:               subnetName
    networkSecurityGroupName: networkSecurityGroupName
    vnetAddressPrefix:        vnetAddressPrefix
    subnetAddressPrefix:      subnetAddressPrefix
  }
}

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2021-04-01' = {
  name: vmssName
  location: location
  sku: {
    name:     vmssSku
    tier:     'Standard'
    capacity: vmssInstanceCount
  }
  plan: {
    name:      vmssImgSku
    publisher: vmssImgPublisher
    product:   vmssImgProduct
  }  
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
          offer:     vmssImgProduct
          sku:       vmssImgSku
          version:   vmssImgVersion
	}
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: '${vmssName}Nic'
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: '${vmssName}IpConfig'
                  properties: {
                    subnet: {
                      id: vnet.outputs.subnetId
                    }
                  }
                }
              ]
              networkSecurityGroup: {
                id: vnet.outputs.nsgID
              }
            }
          }
        ]
      }
      osProfile: {
        computerNamePrefix: vmssName
        adminUsername:      administratorLogin
        adminPassword:      passwordAdministratorLogin
	customData:         base64(customData)
	windowsConfiguration: {
          provisionVMAgent: true
        }	
      }
      priority: 'Regular'
    }
    overprovision: false
  }
}

output id   string = vmss.id
output name string = vmss.name
