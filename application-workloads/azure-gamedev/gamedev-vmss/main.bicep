@description('Deployment Location')
param location string = resourceGroup().location

@description('Name of VMSS Cluster')
param vmssName string

@description('GameDev Sku')
param vmssSku string = 'Standard_D4ds_v4'

@description('GameDev Image Publisher')
@allowed([
  'microsoftcorporation1602274591143'
  'microsoft-azure-gaming'
])
param vmssImgPublisher string = 'microsoft-azure-gaming'

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
@allowed([
  'June_2022_Update_1'
  'March_2022_Update_1'
  'October_2021_Update_5'
  'June_2021_Update_9'
])
param gdkVersion string = 'June_2021_Update_9'

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

module vmss 'br/public:azure-gaming/game-dev-vmss:1.0.1' = {
  name: 'gameDevVMSS'
  params: {
    location: location
    vmssName: vmssName    
    vmssSku: vmssSku
    vmssInstanceCount: vmssInstanceCount
    vmssImgSku: vmssImgSku
    vmssImgPublisher: vmssImgPublisher
    vmssOsDiskType: vmssOsDiskType
    vmssImgVersion: vmssImgVersion
    administratorLogin: administratorLogin
    passwordAdministratorLogin: passwordAdministratorLogin
    fileShareStorageAccount: fileShareStorageAccount
    fileShareStorageAccountKey: fileShareStorageAccountKey
    fileShareName: fileShareName
    p4Port: p4Port
    p4Username: p4Username
    p4Password: p4Password
    p4Workspace: p4Workspace
    p4Stream: p4Stream
    p4ClientViews: p4ClientViews
    ibLicenseKey: ibLicenseKey
    gdkVersion: gdkVersion
    useVmToSysprepCustomImage: useVmToSysprepCustomImage
    remoteAccessTechnology: remoteAccessTechnology
    teradiciRegKey: teradiciRegKey
    parsecTeamId: parsecTeamId
    parsecTeamKey: parsecTeamKey
    parsecHost: parsecHost
    parsecUserEmail: parsecUserEmail
    parsecIsGuestAccess: parsecIsGuestAccess	
    vnetName: vnetName
    subnetName: subnetName
    networkSecurityGroupName: networkSecurityGroupName
    vnetAddressPrefix: vnetAddressPrefix
    subnetAddressPrefix: subnetAddressPrefix    
  }
}

output id   string = vmss.outputs.id
output name string = vmss.outputs.name
