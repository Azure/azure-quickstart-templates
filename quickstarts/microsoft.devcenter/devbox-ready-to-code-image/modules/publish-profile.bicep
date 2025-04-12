param location string
param imageName string
param isBaseImage bool
param galleryName string
param galleryResourceGroup string
param gallerySubscriptionId string
param imageGalleries array
param targetRegions array
param imagePublishingProfile object

// Explicitly supplying imageGalleries param overrides the default gallery info
var imageGalleriesRaw = !empty(imageGalleries)
  ? imageGalleries
  : [
      {
        galleryName: galleryName
        gallerySubscriptionId: gallerySubscriptionId
        galleryResourceGroup: galleryResourceGroup
      }
    ]

// Fill in missing gallery properties with defaults
var imageGalleriesFinal = [
  for item in imageGalleriesRaw: {
    galleryName: item.galleryName
    gallerySubscriptionId: item.?gallerySubscriptionId ?? gallerySubscriptionId
    galleryResourceGroup: item.?galleryResourceGroup ?? galleryResourceGroup
  }
]

module publishGalleries 'publish-galleries.bicep' = {
  name: 'publishGalleries-${uniqueString(deployment().name, resourceGroup().name)}'
  params: {
    imageGalleries: imageGalleriesFinal
    imageName: imageName
    isBaseImage: isBaseImage
    location: location
  }
}

// Generate the list of ids for Compute Gallery VM Image Definitions in the case when publishing to at least one gallery is requested
var galleryIdsFlattened = map(publishGalleries.outputs.galleryIds, obj => obj.Id)
var computeGalleries = map(filter(galleryIdsFlattened, id => !empty(id)), id => { computeGalleryId: id })

// Create the default publishing profile
var defaultImagePublishingProfile = union(
  {
    targetRegions: empty(targetRegions)
      ? [{ name: location, replicas: 1 }]
      : map(targetRegions, targetRegion => { name: targetRegion, replicas: 1 })
  },
  !empty(computeGalleries) ? { computeGalleries: computeGalleries } : {}
)

// Allow top level properties in the explicitly provided profile to override those in the default one
output publishingProfile object = union(defaultImagePublishingProfile, imagePublishingProfile)
