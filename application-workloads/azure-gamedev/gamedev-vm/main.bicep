@description('Resource Location.')
param location string = resourceGroup().location

@description('Virtual Machine Size.')
param vmSize string = 'Standard_NV12s_v3'

@description('Use VM to sysprep an image from')
param useVmToSysprepCustomImage bool = false

@description('Virtual Machine Name.')
param vmName string = 'gamedevvm'

@description('Virtual Machine User Name .')
param adminName string

@metadata({ type: 'password', description: 'Admin password.' })
@secure()
param adminPass string

@description('Operating System type')
@allowed([ 'win10', 'ws2019' ])
param osType string = 'win10'

@description('Game Engine')
@allowed([ 'no_engine', 'ue_4_27_2', 'ue_5_0_1' ])
param gameEngine string = 'ue_4_27_2'

@description('GDK Version')
@allowed([ 'June_2022_Update_1', 'March_2022_Update_1', 'October_2021_Update_5', 'June_2021_Update_9' ])
param gdkVersion string = 'June_2021_Update_9'

@description('Incredibuild License Key')
@secure()
param ibLicenseKey string = ''

@description('Remote Access technology')
@allowed([ 'RDP', 'Teradici', 'Parsec' ])
param remoteAccessTechnology string = 'RDP'

@description('Teradici Registration Key')
@secure()
param teradiciRegKey string = ''

@description('Parsec Team ID')
param parsec_teamId string = ''

@description('Parsec Team Key')
@secure()
param parsec_teamKey string = ''

@description('Parsec Hostname')
param parsec_host string = ''

@description('Parsec User Email')
param parsec_userEmail string = ''

@description('Parsec Is Guest Access')
param parsec_isGuestAccess bool = false

@description('Number of data disks')
param numDataDisks int = 0

@description('Disk Performance Tier')
param dataDiskSize int = 1024

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

@description('Virtual Network name')
param vnetName string = 'gamedev-vnet'

@description('Address prefix of the virtual network')
param vnetARPrefixes array = [ '10.0.0.0/26' ]

@description('Virtual network is new or existing')
param vnetNewOrExisting string = 'new'

@description('Resource Group of the Virtual network')
param vnetRGName string = resourceGroup().name

@description('VM Subnet name')
param subNetName string = 'gamedev-vnet-subnet1'

@description('Subnet prefix of the virtual network')
param subNetARPrefix string = '10.0.0.0/28'

@description('Unique public ip address name')
param publicIpName string = 'GameDevVM-IP'

@description('Unique DNS Public IP attached the VM')
param publicIpDns string = 'gamedevvm${uniqueString(resourceGroup().id)}'

@description('Public IP Allocoation Method')
param publicIpAllocationMethod string = 'Dynamic'

@description('SKU number')
@allowed([ 'Basic', 'Standard' ])
param publicIpSku string = 'Basic'

@description('Public IP New or Existing or None?')
@allowed([ 'new', 'existing', 'none' ])
param publicIpNewOrExisting string = 'new'

@description('Resource Group of the Public IP Address')
param publicIpRGName string = resourceGroup().name

@description('Select Image Deployment for debugging only')
@allowed([ 'development', 'production' ])
param environment string = 'production'

@description('Tags by resource.')
param outTagsByResource object = {}

@description('Enable or disable Unreal Pixel Streaming port.')
param unrealPixelStreamingEnabled bool = false

@description('Enable or disable the use of a Managed Identity for the VM.')
param enableManagedIdentity bool = false

@description('Enable or disable AAD-based login.')
param enableAAD bool = false

@description('Specifies the OS patching behavior.')
@allowed([ 'AutomaticByOS', 'AutomaticByPlatform', 'Manual' ])
param windowsUpdateOption string = 'AutomaticByOS'

module gameDevVM 'br/public:azure-gaming/game-dev-vm:1.0.2' = {
  name: 'gameDevVM-${deployment().name}'
  params: {
    location: location
    vmSize: vmSize
    useVmToSysprepCustomImage: useVmToSysprepCustomImage
    vmName: vmName
    adminName: adminName
    adminPass: adminPass
    osType: osType
    gameEngine: gameEngine
    gdkVersion: gdkVersion
    ibLicenseKey: ibLicenseKey
    remoteAccessTechnology: remoteAccessTechnology
    teradiciRegKey: teradiciRegKey
    parsec_teamId: parsec_teamId
    parsec_teamKey: parsec_teamKey
    parsec_host: parsec_host
    parsec_userEmail: parsec_userEmail
    parsec_isGuestAccess: parsec_isGuestAccess
    numDataDisks: numDataDisks
    dataDiskSize: dataDiskSize
    fileShareStorageAccount: fileShareStorageAccount
    fileShareStorageAccountKey: fileShareStorageAccountKey
    fileShareName: fileShareName
    p4Port: p4Port
    p4Username: p4Username
    p4Password: p4Password
    p4Workspace: p4Workspace
    p4Stream: p4Stream
    p4ClientViews: p4ClientViews
    vnetName: vnetName
    vnetARPrefixes: vnetARPrefixes
    vnetNewOrExisting: vnetNewOrExisting
    vnetRGName: vnetRGName
    subNetName: subNetName
    subNetARPrefix: subNetARPrefix
    publicIpName: publicIpName
    publicIpDns: publicIpDns
    publicIpAllocationMethod: publicIpAllocationMethod
    publicIpSku: publicIpSku
    publicIpNewOrExisting: publicIpNewOrExisting
    publicIpRGName: publicIpRGName
    environment: environment
    outTagsByResource: outTagsByResource
    unrealPixelStreamingEnabled: unrealPixelStreamingEnabled
    enableManagedIdentity: enableManagedIdentity
    enableAAD: enableAAD
    windowsUpdateOption: windowsUpdateOption
  }
}
