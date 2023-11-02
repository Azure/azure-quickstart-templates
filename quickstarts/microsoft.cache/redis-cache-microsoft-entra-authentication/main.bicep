@description('Specify the name of the Azure Redis Cache to create.')
param redisCacheName string = 'redisCache-${uniqueString(resourceGroup().id)}'

@description('Location of all resources')
param location string = resourceGroup().location

@description('Specify the pricing tier of the new Azure Redis Cache.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param redisCacheSKU string = 'Standard'

@description('Specify the family for the sku. C = Basic/Standard, P = Premium.')
@allowed([
  'C'
  'P'
])
param redisCacheFamily string = 'C'

@description('Specify the size of the new Azure Redis Cache instance. Valid values: for C (Basic/Standard) family (0, 1, 2, 3, 4, 5, 6), for P (Premium) family (1, 2, 3, 4, 5)')
@allowed([
  0
  1
  2
  3
  4
  5
  6
])
param redisCacheCapacity int = 1

@description('Specify name of Built-In access policy to use as assignment.')
@allowed([
  'Data Owner'
  'Data Contributor'
  'Data Reader'
])
param builtInAccessPolicyName string = 'Data Reader'

@description('Specify name of custom access policy to create.')
param builtInAccessPolicyAssignmentName string = 'builtInAccessPolicyAssignment-${uniqueString(resourceGroup().id)}'

@description('Specify the valid objectId(usually it is a GUID) of the Microsoft Entra Service Principal or Managed Identity or User Principal to which the built-in access policy would be assigned.')
param builtInAccessPolicyAssignmentObjectId string = newGuid()

@description('Specify human readable name of principal Id of the Microsoft Entra Application name or Managed Identity name used for built-in policy assignment.')
param builtInAccessPolicyAssignmentObjectAlias string = 'builtInAccessPolicyApplication-${uniqueString(resourceGroup().id)}'

@description('Specify name of custom access policy to create.')
param customAccessPolicyName string = 'customAccessPolicy-${uniqueString(resourceGroup().id)}'

@description('Specify the valid permissions for the customer access policy to create. For details refer to https://aka.ms/redis/ConfigureAccessPolicyPermissions')
param customAccessPolicyPermissions string = '+@connection +get +hget allkeys'

@description('Specify name of custom access policy to create.')
param customAccessPolicyAssignmentName string = 'customAccessPolicyAssignment-${uniqueString(resourceGroup().id)}'

@description('Specify the valid objectId(usually it is a GUID) of the Microsoft Entra Service Principal or Managed Identity or User Principal to which the custom access policy would be assigned.')
param customAccessPolicyAssignmentObjectId string = newGuid()

@description('Specify human readable name of principal Id of the Microsoft Entra Application name or Managed Identity name used for custom policy assignment.')
param customAccessPolicyAssignmentObjectAlias string = 'customAccessPolicyApplication-${uniqueString(resourceGroup().id)}'

resource redisCache 'Microsoft.Cache/redis@2023-08-01' = {
  name: redisCacheName
  location: location
  properties: {
    enableNonSslPort: false
    minimumTlsVersion: '1.2'
    sku: {
      capacity: redisCacheCapacity
      family: redisCacheFamily
      name: redisCacheSKU
    }
    redisConfiguration: {
      'aad-enabled': 'true'
    }
  }
}

resource redisCacheBuiltInAccessPolicyAssignment 'Microsoft.Cache/redis/accessPolicyAssignments@2023-08-01' = {
  name: builtInAccessPolicyAssignmentName
  parent: redisCache
  properties: {
    accessPolicyName: builtInAccessPolicyName
    objectId: builtInAccessPolicyAssignmentObjectId
    objectIdAlias: builtInAccessPolicyAssignmentObjectAlias
  }
}

resource redisCacheCustomAccessPolicy 'Microsoft.Cache/redis/accessPolicies@2023-08-01' = {
  name: customAccessPolicyName
  parent: redisCache
  properties: {
    permissions: customAccessPolicyPermissions
  }
  dependsOn: [
    redisCacheBuiltInAccessPolicyAssignment
  ]
}

resource redisCacheCustomAccessPolicyAssignment 'Microsoft.Cache/redis/accessPolicyAssignments@2023-08-01' = {
  name: customAccessPolicyAssignmentName
  parent: redisCache
  properties: {
    accessPolicyName: customAccessPolicyName
    objectId: customAccessPolicyAssignmentObjectId
    objectIdAlias: customAccessPolicyAssignmentObjectAlias
  }
  dependsOn: [
    redisCacheCustomAccessPolicy
  ]
}
