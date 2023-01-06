@description('Name of the Ip Community Lists')
param ipCommunityListName string

@description('Azure Region for deployment of the Ip Community Lists and associated resources')
param location string = resourceGroup().location

@description('Action')
param action string

@description('Local Autonomous System')
param localAS string

@description('Graceful Shutdown ')
param gshut string

@description('Internet access')
param internet string

@description('Avertise')
param advertise string

@description('Export')
param export string

@description('CommunityMember of the Ip Community List')
param communityMember string

@description('Switch configuration description')
param annotation string

@description('evpnEsImportRouteTarget of the Ip Community List')
param evpnEsImportRouteTarget string

@description('Create Ip Community Lists Resource')
resource ipCommunityLists 'Microsoft.ManagedNetworkFabric/ipCommunityLists@2022-01-15-privatepreview' = {
  name: ipCommunityListName
  location: location
  properties: {
    action: action
    localAS: localAS
    gshut: gshut
    internet: internet
    advertise: advertise
    export: export
    communityMembers: [
      {
        communityMember: communityMember
        annotation: annotation
      }
    ]
    evpnEsImportRouteTargets: [
      {
        evpnEsImportRouteTarget: evpnEsImportRouteTarget
      }
    ]
  }
}

output resourceID string = ipCommunityLists.id
