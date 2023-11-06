@description('The user or group id that will be granted to Devcenter Dev Box User and Deployment Environments User role')
param userPrincipalId string = ''

@description('The type of principal id: User or Group')
@allowed([
  'Group'
  'User'
  'ServicePrincipal'
])
param userPrincipalType string = 'User'

@description('Primary location for all resources e.g. eastus')
param location string = resourceGroup().location

@description('The suffix of the resource name. It will be used to generate the resource name. e.g. devcenter-default')
param suffix string = 'default'

@description('The name of Dev Center e.g. dc-devbox-test')
var devcenterName = 'devcenter-${suffix}'

@description('The name of Dev Center project e.g. dcprj-devbox-test')
var projectName = 'project-${suffix}'

@description('The name of Network Connection e.g. con-devbox-test')
var networkConnectionName = 'connection-${suffix}'

@description('The name of Dev Center user identity')
var userIdentityName = 'user-identitiy-${suffix}'

@description('The name of the Virtual Network e.g. vnet-dcprj-devbox-test-eastus')
var networkVnetName = 'vnet-devcenter-${suffix}'

@description('the subnet name of Dev Box e.g. default')
var networkSubnetName = 'default'

@description('The vnet address prefixes of Dev Box e.g. 10.4.0.0/16')
var networkVnetAddressPrefixes = '10.4.0.0/16'

@description('The subnet address prefixes of Dev Box e.g. 10.4.0.0/24')
var networkSubnetAddressPrefixes = '10.4.0.0/24'

@description('The name of Azure Compute Gallery')
var imageGalleryName = 'gallery${suffix}'

@description('The name of Azure Compute Gallery image definition')
var imageDefinitionName = 'CustomizedImage'

@description('The name of image template for customized image')
var imageTemplateName = 'CustomizedImageTemplate'

@description('The name of image offer')
var imageOffer = 'windows-ent-cpc'

@description('The name of image publisher')
var imagePublisher = 'MicrosoftWindowsDesktop'

@description('The name of image sku')
var imageSku = 'win11-22h2-ent-cpc-m365'

@description('The guid id that generat the different name for image template. Please keep it by default')
var guidId = guid(resourceGroup().id, location)

@description('The subnet resource id if the user wants to use existing subnet')
var existingSubnetId = ''

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(resourceGroup().id, location))
var ncName = !empty(networkConnectionName) ? networkConnectionName : '${abbrs.networkConnections}${resourceToken}'
var idName = !empty(userIdentityName) ? userIdentityName : '${abbrs.managedIdentityUserAssignedIdentities}${resourceToken}'

module vnet 'modules/vnet.bicep' = if(empty(existingSubnetId)) {
  name: 'vnet'
  params: {
    location: location
    vnetAddressPrefixes: networkVnetAddressPrefixes
    vnetName: !empty(networkVnetName) ? networkVnetName : '${abbrs.networkVirtualNetworks}${resourceToken}'
    subnetAddressPrefixes: networkSubnetAddressPrefixes
    subnetName: !empty(networkSubnetName) ? networkSubnetName : '${abbrs.networkVirtualNetworksSubnets}${resourceToken}'
  }
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: idName
  location: location
}

module gallery 'modules/gallery.bicep' = {
  name: 'gallery'
  params: {
    galleryName: !empty(imageGalleryName) ? imageGalleryName : '${abbrs.computeGalleries}${resourceToken}'
    location: location
    imageDefinitionName: imageDefinitionName
    imageOffer: imageOffer
    imagePublisher: imagePublisher
    imageSku: imageSku
    imageTemplateName: imageTemplateName
    templateIdentityName: '${abbrs.managedIdentityUserAssignedIdentities}tpl-${resourceToken}'
    guidId: guidId
  }
}

module devcenter 'modules/devcenter.bicep' = {
  name: 'devcenter'
  params: {
    location: location
    devcenterName: !empty(devcenterName) ? devcenterName : '${abbrs.devcenter}${resourceToken}'
    subnetId: !empty(existingSubnetId) ? existingSubnetId : vnet.outputs.subnetId
    networkConnectionName: ncName
    projectName: !empty(projectName) ? projectName : '${abbrs.devcenterProject}${resourceToken}'
    networkingResourceGroupName: '${abbrs.devcenterNetworkingResourceGroup}${ncName}-${location}'
    principalId: userPrincipalId
    principalType: userPrincipalType
    galleryName: gallery.outputs.name
    managedIdentityName: idName
    imageDefinitionName: imageDefinitionName
    imageTemplateName: imageTemplateName
    templateIdentityId: gallery.outputs.templateIdentityId
    guidId: guidId
  }
}

output devcetnerName string = devcenter.outputs.devcenterName
output projectName string = devcenter.outputs.projectName
output networkConnectionName string = devcenter.outputs.networkConnectionName
output vnetName string = empty(existingSubnetId) ? vnet.outputs.vnetName : ''
output subnetName string = empty(existingSubnetId) ? vnet.outputs.subnetName : ''
output customizedImageDevboxDefinitions string = devcenter.outputs.customizedImageDevboxDefinitions
output customizedImagePools array = devcenter.outputs.customizedImagePools
