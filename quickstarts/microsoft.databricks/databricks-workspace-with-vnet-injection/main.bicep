@description('Specifies whether to deploy Azure Databricks workspace with Secure Cluster Connectivity (No Public IP) enabled or not')
param disablePublicIp bool = true

@description('The name of the Azure Databricks workspace to create.')
param workspaceName string

@description('The pricing tier of workspace.')
@allowed([
  'trial'
  'standard'
  'premium'
])
param pricingTier string = 'premium'

@description('The complete ARM resource Id of the custom virtual network.')
param customVirtualNetworkId string

@description('The name of the public subnet in the custom VNet.')
param customPublicSubnetName string = 'public-subnet'

@description('The name of the private subnet in the custom VNet.')
param customPrivateSubnetName string = 'private-subnet'

@description('Location for all resources.')
param location string = resourceGroup().location

var managedResourceGroupName = 'databricks-rg-${workspaceName}-${uniqueString(workspaceName, resourceGroup().id)}'
var trimmedMRGName = substring(managedResourceGroupName, 0, min(length(managedResourceGroupName), 90))
var managedResourceGroupId = '${subscription().id}/resourceGroups/${trimmedMRGName}'

resource workspace 'Microsoft.Databricks/workspaces@2024-05-01' = {
  name: workspaceName
  location: location
  sku: {
    name: pricingTier
  }
  properties: {
    managedResourceGroupId: managedResourceGroupId
    parameters: {
      customVirtualNetworkId: {
        value: customVirtualNetworkId
      }
      customPublicSubnetName: {
        value: customPublicSubnetName
      }
      customPrivateSubnetName: {
        value: customPrivateSubnetName
      }
      enableNoPublicIp: {
        value: disablePublicIp
      }
    }
  }
}
