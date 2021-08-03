@description('The base URI where artifacts required by this template are located.')
param artifactsLocation string = 'https://raw.githubusercontent.com/Azure/RDS-Templates/master/ARM-wvd-templates/DSC/Configuration.zip'

@description('The name of the Hostpool to be created.')
param hostpoolName string

@description('The friendly name of the Hostpool to be created.')
param hostpoolFriendlyName string = ''

@description('The description of the Hostpool to be created.')
param hostpoolDescription string = ''

@description('The location where the resources will be deployed.')
param location string

@description('The name of the workspace to be attach to new Applicaiton Group.')
param workSpaceName string = ''

@description('The location of the workspace.')
param workspaceLocation string = ''

@description('The workspace resource group Name.')
param workspaceResourceGroup string = ''

@description('The existing app groups references of the workspace selected.')
param allApplicationGroupReferences string = ''

@description('Whether to add applicationGroup to workspace.')
param addToWorkspace bool

@description('A username in the domain that has privileges to join the session hosts to the domain. For example, \'vmjoiner@contoso.com\'.')
param administratorAccountUsername string = ''

@description('The password that corresponds to the existing domain username.')
@secure()
param administratorAccountPassword string = ''

@description('A username to be used as the virtual machine administrator account. The vmAdministratorAccountUsername and  vmAdministratorAccountPassword parameters must both be provided. Otherwise, domain administrator credentials provided by administratorAccountUsername and administratorAccountPassword will be used.')
param vmAdministratorAccountUsername string = ''

@description('The password associated with the virtual machine administrator account. The vmAdministratorAccountUsername and  vmAdministratorAccountPassword parameters must both be provided. Otherwise, domain administrator credentials provided by administratorAccountUsername and administratorAccountPassword will be used.')
@secure()
param vmAdministratorAccountPassword string = ''

@allowed([
  'None'
  'AvailabilitySet'
  'AvailabilityZone'
])
@description('Select the availability options for the VMs.')
param availabilityOption string = 'None'

@description('The name of avaiability set to be used when create the VMs.')
param availabilitySetName string = ''

@description('Whether to create a new availability set for the VMs.')
param createAvailabilitySet bool = false

@allowed([
  1
  2
  3
  4
  5
  6
  7
  8
  9
  10
  11
  12
  13
  14
  15
  16
  17
  18
  19
  20
])
@description('The platform update domain count of avaiability set to be created.')
param availabilitySetUpdateDomainCount int = 5

@allowed([
  1
  2
  3
])
@description('The platform fault domain count of avaiability set to be created.')
param availabilitySetFaultDomainCount int = 2

@allowed([
  1
  2
  3
])
@description('The number of availability zone to be used when create the VMs.')
param availabilityZone int = 1

@description('The resource group of the session host VMs.')
param vmResourceGroup string = ''

@description('The location of the session host VMs.')
param vmLocation string = ''

@description('The size of the session host VMs.')
param vmSize string = ''

@description('Number of session hosts that will be created and added to the hostpool.')
param vmNumberOfInstances int = 0

@description('This prefix will be used in combination with the VM number to create the VM name. If using \'rdsh\' as the prefix, VMs would be named \'rdsh-0\', \'rdsh-1\', etc. You should use a unique prefix to reduce name collisions in Active Directory.')
param vmNamePrefix string = ''

@allowed([
  'CustomVHD'
  'CustomImage'
  'Gallery'
])
@description('Select the image source for the session host vms. VMs from a Gallery image will be created with Managed Disks.')
param vmImageType string = 'Gallery'

@description('(Required when vmImageType = Gallery) Gallery image Offer.')
param vmGalleryImageOffer string = ''

@description('(Required when vmImageType = Gallery) Gallery image Publisher.')
param vmGalleryImagePublisher string = ''

@description('(Required when vmImageType = Gallery) Gallery image SKU.')
param vmGalleryImageSKU string = ''

