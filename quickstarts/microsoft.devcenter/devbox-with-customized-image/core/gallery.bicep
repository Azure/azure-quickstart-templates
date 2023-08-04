param galleryName string
param imageDefinitionName string
param imageOffer string
param imagePublisher string
param imageSku string
param imageTemplateName string
param templateIdentityName string
param location string = resourceGroup().location
param tags object = {}
param guidId string

var templateRoleDefinitionName = guid(resourceGroup().id)
var imageBuildName = take('${imageDefinitionName}-${guidId}-buid',64)
var buildCommand = 'Invoke-AzResourceAction -ResourceName "${imageTemplateName}" -ResourceGroupName "${resourceGroup().name}" -ResourceType "Microsoft.VirtualMachineImages/imageTemplates" -ApiVersion "2020-02-14" -Action Run -Force'

// Add your own command to install the software or tools
var customizedCommand = [{
  type: 'PowerShell'
  name: 'Install Choco and other tools'
  inline: [
    'Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(\'https://community.chocolatey.org/install.ps1\'))'
    'choco install -y git'
    'choco install -y azure-cli'
    'choco install -y vscode'
    '$vscode_extension_dir="C:/temp/extensions"; New-Item $vscode_extension_dir -ItemType Directory -Force; [Environment]::SetEnvironmentVariable("VSCODE_EXTENSIONS", $vscode_extension_dir, "Machine"); $env:VSCODE_EXTENSIONS=$vscode_extension_dir; Start-Process -FilePath "C:/Program Files/Microsoft VS Code/bin/code.cmd"  -ArgumentList " --install-extension github.copilot"  -Wait -NoNewWindow'
  ]
}]

resource computeGallery 'Microsoft.Compute/galleries@2022-03-03' = {
  name: galleryName
  location: location
  tags: tags
}

resource imageDefinition 'Microsoft.Compute/galleries/images@2022-03-03' = {
  parent: computeGallery
  name: imageDefinitionName
  location: location
  properties: {
    hyperVGeneration: 'V2'
    architecture: 'x64'
    features: [
      {
          name: 'SecurityType'
          value: 'TrustedLaunch'
      }
    ]
    identifier: {
      offer: imageOffer
      publisher: imagePublisher
      sku: imageSku
    }
    osState: 'Generalized'
    osType: 'Windows'
  }
}

resource templateIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: templateIdentityName
  location: location
}

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2022-02-14' = {
  name: imageTemplateName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${templateIdentity.id}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: 100
    vmProfile: {
      vmSize: 'Standard_DS2_v2'
      osDiskSizeGB: 127
    }
    source: {
      type: 'PlatformImage'
      publisher: imagePublisher
      offer: imageOffer
      sku: imageSku
      version: 'Latest'
    }
    customize: customizedCommand
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: imageDefinition.id
        runOutputName: '${imageDefinitionName}_Output'
        replicationRegions: array(location)
      }
    ]
  }

  dependsOn: [
    templateRoleAssignment
  ]
}

resource templateRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: templateRoleDefinitionName
  properties: {
    roleName: templateRoleDefinitionName
    description: 'Image Builder access to create resources for the image build, you should delete or split out as appropriate'
    type: 'customRole'
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
          'Microsoft.Storage/storageAccounts/blobServices/containers/read'
          'Microsoft.Storage/storageAccounts/blobServices/containers/write'
          'Microsoft.Resources/deployments/read'
          'Microsoft.Resources/deploymentScripts/read'
          'Microsoft.Resources/deploymentScripts/write'
          'Microsoft.VirtualMachineImages/imageTemplates/run/action'
          'Microsoft.ContainerInstance/containerGroups/read'
          'Microsoft.ContainerInstance/containerGroups/write'
          'Microsoft.ContainerInstance/containerGroups/start/action'
        ]
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
}

resource templateRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, '${templateRoleDefinition.id}', templateIdentity.id)
  properties: {
    roleDefinitionId: templateRoleDefinition.id
    principalId: templateIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource imageTemplateBuild 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: imageBuildName
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
    forceUpdateTag: guidId
    azPowerShellVersion: '8.3'
    scriptContent: buildCommand
    timeout: 'PT2H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

output name string = computeGallery.name
