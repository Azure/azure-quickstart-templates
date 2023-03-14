@description('Name of the Network Fabric Controller')
param networkFabricControllerName string

@description('Name of the Network Fabric Controller Resource Group')
param nfcResourceGroupName string

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

@description('Ipv4 address space used for NFC workload management')
param nfcIpv4AddressSpace string

@description('Name of the Network Fabric')
param networkFabricName string

@description('Name of the Network Fabric SKU')
param networkFabricSku string

@minValue(2)
@maxValue(8)
@description('Number of racks associated to Network Fabric')
param rackCount int

@minValue(1)
@maxValue(16)
@description('Number of servers per Rack')
param serverCountPerRack int

@description('IPv4 Prefix for Management Network')
param ipv4Prefix string

@description('IPv6 Prefix for Management Network')
param ipv6Prefix string

@minValue(1)
@maxValue(65535)
@description('ASN of CE devices for CE/PE connectivity')
param fabricASN int

@description('Username of terminal server')
param nfTSconfUsername string

@secure()
@description('Password of terminal server')
param nfTSconfPassword string

@description('Serial Number of Terminal server')
param nfTSconfSerialNumber string

@description('IPv4 Address Prefix of CE-PE interconnect links')
param nfTSconfPrimaryIpv4Prefix string

@description('IPv6 Address Prefix of CE-PE interconnect links')
param nfTSconfPrimaryIpv6Prefix string

@description('Secondary IPv6 Address Prefix of CE-PE interconnect links')
param nfTSconfSecondaryIpv4Prefix string

@description('Secondary IPv6 Address Prefix of CE-PE interconnect links')
param nfTSconfSecondaryIpv6Prefix string

@description('Manage the management VPN connection between Network Fabric and infrastructure services in Network Fabric Controller')
param nfMNconfInfraVpn object

@description('Manage the management VPN connection between Network Fabric and workload services in Network Fabric Controller')
param nfMNconfWorkloadVpn object

@description('List of Device to be updated ie., deviceName:serialNumber')
param nniMap object

var nniNameList = [for item in items(nniMap): item.key]

var nniPropertiesList = [for item in items(nniMap): item.value]

var nniCount = length(nniNameList)

@description('List of Device to be updated ie., deviceName:serialNumber')
param deviceMap object

var deviceNameList = [for item in items(deviceMap): item.key]

var serialNumberList = [for item in items(deviceMap): item.value]

var deviceCount = length(deviceNameList)

@description('Name of the Managed Identity')
param userIdentityName string

@description('Role Assignment Name')
param roleAssignmentName string

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

module nfc './modules/NFC.bicep' = {
  name: 'nfc'
  scope: resourceGroup(nfcResourceGroupName)
  params: {
    location: location
    networkFabricControllerName: networkFabricControllerName
    nfcInfraExRAuthKey: nfcInfraExRAuthKey
    nfcInfraExRCircuitId: nfcInfraExRCircuitId
    nfcIpv4AddressSpace: nfcIpv4AddressSpace
    nfcWorkloadExRAuthKey: nfcWorkloadExRAuthKey
    nfcWorkloadExRCircuitId: nfcWorkloadExRCircuitId
  }
}

@description('Create Network Fabric Resource')
resource networkFabrics 'Microsoft.ManagedNetworkFabric/networkFabrics@2023-02-01-preview' = {
  name: networkFabricName
  location: location
  properties: {
    networkFabricSku: networkFabricSku
    rackCount: rackCount
    serverCountPerRack: serverCountPerRack
    ipv4Prefix: ipv4Prefix != '' ? ipv4Prefix : null
    ipv6Prefix: ipv6Prefix != '' ? ipv6Prefix : null
    fabricASN: fabricASN
    networkFabricControllerId: nfc.outputs.resourceID
    terminalServerConfiguration: {
      username: nfTSconfUsername
      password: nfTSconfPassword
      serialNumber: nfTSconfSerialNumber
      primaryIpv4Prefix: nfTSconfPrimaryIpv4Prefix != '' ? nfTSconfPrimaryIpv4Prefix : null
      primaryIpv6Prefix: nfTSconfPrimaryIpv6Prefix != '' ? nfTSconfPrimaryIpv6Prefix : null
      secondaryIpv4Prefix: nfTSconfSecondaryIpv4Prefix != '' ? nfTSconfSecondaryIpv4Prefix : null
      secondaryIpv6Prefix: nfTSconfSecondaryIpv6Prefix != '' ? nfTSconfSecondaryIpv6Prefix : null
    }
    managementNetworkConfiguration: {
      infrastructureVpnConfiguration: nfMNconfInfraVpn
      workloadVpnConfiguration: nfMNconfWorkloadVpn
    }
  }
  resource networkToNetworkInterconnect 'networkToNetworkInterconnects' = [for i in range(0, nniCount): {
    name: nniNameList[i]
    properties: {
      isManagementType: nniPropertiesList[i].properties.isManagementType
      useOptionB: nniPropertiesList[i].properties.useOptionB
      layer2Configuration: nniPropertiesList[i].properties.layer2Configuration
      layer3Configuration: nniPropertiesList[i].properties.layer3Configuration
    }
  }]
}

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: userIdentityName
  location: location
  dependsOn: [
    networkFabrics
  ]
}

