param customLocationName string
param location string
param imageName string
@allowed([ 'Windows' ])
param osType string = 'Windows'
@allowed([ 
  'microsoftwindowsserver:windowsserver:2022-datacenter-azure-edition-core'
  'microsoftwindowsserver:windowsserver:2022-datacenter-azure-edition'
  'microsoftwindowsserver:windowsserver:2022-datacenter-azure-edition-hotpatch'
  'microsoftwindowsdesktop:office-365:win11-21h2-avd-m365'
  'microsoftwindowsdesktop:office-365:win10-21h2-avd-m365-g2'
  'microsoftwindowsdesktop:windows-10:win10-21h2-avd-g2'
  'microsoftwindowsdesktop:windows-11:win11-21h2-avd'
  'microsoftwindowsdesktop:windows-11:win11-22h2-avd' ])
param imageURN string
param skuVersion string = 'latest'
@allowed([ 'v2' ])
param hyperVGeneration string = 'v2'

// as of 9/21/23, these are the only marketplace images supported on Azure Stack HCI

// Windows Server 2022 Datacenter: Azure Editition Core - Gen2:                                           microsoftwindowsserver:windowsserver:2022-datacenter-azure-edition-core
// Windows Server 2022 Datacenter: Azure Editition - Gen2:                                                microsoftwindowsserver:windowsserver:2022-datacenter-azure-edition
// Windows Server 2022 Datacenter: Azure Editition Hotpatch - Gen2:                                       microsoftwindowsserver:windowsserver:2022-datacenter-azure-edition-hotpatch
// Windows 11 Enterprise multi-session + Microsoft 365 Apps, version 21H2 - Gen2:                         microsoftwindowsdesktop:office-365:win11-21h2-avd-m365
// Windows 10 Enterprise multi-session, version 21H2 + Microsoft 365 Apps - Gen2:                         microsoftwindowsdesktop:office-365:win10-21h2-avd-m365-g2
// Windows 10 Enterprise multi-session, version 21H2 - Gen2:                                              microsoftwindowsdesktop:windows-10:win10-21h2-avd-g2
// Windows 11 Enterprise multi-session, version 21h2 - Gen2:                                              microsoftwindowsdesktop:windows-11:win11-21h2-avd
// Windows 11 Enterprise multi-session, version 22h2 - Gen2:                                              microsoftwindowsdesktop:windows-11:win11-22h2-avd

var customLocationId = resourceId('Microsoft.ExtendedLocation/customLocations', customLocationName)
var publisherId = split(imageURN, ':')[0]
var offerId = split(imageURN, ':')[1]
var planId = split(imageURN, ':')[2]

resource image 'microsoft.azurestackhci/marketplacegalleryimages@2021-09-01-preview' = {
  extendedLocation: {
    name: customLocationId
    type: 'CustomLocation'
  }
  location: location
  name: imageName
  properties: {
    osType: osType
    resourceName: imageName
    hyperVGeneration: hyperVGeneration
    identifier: {
      publisher: publisherId
      offer: offerId
      sku: planId
    }
    version: {
      name: skuVersion
    }
  }
  tags: {}
}
