
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

param managedResourceGroupId string = ''

resource solution_resource 'Microsoft.Solutions/applications@2017-09-01'  = {
  name    : 'gamingDevVM'
  location: location
  kind    : 'MarketPlace'
  plan    : {
    'name': 'game-dev-vm-amatest-plan'
    'product': 'f39e77ad-ada5-4145-9291-643e6e3ce1b2'
    'publisher': 'microsoftcorporation1602274591143'
    'version': '0.1.121'
  }
  properties: {
    managedResourceGroupId: (empty(managedResourceGroupId) ? '${subscription().id}/resourceGroups/${take('${resourceGroup().name}-mrg', 90)}' : managedResourceGroupId)
    parameters: {
      location: {
        value: location
      }
      vmSize: {
        value: vmSize
      }
      adminName: {
        value: administratorLogin
      }
      adminPass: {
        value: passwordAdministratorLogin
      }
      osType: {
        value: osType
      }
      gameEngine: {
        value: gameEngine
      }
      remoteAccessTechnology: {
        value: remoteAccessTechnology
      }
    }
  }
}