@description('(Required when vmImageType = CustomVHD) URI of the sysprepped image vhd file to be used to create the session host VMs. For example, https://rdsstorage.blob.core.windows.net/vhds/sessionhostimage.vhd')
param vmImageVhdUri string = ''

@description('(Required when vmImageType = CustomImage) Resource ID of the image')
param vmCustomImageSourceId string = ''

@allowed([
  'Premium_LRS'
  'StandardSSD_LRS'
  'Standard_LRS'
])
@description('The VM disk type for the VM: HDD or SSD.')
param vmDiskType string = 'StandardSSD_LRS'

@description('True indicating you would like to use managed disks or false indicating you would like to use unmanaged disks.')
param vmUseManagedDisks bool = true

@description('(Required when vmUseManagedDisks = False) The resource group containing the storage account of the image vhd file.')
param storageAccountResourceGroupName string = ''

@description('The name of the virtual network the VMs will be connected to.')
param existingVnetName string = ''

@description('The subnet the VMs will be placed in.')
param existingSubnetName string = ''

@description('The resource group containing the existing virtual network.')
param virtualNetworkResourceGroupName string = ''

@description('Whether to create a new network security group or use an existing one')
param createNetworkSecurityGroup bool = false

@description('The resource id of an existing network security group')
param networkSecurityGroupId string = ''

@description('The rules to be given to the new network security group')
param networkSecurityGroupRules array = []

@allowed([
  'Personal'
  'Pooled'
])
@description('Set this parameter to Personal if you would like to enable Persistent Desktop experience. Defaults to false.')
param hostpoolType string

@allowed([
  'Automatic'
  'Direct'
  ''
])
@description('Set the type of assignment for a Personal hostpool type')
param personalDesktopAssignmentType string = ''

@description('Maximum number of sessions.')
param maxSessionLimit int = 99999

@allowed([
  'BreadthFirst'
  'DepthFirst'
  'Persistent'
])
@description('Type of load balancer algorithm.')
param loadBalancerType string = 'BreadthFirst'

@description('Hostpool rdp properties')
param customRdpProperty string = ''

@description('The necessary information for adding more VMs to this Hostpool')
param vmTemplate string = ''

@description('Hostpool token expiration time')
param tokenExpirationTime string

@description('The tags to be assigned to the hostpool')
param hostpoolTags object = {}

@description('The tags to be assigned to the application group')
param applicationGroupTags object = {}

@description('The tags to be assigned to the availability set')
param availabilitySetTags object = {}

@description('The tags to be assigned to the network interfaces')
param networkInterfaceTags object = {}

@description('The tags to be assigned to the network security groups')
param networkSecurityGroupTags object = {}

@description('The tags to be assigned to the virtual machines')
param virtualMachineTags object = {}

@description('The tags to be assigned to the images')
param imageTags object = {}

@description('WVD api version')
param apiVersion string = '2019-12-10-preview'

@description('GUID for the deployment')
param deploymentId string = ''

@description('Whether to use validation enviroment.')
param validationEnvironment bool = false

@description('Preferred App Group type to display')
param preferredAppGroupType string = 'Desktop'

@description('OUPath for the domain join')
param ouPath string = ''

@description('Domain to join')
param domain string = ''

@description('IMPORTANT: Please don\'t use this parameter as AAD Join is not supported yet. True if AAD Join, false if AD join')
param aadJoin bool = false

@description('IMPORTANT: Please don\'t use this parameter as intune enrollment is not supported yet. True if intune enrollment is selected.  False otherwise')
param intune bool = false

