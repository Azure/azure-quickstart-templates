// Creates private endpoints and DNS zones for the azure machine learning workspace
@description('Azure region of the deployment')
param location string

@description('AI Hub private link endpoint name')
param aiInboundPrivateEndpoint string

@description('Resource ID of the virtual network resource')
param virtualNetworkId string

@description('Resource ID of the machine learning workspace')
param workspaceArmId string

@description('Tags to add to the resources')
param tags object

@description('Resource ID of the subnet resource')
param subnetId string

var privateDnsZoneName =  {
  azurecloud: 'privatelink.api.azureml.ms'
}

var privateAznbDnsZoneName = {
    azurecloud: 'privatelink.notebooks.azure.net'
}

resource aiPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: aiInboundPrivateEndpoint
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: aiInboundPrivateEndpoint
        properties: {
          groupIds: [
            'amlworkspace'
          ]
          privateLinkServiceId: workspaceArmId
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource aiPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName[toLower(environment().name)]
  location: 'global'
}

resource aiPrivateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${aiPrivateDnsZone.name}/${uniqueString(workspaceArmId)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

// Notebook
resource notebookPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateAznbDnsZoneName[toLower(environment().name)]
  location: 'global'
}

resource notebookPrivateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${notebookPrivateDnsZone.name}/${uniqueString(workspaceArmId)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource privateEndpointDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  name: '${aiPrivateEndpoint.name}/amlworkspace-PrivateDnsZoneGroup'
  properties:{
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneName[environment().name]
        properties:{
          privateDnsZoneId: aiPrivateDnsZone.id
        }
      }
      {
        name: privateAznbDnsZoneName[environment().name]
        properties:{
          privateDnsZoneId: notebookPrivateDnsZone.id
        }
      }
    ]
  }
}
