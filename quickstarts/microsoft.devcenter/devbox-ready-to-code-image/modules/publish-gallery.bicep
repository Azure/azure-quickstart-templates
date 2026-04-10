param galleryName string
param imageName string
param isBaseImage bool
param location string = resourceGroup().location

// Dev Box image requirements are described at https://learn.microsoft.com/en-us/azure/dev-box/how-to-configure-azure-compute-gallery#image-version-requirements
var imageDefinitionProperties = {
  hyperVGeneration: 'V2'
  architecture: 'x64'
  features: [
    {
      name: 'SecurityType'
      // Dev Box ONLY accepts images with TrustedLaunch secuirty type (1) while AIB cannot produce those yet (2). Work around by using TrustedLaunchSupported for base images.
      // (1) https://learn.microsoft.com/en-us/azure/dev-box/how-to-customize-devbox-azure-image-builder
      // (2) https://learn.microsoft.com/en-us/azure/virtual-machines/image-builder-overview?tabs=azure-powershell#confidential-vm-and-trusted-launch-support
      value: isBaseImage ? 'TrustedLaunchSupported' : 'TrustedLaunch'
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

resource publishGallery 'Microsoft.Compute/galleries@2023-07-03' existing = if (!empty(galleryName)) {
  name: galleryName

  resource newImageDef 'images' = {
    name: imageName
    location: location
    properties: imageDefinitionProperties
  }
}

output computeGalleryId string = empty(galleryName) ? '' : publishGallery::newImageDef.id
