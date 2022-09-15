@description('Deployment Location')
param location string = resourceGroup().location

@description('Select Game Engine Version')
@allowed([
  'ue_4_27_2'
  'ue_5_0_1'
])
param gameEngine string = 'ue_4_27_2'

@description('Select Operating System')
@allowed([
  'win10'
  'ws2019'
])
param osType string = 'win10'

@description('Select Virtual Machine Skew')
@allowed([
  'Standard_NC4as_T4_v3'
  'Standard_NC8as_T4_v3'
  'Standard_NC16as_T4_v3'
  'Standard_NC64as_T4_v3'
  'Standard_NV6'
  'Standard_NV12'
  'Standard_NV24'
  'Standard_NV12s_v3'
  'Standard_NV24s_v3'
  'Standard_NV48s_v3'
])
param vmSize string = 'Standard_NV12s_v3'

@description('Administrator Login for access')
param administratorLogin string

@description('Administrator Password for access')
@secure()
param passwordAdministratorLogin string

@description('Remote Access technology')
@allowed([
  'RDP'
  'Teradici'
  'Parsec'
])
param remoteAccessTechnology string = 'RDP'

module gameDevVM 'br/public:azure-gaming/game-dev-vm:1.0.1' = {
  name: 'gamingDevVM'
  params: {
    location: location
    vmSize: vmSize
    adminName: administratorLogin
    adminPass: passwordAdministratorLogin
    osType: osType
    gameEngine: gameEngine
    remoteAccessTechnology: remoteAccessTechnology
  }
}
