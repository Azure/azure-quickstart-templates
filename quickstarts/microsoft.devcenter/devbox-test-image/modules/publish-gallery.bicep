param galleryName string
param imageName string
param location string = resourceGroup().location

// Dev Box image requirements are described at https://learn.microsoft.com/en-us/azure/dev-box/how-to-configure-azure-compute-gallery#image-version-requirements
var imageDefinitionProperties = {
  hyperVGeneration: 'V2'
  architecture: 'x64'
  features: [
    {
      name: 'SecurityType'
      value: 'TrustedLaunch'
    }
    {
      name: 'IsHibernateSupported'
      value: 'true'
    }
  ]
  osType: 'Windows'
  osState: 'Generalized'
  identifier: {
    publisher: 'AzureQuickstarts'
    offer: 'DevBox'
    sku: imageName
  }
}

resource publishGallery 'Microsoft.Compute/galleries@2022-01-03' existing = if (!empty(galleryName)) {
  name: galleryName

  resource newImageDef 'images' = {
    name: imageName
    location: location
    properties: imageDefinitionProperties
  }
}

output computeGalleryId string = empty(galleryName) ? '' : publishGallery::newImageDef.id
