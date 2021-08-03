param siglocation string
param roleNameAIBCustom string = '${'BicepAIB'}${utcNow()}'
param uamiName string
param uamiId string = resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', uamiName)
param imageTemplateName string = '${'AVDBicep'}${utcNow()}'
param outputname string = uniqueString(resourceGroup().name)
param galleryImageId string
param imagePublisher string
param imageOffer string
param imageSKU string
param InvokeRunImageBuildThroughDeploymentScript bool
param rgname string = resourceGroup().name

resource managedidentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: uamiName
}

// Create Image Template in SIG Resource Group

resource imageTemplateName_resource 'Microsoft.VirtualMachineImages/imageTemplates@2020-02-14' = {
  name: imageTemplateName
  location: siglocation
  tags: {
    imagebuilderTemplate: 'AzureImageBuilderSIG'
    userIdentity: 'enabled'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedidentity.id}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: 180
    vmProfile: {
      vmSize: 'Standard_D2_v2'
      osDiskSizeGB: 127
    }
    source: {
      type: 'PlatformImage'
      publisher: imagePublisher
      offer: imageOffer
      sku: imageSKU
      version: 'latest'
    }
    /* Uncomment if you wish to run OS Optimize Script, Teams Installer and Windows Updates
    customize: [
      {
        type: 'PowerShell'
        name: 'OptimizeOS'
        runElevated: true
        runAsSystem: true
        scriptUri: 'https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/solutions/14_Building_Images_AVD/1_Optimize_OS_for_AVD.ps1'
      }
      {
        type: 'WindowsRestart'
        restartCheckCommand: 'write-host \'restarting post Optimizations\''
        restartTimeout: '5m'
      }
      {
        type: 'PowerShell'
        name: 'Install Teams'
        runElevated: true
        runAsSystem: true
        scriptUri: 'https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/solutions/14_Building_Images_AVD/2_installTeams.ps1'
      }
      {
        type: 'WindowsRestart'
        restartCheckCommand: 'write-host \'restarting post Teams Install\''
        restartTimeout: '5m'
      }
      {
        type: 'WindowsUpdate'
        searchCriteria: 'IsInstalled=0'
        filters: [
          'exclude:$_.Title -like \'*Preview*\''
          'include:$true'
        ]
        updateLimit: 40
      }
    ]
    */
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: galleryImageId
        runOutputName: outputname
        artifactTags: {
          source: 'avd10'
          baseosimg: 'windows10'
        }
        replicationRegions: []
      }
    ]
  }
}

//Create Role Definition with Image Builder to run Image Build and execute container cli script
resource aibdef 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' = if (InvokeRunImageBuildThroughDeploymentScript) {
  name: guid(roleNameAIBCustom)
  properties: {
    roleName: roleNameAIBCustom
    description: 'Custom role for AIB to invoke build of VM Template from deployment'
    permissions: [
      {
        actions: [
          'Microsoft.VirtualMachineImages/imageTemplates/Run/action'
          'Microsoft.Storage/storageAccounts/*'
          'Microsoft.ContainerInstance/containerGroups/*'
          'Microsoft.Resources/deployments/*'
          'Microsoft.Resources/deploymentScripts/*'
        ]
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
}

// Map AIB Runner Custom Role Assignment to Managed Identity
resource aibrunnerassignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (InvokeRunImageBuildThroughDeploymentScript) {
  name: guid(resourceGroup().id, aibdef.id, managedidentity.id)
  properties: {
    roleDefinitionId: aibdef.id
    principalId: managedidentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Map Managed Identity Operator Role to to Managed Identity - Not required if not running Powershell Deployment Script for AIB
resource miorole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (InvokeRunImageBuildThroughDeploymentScript) {
  name: guid(resourceGroup().id, '/providers/Microsoft.Authorization/roleDefinitions/f1a07417-d97a-45cb-824c-7a7467783830', managedidentity.id)
  properties: {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/f1a07417-d97a-45cb-824c-7a7467783830'
    principalId: managedidentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Run Deployment Script to Start build of Virtual Machine Image using AIB
resource scriptName_BuildVMImage 'Microsoft.Resources/deploymentScripts@2020-10-01' = if (InvokeRunImageBuildThroughDeploymentScript) {
  name: 'BuildVMImage'
  location: resourceGroup().location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uamiId}': {}
    }
  }
  properties: {
    forceUpdateTag: '1'
    azPowerShellVersion: '5.9'
    arguments: ''
    scriptContent: 'Invoke-AzResourceAction -ResourceName ${imageTemplateName} -ResourceGroupName ${rgname} -ResourceType Microsoft.VirtualMachineImages/imageTemplates -ApiVersion "2020-02-14" -Action Run -Force'
    timeout: 'PT5M'
    cleanupPreference: 'Always'
    retentionInterval: 'P1D'
  }
  dependsOn: [
    imageTemplateName_resource
  ]
}
