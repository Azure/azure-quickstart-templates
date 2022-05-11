@description('Deployment Location')
param location string = resourceGroup().location

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.')
@secure()
param _artifactsLocationSasToken string = ''

@description('Select Game Engine Version')
@allowed([
  'ue_4_27'
  'ue_5_0ea'
])
param gameEngine string = 'ue_4_27'

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

module gamedevvm './nestedtemplates/gamedev-vm.bicep'  = {
  name: 'gamingDevVM'
  params: {
    location: location
    vmSize: vmSize
    adminName: administratorLogin
    adminPass: passwordAdministratorLogin
    osType: osType
    gameEngine: gameEngine
    remoteAccessTechnology: remoteAccessTechnology
    _artifactsLocation: _artifactsLocation
    _artifactsLocationSasToken: _artifactsLocationSasToken
  }
}
