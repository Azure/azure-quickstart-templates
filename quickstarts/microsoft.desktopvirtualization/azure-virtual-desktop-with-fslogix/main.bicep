@description('Location for all resources.')
param location string = resourceGroup().location


// Parameters from the azuredeploy.parameters.json file
@description('Is the AVD FSLogix enabled or not')
param fslogixEnabled bool
@description('Virtual network resource name.')
param virtualNetworkName string
//@description('Peer Virtual network with Hub network')
//param virtualNetworkPeeringToHub bool
@description('Virtual network resource Subnet 1 name.')
param subnetName1 string
@description('Virtual network resource Subnet 2 name.')
param subnetName2 string
@secure()
@description('Virtual machine resource admin password')
param vmAdminPassword string
@description('Enable Active directory authentication')
param activeDirectoryAuthenticationEnabled bool
@secure()
@description('The password that corresponds to the existing domain username.')
param ADAdministratorAccountPassword string


// Required parameters
@description('Virtual network resource Address Space.')
param virtualNetworkAddressSpace string = '10.100.0.0/16'
@description('Virtual network resource Subnet 1 Address Prefix.')
param subnetAddressPrefix1 string = '10.100.0.0/24'
@description('Virtual network resource Subnet 2 Address Prefix.')
param subnetAddressPrefix2 string = '10.100.1.0/24'
//@description('Hub Virtual network object')
//param hubVirtualNetwork object = {
//  virtualNetworkRG: 'nothing'
//  virtualNetworkName: 'nothing'
//}
@description('Number of session host to create')
param numberOfSessionHost int = 2
@secure()
@description('Virtual machine resource admin username')
param vmAdminUsername string
@description('Virtual machine size')
param vmSize string = 'Standard_D2s_v3'
@description('Domain name to join')
param DomainName string = activeDirectoryAuthenticationEnabled ? 'contoso.com' : ''
@description('OUPath for the domain join')
param DomainJoinOUPath string = activeDirectoryAuthenticationEnabled ? 'OU=SessionHosts,OU=AVD-Objects,OU=AzureVirtualDesktop,DC=contoso,DC=com' : ''
@description('The username for the domain admin.')
param ADAdministratorAccountUsername string = activeDirectoryAuthenticationEnabled ? 'test@contoso.com' : ''
@description('Azure virtual desktop DSC Extension')
param artifactsLocation string = 'https://wvdportalstorageblob.blob.${environment().suffixes.storage}/galleryartifacts/Configuration_1.0.02797.442.zip'
@description('AVD Application group and File share admin group object id')
param adminGroupObjectId string = ''
@description('AVD Application group and File share user group object id')
param userGroupObjectId string = ''
@description('Storage account name')
param storageAccountName string = fslogixEnabled ? 'storage${uniqueString(resourceGroup().id)}' : ''
@description('Azure storage account share name')
param fileShareName string = fslogixEnabled ? 'avdfileshare' : ''
@description('Azure storage account share quota')
param fileShareQuota int = fslogixEnabled ? 5120 : 0
@description('Azure recovery service vault name')
param recoveryServiceVaultName string = fslogixEnabled ? 'rsv-${uniqueString(resourceGroup().id)}' : ''
@description('Host pool resource name')
param hostPoolName string = 'hostpool-${uniqueString(resourceGroup().id)}'
@description('Application groups resource name')
param applicationGroupName string = 'ag-${uniqueString(resourceGroup().id)}'
@description('Workspace resource name')
param workspaceName string = 'workspace-${uniqueString(resourceGroup().id)}'


// Unchange parameters
@description('Storage account private dns zone')
param filePrivateDnsZoneName string = fslogixEnabled ? 'privatelink.file.${environment().suffixes.storage}' : ''
@description('Azure storage file private endpoint groupId')
param filePrivateEndpointGroupName string = fslogixEnabled ? 'file' : ''
@description('Azure AVD Application group Desktop Virtualization User role assignment')
param avdRoleDefinitionId string = resourceId('Microsoft.Authorization/roleDefinitions', '1d18fff3-a72a-46b5-b4a9-0b38a3cd7e63')
@description('Storage account role definition for Storage File Data SMB Share Elevated Contributor file share admin access')
param adminRoleDefinitionId string = fslogixEnabled ? resourceId('Microsoft.Authorization/roleDefinitions', 'a7264617-510b-434b-a828-9731dc254ea7') : ''
@description('Storage account role definition for Storage File Data SMB Share Contributor file share user access')
param userRoleDefinitionId string = fslogixEnabled ? resourceId('Microsoft.Authorization/roleDefinitions', '0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb') : ''
@description('Application group Entra ID Group object ids for Desktop Virtualization User role assignment')
param GroupObjectIds array = adminGroupObjectId != '' && userGroupObjectId != '' ? [adminGroupObjectId, userGroupObjectId] : []


