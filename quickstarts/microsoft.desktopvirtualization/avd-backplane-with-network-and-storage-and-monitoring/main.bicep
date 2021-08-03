targetScope = 'subscription'

//Define AVD deployment parameters
param resourceGroupPrefrix string = 'BICEP-AVD-RG-'
param hostpoolName string = 'myBicepHostpool'
param hostpoolFriendlyName string = 'My Bicep deployed Hostpool'
param appgroupName string = 'myBicepAppGroup'
param appgroupNameFriendlyName string = 'My Bicep deployed Appgroup'
param workspaceName string = 'myBicepWorkspace'
param workspaceNameFriendlyName string = 'My Bicep deployed Workspace'
param preferredAppGroupType string = 'Desktop'
param avdbackplanelocation string = 'eastus'
param hostPoolType string = 'pooled'
param loadBalancerType string = 'BreadthFirst'
param logAnalyticsWorkspaceName string = 'BicepLAWorkspace'
param logAnalyticslocation string = 'westeurope'

//Define Networking deployment parameters
param vnetName string = 'bicep-vnet'
param vnetaddressPrefix string = '10.0.0.0/15'
param subnetPrefix string = '10.0.1.0/24'
param vnetLocation string = 'westeurope'
param subnetName string = 'bicep-subnet'

//Define Azure Files deployment parameters
param storageaccountlocation string = 'westeurope'
param storageaccountName string = 'bicepsa${uniqueString(storageaccountlocation)}' //Make unique before running
param storageaccountkind string = 'FileStorage'
param storgeaccountglobalRedundancy string = 'Premium_LRS'
param fileshareFolderName string = 'profilecontainers'

//Define Shared Image Gallery and Azure Image Parameters
param sigName string = 'BicepavdSIG'
param imageDefinitionName string = 'BicepAIBavdImage'
param imagePublisher string = 'MicrosoftWindowsDesktop'
param imageOffer string = 'windows-10'
param imageSKU string = '20h2-ent'
param uamiName string = '${'AIBUser'}${utcNow()}'

//Define Azure Image Builder Parameters
//Set below to true to start the Image Definition build using AIB once deployment completes
param InvokeRunImageBuildThroughDeploymentScript bool = false

//Create Resource Groups
resource rgavd 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${resourceGroupPrefrix}BACKPLANE'
  location: 'westeurope'
}
resource rgnetw 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${resourceGroupPrefrix}NETWORK'
  location: 'westeurope'
}
resource rgfs 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${resourceGroupPrefrix}FILESERVICES'
  location: 'westeurope'
}
resource rdmon 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${resourceGroupPrefrix}MONITOR'
  location: 'westeurope'
}
resource rgsig 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${resourceGroupPrefrix}SIG'
  location: 'westeurope'
}

//Create avd backplane objects and configure Log Analytics Diagnostics Settings
module avdbackplane './avd-backplane-module.bicep' = {
  name: 'avdbackplane'
  scope: rgavd
  params: {
    hostpoolName: hostpoolName
    hostpoolFriendlyName: hostpoolFriendlyName
    appgroupName: appgroupName
    appgroupNameFriendlyName: appgroupNameFriendlyName
    workspaceName: workspaceName
    workspaceNameFriendlyName: workspaceNameFriendlyName
    preferredAppGroupType: preferredAppGroupType
    applicationgrouptype: preferredAppGroupType
    avdbackplanelocation: avdbackplanelocation
    hostPoolType: hostPoolType
    loadBalancerType: loadBalancerType
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    logAnalyticslocation: logAnalyticslocation
    logAnalyticsResourceGroup: rdmon.name
    avdBackplaneResourceGroup: rgavd.name
  }
}

//Create avd Netwerk and Subnet
module avdnetwork './avd-network-module.bicep' = {
  name: 'avdnetwork'
  scope: rgnetw
  params: {
    vnetName: vnetName
    vnetaddressPrefix: vnetaddressPrefix
    subnetPrefix: subnetPrefix
    vnetLocation: vnetLocation
    subnetName: subnetName
  }
}

//Create avd Azure File Services and FileShare`
module avdFileServices './avd-fileservices-module.bicep' = {
  name: 'avdFileServices'
  scope: rgfs
  params: {
    storageaccountlocation: storageaccountlocation
    storageaccountName: storageaccountName
    storageaccountkind: storageaccountkind
    storgeaccountglobalRedundancy: storgeaccountglobalRedundancy
    fileshareFolderName: fileshareFolderName
  }
}

//Create Private Endpoint for file storage
module pep './avd-fileservices-privateendpoint-module.bicep' = {
  name: 'privateEndpoint'
  scope: rgnetw
  params: {
    location: vnetLocation
    privateEndpointName: 'pep-sto'
    storageAccountId: avdFileServices.outputs.storageAccountId
    vnetId: avdnetwork.outputs.vnetId
    subnetId: avdnetwork.outputs.subnetId
  }
}

//Create avd Shared Image Gallery and Image Definition
module avdsig './avd-sig-module.bicep' = {
  name: 'avdsig'
  scope: rgsig
  params: {
    sigName: sigName
    sigLocation: rgsig.location
    imagePublisher: imagePublisher
    imageDefinitionName: imageDefinitionName
    imageOffer: imageOffer
    imageSKU: imageSKU
    uamiName: uamiName
    roleNameGalleryImage: '${'BicepSIGRole'}'
  }
}

//Create AIB Image and optionally build and add version to SIG Definition
module avdaib './avd-image-builder-module.bicep' = {
  name: 'avdimagebuilder${avdsig.name}'
  scope: rgsig
  params: {
    siglocation: rgsig.location
    uamiName: uamiName
    imagePublisher: imagePublisher
    imageOffer: imageOffer
    imageSKU: imageSKU
    galleryImageId: avdsig.outputs.avdidoutput
    InvokeRunImageBuildThroughDeploymentScript: InvokeRunImageBuildThroughDeploymentScript
  }
}
