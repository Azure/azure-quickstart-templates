@description('Name of the Network Fabric Controller')
param networkFabricControllerName string

@description('Azure Region for deployment of the Network Fabric Controller and associated resources')
param location string = resourceGroup().location

@description('Name of Express Route circuit')
param nfcInfraExRCircuitId string

@description('Authorization key for the circuit')
param nfcInfraExRAuthKey string

@description('Name of Express Route circuit')
param nfcWorkloadExRCircuitId string

@description('Authorization key for the circuit')
param nfcWorkloadExRAuthKey string

@description('Managed Resource Group name')
param nfcManagedResourceGroupName string

@description('Ipv4 address space used for NFC workload management')
param nfcIpv4AddressSpace string

@description('Name of the Network Fabric')
param networkFabricName string

@description('Name of the Network Fabric SKU')
param networkFabricSku string

@description('Layer2 Configuration of Network to Network Inter-connectivity configuration between CEs and PEs')
param nfNniLayer2conf object

@description('Layer3 Configuration of Network to Network Inter-connectivity configuration between CEs and PEs')
param nfNniLayer3conf object

@description('Username of terminal server')
param nfTSconfUsername string

@secure()
@description('Password of terminal server')
param nfTSconfPassword string

@description('IPv4 Prefix for connectivity between TS and PE1')
param nfTSconfPrimaryIpv4Prefix string

@description('IPv4 Prefix for connectivity between TS and PE12')
param nfTSconfSecondaryIpv4Prefix string

@description('IPv4 Prefix of the management network')
param nfMNconfIpv4Prefix string

@description('Manage the management VPN connection between Network Fabric and infrastructure services in Network Fabric Controller')
param nfMNconfManVpn object

@description('Manage the management VPN connection between Network Fabric and workload services in Network Fabric Controller')
param nfMNconfWorkloadVpn object

@description('List of Racks to be created')
param racks object

var racksName = [for item in items(racks): item.key]

var racksProperties = [for item in items(racks): item.value]

var rackCount = length(racksName)

@description('List of Device to be updated ie., deviceName:serialNumber')
param deviceMap object

var deviceNameList = [for item in items(deviceMap): item.key]

var serialNumberList = [for item in items(deviceMap): item.value]

var deviceCount = length(deviceNameList)

@description('Name of the Managed Identity')
param userIdentityName string

@description('Id of the Role')
param roleId string

@description('Role Definition ID')
param roleDefinitionId string = resourceId('microsoft.authorization/roleDefinitions', roleId) // 21d96096-b162-414a-8302-d8354f9d91b2        94ddc4bc-25f5-4f3e-b527-c587da93cfe4        b24988ac-6180-42a0-ab88-20f7382dd24c        8e3af657-a8ff-443c-a75c-2fe8c4bcb635

@description('Role Assignment Name')
param roleAssignmentName string = guid(userIdentityName, roleDefinitionId, resourceGroup().id)

@description('URL of the globally available wheel file')
param wheelFileURL string

@description('Name of the Deployment Script')
param deploymentScriptsName string

@description('List of L2domain to be created')
param l2Domain object

var l2DomainsName = [for item in items(l2Domain): item.key]

var l2DomainsProperties = [for item in items(l2Domain): item.value]

var l2DomainCount = length(l2DomainsName)

@description('List of L3domain and Internal/External Networks to be created')
param ISD object

var l3DomainsName = [for item in items(ISD): item.key]

var l3DomainCount = length(l3DomainsName)

@description('Create Network Fabric Controller Resource')
resource networkFabricController 'Microsoft.ManagedNetworkFabric/networkFabricControllers@2022-01-15-privatepreview' = {
  name: networkFabricControllerName
  location: location
  properties: {
    infrastructureExpressRouteConnections: [
      {
        expressRouteCircuitId: nfcInfraExRCircuitId
        expressRouteAuthorizationKey: nfcInfraExRAuthKey
      }
    ]
    workloadExpressRouteConnections: [
      {
        expressRouteCircuitId: nfcWorkloadExRCircuitId
        expressRouteAuthorizationKey: nfcWorkloadExRAuthKey
      }
    ]
    managedResourceGroupConfiguration: {
      name: nfcManagedResourceGroupName
      location: location
    }
    ipv4AddressSpace: nfcIpv4AddressSpace
  }
}

