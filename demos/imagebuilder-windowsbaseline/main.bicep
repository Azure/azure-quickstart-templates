@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated. Use the defaultValue if the staging location is not secured.')
@secure()
param _artifactsLocationSasToken string = ''

@description('The Azure region where resources in the template should be deployed.')
param location string = resourceGroup().location

@description('The name of the customizer script which will be executed during image build.')
param customizerScriptName string = 'scripts/runScript.ps1'

@description('Name of the user-assigned managed identity used by Azure Image Builder template, and for triggering the Azure Image Builder build at the end of the deployment')
param templateIdentityName string = substring('ImageGallery_${guid(resourceGroup().id)}', 0, 21)

@description('Permissions to allow for the user-assigned managed identity.')
param templateIdentityRoleDefinitionName string = guid(resourceGroup().id)

@description('Name of the new Azure Image Gallery resource.')
param imageGalleryName string = substring('ImageGallery_${guid(resourceGroup().id)}', 0, 21)

@description('Detailed image information to set for the custom image produced by the Azure Image Builder build.')
param imageDefinitionProperties object = {
  name: 'Win2019_AzureWindowsBaseline_Definition'
  publisher: 'AzureWindowsBaseline'
  offer: 'WindowsServer'
  sku: '2019-Datacenter'
}

@description('Name of the template to create in Azure Image Builder.')
param imageTemplateName string = 'Win2019_AzureWindowsBaseline_Template'

@description('Name of the custom iamge to create and distribute using Azure Image Builder.')
param runOutputName string = 'Win2019_AzureWindowsBaseline_CustomImage'

@description('List the regions in Azure where you would like to replicate the custom image after it is created.')
param replicationRegions array = [
  'centralus'
  'eastus2'
  'westus2'
  'northeurope'
  'westeurope'
]

@description('A unique string generated for each deployment, to make sure the script is always run.')
param forceUpdateTag string = newGuid()

var customizerScriptUri = uri(_artifactsLocation, '${customizerScriptName}${_artifactsLocationSasToken}')
var templateIdentityRoleAssignmentName = guid(templateIdentity.id, resourceGroup().id, templateIdentityRoleDefinition.id)

resource templateIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: templateIdentityName
  location: location
}

resource templateIdentityRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-07-01' = {
  name: templateIdentityRoleDefinitionName
  properties: {
    roleName: templateIdentityRoleDefinitionName
    description: 'Used for AIB template and ARM deployment script that runs AIB build'
    type: 'customRole'
    isCustom: true
    permissions: [
      {
        actions: [
          'Microsoft.Compute/galleries/read'
          'Microsoft.Compute/galleries/images/read'
          'Microsoft.Compute/galleries/images/versions/read'
          'Microsoft.Compute/galleries/images/versions/write'
          'Microsoft.Compute/images/read'
          'Microsoft.Compute/images/write'
          'Microsoft.Compute/images/delete'
          'Microsoft.Storage/storageAccounts/blobServices/containers/read'
          'Microsoft.Storage/storageAccounts/blobServices/containers/write'
          'Microsoft.ContainerInstance/containerGroups/read'
          'Microsoft.ContainerInstance/containerGroups/write'
          'Microsoft.ContainerInstance/containerGroups/start/action'
          'Microsoft.Resources/deployments/read'
          'Microsoft.Resources/deploymentScripts/read'
          'Microsoft.Resources/deploymentScripts/write'
          'Microsoft.VirtualMachineImages/imageTemplates/run/action'
        ]
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
}

resource templateRoleAssignment 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: templateIdentityRoleAssignmentName
  properties: {
    roleDefinitionId: templateIdentityRoleDefinition.id
    principalId: templateIdentity.properties.principalId
    scope: resourceGroup().id
    principalType: 'ServicePrincipal'
  }
}

resource imageGallery 'Microsoft.Compute/galleries@2020-09-30' = {
  name: imageGalleryName
  location: location
  properties: {}
}

resource imageDefinition 'Microsoft.Compute/galleries/images@2020-09-30' = {
  parent: imageGallery
  name: imageDefinitionProperties.name
  location: location
  properties: {
    osType: 'Windows'
    osState: 'Generalized'
    identifier: {
      publisher: imageDefinitionProperties.publisher
      offer: imageDefinitionProperties.offer
      sku: imageDefinitionProperties.sku
    }
    recommended: {
      vCPUs: {
        min: 2
        max: 8
      }
      memory: {
        min: 16
        max: 48
      }
    }
    hyperVGeneration: 'V1'
  }
}

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2020-02-14' = {
  name: imageTemplateName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${templateIdentity.id}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: 60
    vmProfile: {
      vmSize: 'Standard_D2_v3'
      osDiskSizeGB: 127
    }
    source: {
      type: 'PlatformImage'
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2019-Datacenter'
      version: 'latest'
    }
    customize: [
      {
        type: 'WindowsUpdate'
        searchCriteria: 'IsInstalled=0'
        filters: [
          'exclude:$_.Title -like \'*Preview*\''
          'include:$true'
        ]
        updateLimit: 40
      }
      {
        type: 'PowerShell'
        name: 'AzureWindowsBaseline'
        runElevated: true
        scriptUri: customizerScriptUri
      }
    ]
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: imageDefinition.id
        runOutputName: runOutputName
        replicationRegions: replicationRegions
      }
    ]
  }
}

resource imageTemplate_build 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'Image_template_build'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${templateIdentity.id}': {}
    }
  }
  dependsOn: [
    imageTemplate
    templateRoleAssignment
  ]
  properties: {
    forceUpdateTag: forceUpdateTag
    azPowerShellVersion: '6.2'
    scriptContent: 'Invoke-AzResourceAction -ResourceName "${imageTemplateName}" -ResourceGroupName "${resourceGroup().name}" -ResourceType "Microsoft.VirtualMachineImages/imageTemplates" -ApiVersion "2020-02-14" -Action Run -Force'
    timeout: 'PT1H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}
