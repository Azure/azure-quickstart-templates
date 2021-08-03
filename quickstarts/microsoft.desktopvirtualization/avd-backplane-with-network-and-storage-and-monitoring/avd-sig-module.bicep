param sigName string
param sigLocation string
param imagePublisher string
param imageDefinitionName string
param imageOffer string
param imageSKU string
param uamiName string
param roleNameGalleryImage string

//Create Shared Image Gallery
resource avdsig 'Microsoft.Compute/galleries@2020-09-30' = {
  name: sigName
  location: sigLocation
}

// Create User-Assigned Managed Identity

resource managedidentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: uamiName
  location: resourceGroup().location
}

//Create Role Definition for Image Builder to map to SIG Resource Group
resource gallerydef 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' = {
  name: guid(roleNameGalleryImage)
  properties: {
    roleName: roleNameGalleryImage
    description: 'Custom role for SIG and AIB'
    permissions: [
      {
        actions: [
          'Microsoft.Compute/galleries/read'
          'Microsoft.Compute/galleries/images/read'
          'Microsoft.Compute/galleries/images/versions/read'
          'Microsoft.Compute/galleries/images/versions/write'
          'Microsoft.Compute/images/write'
          'Microsoft.Compute/images/read'
          'Microsoft.Compute/images/delete'
        ]
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
  dependsOn: [
    managedidentity
  ]
}

output sigid string = gallerydef.properties.roleName

// Map Standard SIG Custom Role Assignment to Managed Identity
resource galleryassignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, gallerydef.id, managedidentity.id)
  properties: {
    roleDefinitionId: gallerydef.id
    principalId: managedidentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Create SIG Image Definition
resource avdid 'Microsoft.Compute/galleries/images@2019-07-01' = {
  name: '${avdsig.name}/${imageDefinitionName}'
  location: sigLocation
  properties: {
    osType: 'Windows'
    osState: 'Generalized'
    identifier: {
      publisher: imagePublisher
      offer: imageOffer
      sku: imageSKU
    }
    recommended: {
      vCPUs: {
        min: 2
        max: 32
      }
      memory: {
        min: 4
        max: 64
      }
    }
    hyperVGeneration: 'V2'
  }
  tags: {}
}

output avdidoutput string = avdid.id