// Required variables
@description('Host pool resource property configuration')
var hostPoolProperties = {
  friendlyName: hostPoolName
  description: 'Azure Virtual Desktop host pool'
  hostPoolType: fslogixEnabled ? 'Pooled' : 'Personal'
  personalDesktopAssignmentType: fslogixEnabled ? '' : 'Direct'
  maxSessionLimit: 999999
  loadBalancerType: fslogixEnabled ? 'BreadthFirst' : 'Persistent'
  validationEnvironment: true
  preferredAppGroupType: 'Desktop'
  publicNetworkAccess: 'Enabled'
  customRdpProperty: 'targetisaadjoined:i:1;drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;redirectwebauthn:i:1;use multimon:i:1;'
  directUDP: 'Default'
  managedPrivateUDP: 'Default'
  managementType: 'Standard'
  publicUDP: 'Default'
  relayUDP: 'Default'
  startVMOnConnect: false
  registrationInfo: {
    expirationTime: dateTimeAdd('2024-10-19 00:00:00Z', 'P2D')
    registrationTokenOperation: 'Update'
  }
}
@description('Application group resource property configuration')
var applicationGroupProperties = {
  applicationGroupType: 'Desktop'
  friendlyName: applicationGroupName
  description: 'Azure Virtual Desktop application group'
}
@description('Workspace resource property configuration')
var workspaceProperties = {
  description: 'Azure Virtual Desktop workspace'
  friendlyName: workspaceName
  publicNetworkAccess: 'Enabled'
}
@description('Virtual machine resource object')
var virtualMachine = {
  name: 'azurevm'
  licenseType: 'Windows_Client'
  vmSize: vmSize
  osDisk: {
    createOption: 'FromImage'
    storageAccountType: 'Premium_LRS'
    deleteOption: 'Delete'
  }
  imageReference: {
    publisher: 'microsoftwindowsdesktop'
    offer: 'office-365'
    sku: 'win11-23h2-avd-m365'
    version: 'latest'
  }
}

module network 'modules/virtualnetwork/main.bicep' = {
  name: 'networkComponent'
  params: {
    location: location
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressSpace: virtualNetworkAddressSpace
    //virtualNetworkPeeringToHub: virtualNetworkPeeringToHub
    //hubVirtualNetworkRG: hubVirtualNetwork.virtualNetworkRG
    //hubVirtualNetworkName: hubVirtualNetwork.virtualNetworkName
    subnetName1: subnetName1
    subnetAddressPrefix1: subnetAddressPrefix1
    subnetName2: subnetName2
    subnetAddressPrefix2: subnetAddressPrefix2
  }
}

module storageAccount 'modules/storage/main.bicep' = if (fslogixEnabled) {
  name: 'storageAccountComponent'
  params: {
    location: location
    storageAccountName: storageAccountName
    adminRoleDefinitionId: adminRoleDefinitionId
    userRoleDefinitionId: userRoleDefinitionId
    adminGroupObjectId: adminGroupObjectId
    userGroupObjectId: userGroupObjectId
    fileShareName: fileShareName
    fileShareQuota: fileShareQuota
    filePrivateDnsZoneName: filePrivateDnsZoneName
    virtualNetworkId: network.outputs.virtualNetworkId
    subnetId: network.outputs.subnetId2
    filePrivateEndpointGroupName: filePrivateEndpointGroupName
    recoveryServiceVaultName: recoveryServiceVaultName
  }
}

module virtualDesktop 'modules/virtualdesktop/main.bicep' = {
  name: 'virtualDesktopComponent'
  params: {
    location: location
    hostPoolName: hostPoolName
    applicationGroupName: applicationGroupName
    workspaceName: workspaceName
    hostPoolProperties: hostPoolProperties
    applicationGroupProperties: applicationGroupProperties
    workspaceProperties: workspaceProperties
    avdRoleDefinitionId: avdRoleDefinitionId
    GroupObjectIds: GroupObjectIds

    fslogixEnabled: fslogixEnabled
    subnetId: network.outputs.subnetId1
    numberOfSessionHost: numberOfSessionHost
    virtualMachine: virtualMachine
    adminUsername: vmAdminUsername
    adminPassword: vmAdminPassword
    activeDirectoryAuthenticationEnabled: activeDirectoryAuthenticationEnabled
    DomainName: DomainName
    DomainJoinOUPath: DomainJoinOUPath
    ADAdministratorAccountUsername: ADAdministratorAccountUsername
    ADAdministratorAccountPassword: ADAdministratorAccountPassword
    artifactsLocation: artifactsLocation
  }
}
