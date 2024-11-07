@description('The name of the image')
param imageName string
@description('Operating system associated with the source image. This can be Windows or Linux.')
param osType string

@description('Publisher of image required if the image is from azure marketplace')
param publisher string = ''
@description('Offer of image required if the image is from azure marketplace')
param offer string = ''
@description('SKU of image required if the image is from azure marketplace')
param sku string = ''
@description('Version of image required if the image is from azure marketplace')
param version string = ''

@description('Path of the image from local share or azure storage account, eg. C:\\ClusterStorage\\UserStorage_01\\ubuntu-01.vhdx')
param imageSourcePath string = ''


param location string = 'eastus'
@description('The name of the custom location to use for the deployment. This name is specified during the deployment of the Azure Stack HCI cluster and can be found on the Azure Stack HCI cluster resource Overview in the Azure portal.')
param customLocationName string

var customLocationId = resourceId('Microsoft.ExtendedLocation/customLocations', customLocationName)

resource marketplaceGalleryImage 'Microsoft.AzureStackHCI/marketplaceGalleryImages@2024-01-01' = if(imageSourcePath == '') {
  name: imageName
  location: location
  extendedLocation: {
    type: 'CustomLocation'
    name: customLocationId
  }
  properties: {
    identifier: {
      publisher: publisher
      offer: offer
      sku: sku
    }
    version: {
      name: version
    }
    osType: osType
  }
}

resource galleryImage 'Microsoft.AzureStackHCI/galleryImages@2024-01-01' = if(imageSourcePath != '') {
  name: imageName
  location: location
  extendedLocation: {
    type: 'CustomLocation'
    name: customLocationId
  }
  properties: {
    hyperVGeneration: 'V2'
    osType: osType
    imagePath: imageSourcePath
  }
}

