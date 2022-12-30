@description('Name of the Ip Community Lists')
param ipCommunityListName string

@description('Azure Region for deployment of the Ip Community Lists and associated resources')
param location string = resourceGroup().location

var action = 'allow'
var localAS = 'true'
var gshut = 'true'
var internet = 'true'
var advertise = 'true'
var export = 'true'
var communityMember = '100'
var annotation = 'asdf'
var evpnEsImportRouteTarget = '201'

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
