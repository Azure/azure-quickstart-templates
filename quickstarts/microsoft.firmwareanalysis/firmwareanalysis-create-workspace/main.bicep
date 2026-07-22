@description('Name of the firmware analysis workspace.')
param workspaceName string

@description('Location for the workspace.')
param location string = resourceGroup().location

@description('Optional tags to apply to the workspace.')
param tags object = {}

resource workspace 'Microsoft.IoTFirmwareDefense/workspaces@2025-04-01-preview' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {}
}

output workspaceId string = workspace.id
output workspaceNameOut string = workspace.name
