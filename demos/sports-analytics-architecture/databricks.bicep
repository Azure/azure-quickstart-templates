@description('Specifies whether to deploy Azure Databricks workspace with Secure Cluster Connectivity (No Public IP) enabled or not')
param disablePublicIp bool

@description('The name of the Azure Databricks workspace to create.')
param workspaceName string

var managedResourceGroupName = 'databricks-rg-${workspaceName}-${uniqueString(workspaceName, resourceGroup().id)}'

resource ws 'Microsoft.Databricks/workspaces@2018-04-01' = {
  name: workspaceName
  location: resourceGroup().location
  sku: {
    name: 'premium'
  }
  properties: {
    managedResourceGroupId: managedResourceGroup.id
    parameters: {
      enableNoPublicIp: {
        value: disablePublicIp
      }
    }
  }
}

resource managedResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  scope: subscription()
  name: managedResourceGroupName
}