@description('Create Network Fabric Resource')
resource networkFabrics 'Microsoft.ManagedNetworkFabric/networkFabrics@2022-01-15-privatepreview' = {
  name: networkFabricName
  location: location
  properties: {
    networkFabricSku: networkFabricSku
    networkFabricControllerId: networkFabricController.id
    networkToNetworkInterconnect: {
      layer2Configuration: nfNniLayer2conf
      layer3Configuration: nfNniLayer3conf
    }
    terminalServerConfiguration: {
      username: nfTSconfUsername
      password: nfTSconfPassword
      primaryIpv4Prefix: nfTSconfPrimaryIpv4Prefix
      secondaryIpv4Prefix: nfTSconfSecondaryIpv4Prefix
    }
    managementNetworkConfiguration: {
      ipv4Prefix: nfMNconfIpv4Prefix
      managementVpnConfiguration: nfMNconfManVpn
      workloadVpnConfiguration: nfMNconfWorkloadVpn
    }
  }
}

@description('Create Network Rack Resource')
resource networkRacks 'Microsoft.ManagedNetworkFabric/networkRacks@2022-01-15-privatepreview' = [for i in range(0, rackCount): {
  name: racksName[i]
  location: location
  properties: {
    networkRackSku: racksProperties[i].properties.networkRackSku
    networkFabricId: networkFabrics.id
  }
}]

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: userIdentityName
  location: location
  dependsOn: [
    networkRacks // once fabric is created, we need to create the managed identity to make POST action
  ]
}

resource roleAssign 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleAssignmentName
  properties: {
    roleDefinitionId: roleDefinitionId // once managed identity is created, assign the 'Owner' permission to it.
    principalId: userIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource deploymentScripts 'Microsoft.Resources/deploymentScripts@2020-10-01' = [for i in range(0, deviceCount): {
  name: '${deploymentScriptsName}-${i}'
  location: location
  dependsOn: [
    roleAssign
  ]
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
  }
  properties: {
    scriptContent: 'az extension add --source ${wheelFileURL} -y; response=$(az nf device show -g ${resourceGroup().name} --resource-name "${deviceNameList[i]}"); role=$(echo "$response" | grep networkDeviceRole | cut -b 24- | head --bytes -2); sku=$(echo "$response" | grep networkDeviceSku | cut -b 23- | head --bytes -2);  az nf device update --resource-group ${resourceGroup().name}  --location ${location}  --resource-name "${deviceNameList[i]}" --serial-number "${serialNumberList[i]}" --network-device-sku "$sku" --network-device-role "$role"; if [ $((${deviceCount}-1)) -eq ${i} ]; then result=$(az nf fabric provision -g ${resourceGroup().name} --resource-name ${networkFabrics.name}); fi'
    azCliVersion: '2.42.0'
    retentionInterval: 'PT4H'
  }
}]

@description('Create L2 Isolation Domain Resource')
resource l2IsolationDomains 'Microsoft.ManagedNetworkFabric/l2IsolationDomains@2022-01-15-privatepreview' = [for i in range(0, l2DomainCount): {
  name: l2DomainsName[i]
  location: location
  dependsOn: [
    deploymentScripts
  ]
  properties: {
    networkFabricId: networkFabrics.id
    vlanId: l2DomainsProperties[i].properties.vlanId
    mtu: l2DomainsProperties[i].properties.mtu
  }
}]

module isd './ISD.bicep' = [for i in range(0, l3DomainCount): {
  name: 'isd-${i}'
  dependsOn: [
    deploymentScripts
  ]
  params: {
    l3DomainName: l3DomainsName[i]
    ISDList: ISD
    index: i
    fabricId: networkFabrics.id
  }
}]