var createVMs = (vmNumberOfInstances > 0)
var rdshManagedDisks = ((vmImageType == 'CustomVHD') ? vmUseManagedDisks : bool('true'))
var rdshPrefix = '${vmNamePrefix}-'
var avSetSKU = (rdshManagedDisks ? 'Aligned' : 'Classic')
var vhds = 'vhds/${rdshPrefix}'
var subnet_id = resourceId(virtualNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', existingVnetName, existingSubnetName)
var hostpoolName_var = replace(hostpoolName, '"', '')
var rdshVmNamesOutput = [for j in range(0, (createVMs ? vmNumberOfInstances : 1)): {
  name: '${rdshPrefix}${j}'
}]
var appGroupName_var = '${hostpoolName_var}-DAG'
var appGroupResourceId = [
  resourceId('Microsoft.DesktopVirtualization/applicationgroups/', appGroupName_var)
]
var workspaceResourceGroup_var = (empty(workspaceResourceGroup) ? resourceGroup().name : workspaceResourceGroup)
var applicationGroupReferencesArr = (('' == allApplicationGroupReferences) ? appGroupResourceId : concat(split(allApplicationGroupReferences, ','), appGroupResourceId))
var hostpoolRequiredProps = {
  friendlyName: hostpoolFriendlyName
  description: hostpoolDescription
  hostpoolType: hostpoolType
  personalDesktopAssignmentType: personalDesktopAssignmentType
  maxSessionLimit: maxSessionLimit
  loadBalancerType: loadBalancerType
  validationEnvironment: validationEnvironment
  preferredAppGroupType: preferredAppGroupType
  ring: null
  registrationInfo: {
    expirationTime: tokenExpirationTime
    token: null
    registrationTokenOperation: 'Update'
  }
  vmTemplate: vmTemplate
}
var hostpoolOptionalProps = {
  customRdpProperty: customRdpProperty
}

resource hostpool 'Microsoft.DesktopVirtualization/hostpools@2019-12-10-preview' = {
  name: hostpoolName
  location: location
  tags: hostpoolTags
  properties: (empty(customRdpProperty) ? hostpoolRequiredProps : union(hostpoolOptionalProps, hostpoolRequiredProps))
}

resource appGroupName 'Microsoft.DesktopVirtualization/applicationgroups@2019-12-10-preview' = {
  name: appGroupName_var
  location: location
  tags: applicationGroupTags
  properties: {
    hostPoolArmPath: hostpool.id
    friendlyName: 'Default Desktop'
    description: 'Desktop Application Group created through the Hostpool Wizard'
    applicationGroupType: 'Desktop'
  }
}

module workspace './modules/workspace.bicep' = if (addToWorkspace) {
  name: 'Workspace-linkedTemplate-${deploymentId}'
  scope: resourceGroup(workspaceResourceGroup_var)
  params: {
    //apiVersion: apiVersion
    workSpaceName: workSpaceName
    workspaceLocation: workspaceLocation
    applicationGroupReferencesArr: applicationGroupReferencesArr
  }
}

module AVSet './modules/AVSet.bicep' = if (createVMs && (availabilityOption == 'AvailabilitySet') && createAvailabilitySet) {
  name: 'AVSet-deployment' //'AVSet-linkedTemplate-${deploymentId}'
  scope: resourceGroup(vmResourceGroup)
  params: {
    availabilitySetName: availabilitySetName
    vmLocation: vmLocation
    availabilitySetTags: availabilitySetTags
    availabilitySetUpdateDomainCount: availabilitySetUpdateDomainCount
    availabilitySetFaultDomainCount: availabilitySetFaultDomainCount
    avSetSKU: avSetSKU
  }
  dependsOn: [
    appGroupName
  ]
}

// Deploy vmImageType = CustomVHD, managed disks
module vmCreation_customVHD_managedDisks './modules/managedDisks-customvhdvm.bicep' = if ((createVMs) && (vmImageType == 'CustomVHD') && (vmUseManagedDisks)) {
  name: 'vmCreation-linkedTemplate-${deploymentId}-managedDisks-customvhdvm'
  scope: resourceGroup(vmResourceGroup)
  params: {
    artifactsLocation: artifactsLocation
    availabilityOption: availabilityOption
    availabilitySetName: availabilitySetName
    availabilityZone: availabilityZone
    vmImageVhdUri: vmImageVhdUri
    storageAccountResourceGroupName: storageAccountResourceGroupName
    vmGalleryImageOffer: vmGalleryImageOffer
    vmGalleryImagePublisher: vmGalleryImagePublisher
    vmGalleryImageSKU: vmGalleryImageSKU
    rdshPrefix: rdshPrefix
    rdshNumberOfInstances: vmNumberOfInstances
    rdshVMDiskType: vmDiskType
    rdshVmSize: vmSize
    enableAcceleratedNetworking: false
    vmAdministratorAccountUsername: vmAdministratorAccountUsername
    vmAdministratorAccountPassword: vmAdministratorAccountPassword
    administratorAccountUsername: administratorAccountUsername
    administratorAccountPassword: administratorAccountPassword
    subnet_id: subnet_id
    vhds: vhds
    rdshImageSourceId: vmCustomImageSourceId
    location: vmLocation
    createNetworkSecurityGroup: createNetworkSecurityGroup
    networkSecurityGroupId: networkSecurityGroupId
    networkSecurityGroupRules: networkSecurityGroupRules
    networkInterfaceTags: networkInterfaceTags
    networkSecurityGroupTags: networkSecurityGroupTags
    virtualMachineTags: virtualMachineTags
    imageTags: imageTags
    hostpoolToken: reference(hostpoolName).registrationInfo.token
    hostpoolName: hostpoolName
    domain: domain
    ouPath: ouPath
    aadJoin: aadJoin
    intune: intune
    guidValue: deploymentId
  }
  dependsOn: [
    AVSet
  ]
}

// Deploy vmImageType = CustomVHD, unmanaged disks
module vmCreation_customVHD_unmanagedDisks './modules/unmanagedDisks-customvhdvm.bicep' = if ((createVMs) && (vmImageType == 'CustomVHD') && (!vmUseManagedDisks)) {
  name: 'vmCreation-linkedTemplate-${deploymentId}-unmanagedDisks-customvhdvm'
  scope: resourceGroup(vmResourceGroup)
  params: {
    artifactsLocation: artifactsLocation
    availabilityOption: availabilityOption
    availabilitySetName: availabilitySetName
    availabilityZone: availabilityZone
    vmImageVhdUri: vmImageVhdUri
    storageAccountResourceGroupName: storageAccountResourceGroupName
    vmGalleryImageOffer: vmGalleryImageOffer
    vmGalleryImagePublisher: vmGalleryImagePublisher
    vmGalleryImageSKU: vmGalleryImageSKU
    rdshPrefix: rdshPrefix
    rdshNumberOfInstances: vmNumberOfInstances
    rdshVMDiskType: vmDiskType
    rdshVmSize: vmSize
    enableAcceleratedNetworking: false
    vmAdministratorAccountUsername: vmAdministratorAccountUsername
    vmAdministratorAccountPassword: vmAdministratorAccountPassword
    administratorAccountUsername: administratorAccountUsername
    administratorAccountPassword: administratorAccountPassword
    subnet_id: subnet_id
    vhds: vhds
    rdshImageSourceId: vmCustomImageSourceId
    location: vmLocation
    createNetworkSecurityGroup: createNetworkSecurityGroup
    networkSecurityGroupId: networkSecurityGroupId
    networkSecurityGroupRules: networkSecurityGroupRules
    networkInterfaceTags: networkInterfaceTags
    networkSecurityGroupTags: networkSecurityGroupTags
    virtualMachineTags: virtualMachineTags
    imageTags: imageTags
    hostpoolToken: reference(hostpoolName).registrationInfo.token
    hostpoolName: hostpoolName
    domain: domain
    ouPath: ouPath
    aadJoin: aadJoin
    intune: intune
    guidValue: deploymentId
  }
  dependsOn: [
    AVSet
  ]
}

// Deploy vmImageType = CustomImage
module vmCreation_customeImage './modules/managedDisks-customimagevm.bicep' = if ((createVMs) && (vmImageType == 'CustomImage')) {
  name: 'vmCreation-linkedTemplate-${deploymentId}-managedDisks-customimagevm'
  scope: resourceGroup(vmResourceGroup)
  params: {
    artifactsLocation: artifactsLocation
    availabilityOption: availabilityOption
    availabilitySetName: availabilitySetName
    availabilityZone: availabilityZone
    vmImageVhdUri: vmImageVhdUri
    storageAccountResourceGroupName: storageAccountResourceGroupName
    vmGalleryImageOffer: vmGalleryImageOffer
    vmGalleryImagePublisher: vmGalleryImagePublisher
    vmGalleryImageSKU: vmGalleryImageSKU
    rdshPrefix: rdshPrefix
    rdshNumberOfInstances: vmNumberOfInstances
    rdshVMDiskType: vmDiskType
    rdshVmSize: vmSize
    enableAcceleratedNetworking: false
    vmAdministratorAccountUsername: vmAdministratorAccountUsername
    vmAdministratorAccountPassword: vmAdministratorAccountPassword
    administratorAccountUsername: administratorAccountUsername
    administratorAccountPassword: administratorAccountPassword
    subnet_id: subnet_id
    vhds: vhds
    rdshImageSourceId: vmCustomImageSourceId
    location: vmLocation
    createNetworkSecurityGroup: createNetworkSecurityGroup
    networkSecurityGroupId: networkSecurityGroupId
    networkSecurityGroupRules: networkSecurityGroupRules
    networkInterfaceTags: networkInterfaceTags
    networkSecurityGroupTags: networkSecurityGroupTags
    virtualMachineTags: virtualMachineTags
    imageTags: imageTags
    hostpoolToken: reference(hostpoolName).registrationInfo.token
    hostpoolName: hostpoolName
    domain: domain
    ouPath: ouPath
    aadJoin: aadJoin
    intune: intune
    guidValue: deploymentId
  }
  dependsOn: [
    AVSet
  ]
}

// Deploy vmImageType = CustomVHD, managed disks
module vmCreation_Gallery './modules/managedDisks-galleryvm.bicep' = if ((createVMs) && (vmImageType == 'Gallery') && (vmUseManagedDisks)) {
  name: 'vmCreation-linkedTemplate-${deploymentId}-managedDisks-galleryvm'
  scope: resourceGroup(vmResourceGroup)
  params: {
    artifactsLocation: artifactsLocation
    availabilityOption: availabilityOption
    availabilitySetName: availabilitySetName
    availabilityZone: availabilityZone
    vmImageVhdUri: vmImageVhdUri
    storageAccountResourceGroupName: storageAccountResourceGroupName
    vmGalleryImageOffer: vmGalleryImageOffer
    vmGalleryImagePublisher: vmGalleryImagePublisher
    vmGalleryImageSKU: vmGalleryImageSKU
    rdshPrefix: rdshPrefix
    rdshNumberOfInstances: vmNumberOfInstances
    rdshVMDiskType: vmDiskType
    rdshVmSize: vmSize
    enableAcceleratedNetworking: false
    vmAdministratorAccountUsername: vmAdministratorAccountUsername
    vmAdministratorAccountPassword: vmAdministratorAccountPassword
    administratorAccountUsername: administratorAccountUsername
    administratorAccountPassword: administratorAccountPassword
    subnet_id: subnet_id
    vhds: vhds
    rdshImageSourceId: vmCustomImageSourceId
    location: vmLocation
    createNetworkSecurityGroup: createNetworkSecurityGroup
    networkSecurityGroupId: networkSecurityGroupId
    networkSecurityGroupRules: networkSecurityGroupRules
    networkInterfaceTags: networkInterfaceTags
    networkSecurityGroupTags: networkSecurityGroupTags
    virtualMachineTags: virtualMachineTags
    imageTags: imageTags
    hostpoolToken: reference(hostpoolName).registrationInfo.token
    hostpoolName: hostpoolName
    domain: domain
    ouPath: ouPath
    aadJoin: aadJoin
    intune: intune
    guidValue: deploymentId
  }
  dependsOn: [
    AVSet
  ]
}

output rdshVmNamesObject array = rdshVmNamesOutput
