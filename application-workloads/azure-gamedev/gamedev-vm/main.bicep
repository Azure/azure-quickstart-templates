
param location string = resourceGroup().location

@allowed([
  'ue_4_27'
  'ue_5_0ea'
])
param gameEngine string = 'ue_4_27'
@allowed([
  'win10'
  'ws2019'
])
param osType string = 'win10'

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

param administratorLogin string
@secure()
param passwordAdministratorLogin string

@description('Remote Access technology')
@allowed([
  'RDP'
  'Teradici'
  'Parsec'
])
param remoteAccessTechnology string = 'RDP'

module gamedevvm 'gamedev-vm.bicep'  = {
  name    : 'gamingDevVM'
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