resource roleAssign 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' existing = {
  scope: subscription()
  name: roleAssignmentName
}

resource updateSerialNumber 'Microsoft.Resources/deploymentScripts@2020-10-01' = [for i in range(0, deviceCount): {
  name: '${deploymentScriptsName}-USN-${i}'
  location: location
  dependsOn: [
    userIdentity
  ]
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
  }
  properties: {
    scriptContent: loadTextContent('scripts/deviceUpdate.sh')
    azCliVersion: '2.42.0'
    retentionInterval: 'PT4H'
    environmentVariables: [
      {
        name: 'WHEEL_FILE_URL'
        value: wheelFileURL
      }
      {
        name: 'RESOURCEGROUP'
        value: resourceGroup().name
      }
      {
        name: 'DEVICENAME'
        value: deviceNameList[i]
      }
      {
        name: 'LOCATION'
        value: location
      }
      {
        name: 'SERIALNUMBER'
        value: serialNumberList[i]
      }
    ]
  }
}]

resource networkFabricProvision 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'networkFabricProvision'
  location: location
  dependsOn: [
    updateSerialNumber
  ]
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
  }
  properties: {
    scriptContent: loadTextContent('scripts/provision.sh')
    azCliVersion: '2.42.0'
    retentionInterval: 'PT4H'
    environmentVariables: [
      {
        name: 'WHEEL_FILE_URL'
        value: wheelFileURL
      }
      {
        name: 'RESOURCEGROUP'
        value: resourceGroup().name
      }
      {
        name: 'FABRICNAME'
        value: networkFabrics.name
      }
    ]
  }
}

@description('Create L2 Isolation Domain Resource')
resource l2IsolationDomains 'Microsoft.ManagedNetworkFabric/l2IsolationDomains@2023-02-01-preview' = [for i in range(0, l2DomainCount): {
  name: l2DomainsName[i]
  location: location
  dependsOn: [
    networkFabricProvision
  ]
  properties: {
    networkFabricId: networkFabrics.id
    vlanId: l2DomainsProperties[i].properties.vlanId
    mtu: l2DomainsProperties[i].properties.mtu
  }
}]

resource l2DomainUpdateAdminState 'Microsoft.Resources/deploymentScripts@2020-10-01' = [for i in range(0, l2DomainCount): {
  name: '${deploymentScriptsName}-L2UAS-${i}'
  location: location
  dependsOn: [
    l2IsolationDomains
  ]
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
  }
  properties: {
    scriptContent: 'az extension add --source ${wheelFileURL} -y; az nf l2domain update-admin-state --resource-name "${l2DomainsName[i]}" --resource-group ${resourceGroup().name} --state "Enable"'
    azCliVersion: '2.42.0'
    retentionInterval: 'PT4H'
  }
}]

module isd './modules/ISD.bicep' = [for i in range(0, l3DomainCount): {
  name: 'isd-${i}'
  dependsOn: [
    l2DomainUpdateAdminState
  ]
  params: {
    location: location
    l3DomainName: l3DomainsName[i]
    ISDList: ISD
    index: i
    fabricId: networkFabrics.id
  }
}]

resource l3DomainUpdateAdminState 'Microsoft.Resources/deploymentScripts@2020-10-01' = [for i in range(0, l3DomainCount): {
  name: '${deploymentScriptsName}-L3UAS-${i}'
  location: location
  dependsOn: [
    isd
  ]
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
  }
  properties: {
    scriptContent: 'az extension add --source ${wheelFileURL} -y; az nf l3domain update-admin-state --resource-name "${l3DomainsName[i]}" --resource-group ${resourceGroup().name} --state "Enable"'
    azCliVersion: '2.42.0'
    retentionInterval: 'PT4H'
  }
}]
