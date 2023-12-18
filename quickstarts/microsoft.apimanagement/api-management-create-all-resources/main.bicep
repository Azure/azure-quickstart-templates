@description('The email address of the owner of the service')
@minLength(1)
param publisherEmail string

@description('The name of the owner of the service')
@minLength(1)
param publisherName string

@description('The pricing tier of this API Management service')
@allowed([
  'Consumption'
  'Developer'
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Developer'

@description('The instance size of this API Management service.')
param skuCount int = 1

@description('Tenant policy XML.')
param tenantPolicy string

@description('API policy XML.')
param apiPolicy string

@description('Operation policy XML.')
param operationPolicy string

@description('Product policy XML.')
param productPolicy string

@description('Location for all resources.')
param location string = resourceGroup().location

var apiManagementServiceName = 'apiservice${uniqueString(resourceGroup().id)}'

resource apiManagementService 'Microsoft.ApiManagement/service@2022-08-01' = {
  name: apiManagementServiceName
  location: location
  tags: {}
  sku: {
    name: sku
    capacity: skuCount
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

resource apiManagementServiceName_policy 'Microsoft.ApiManagement/service/policies@2022-08-01' = {
  parent: apiManagementService
  name: 'policy'
  properties: {
    value: tenantPolicy
  }
}

resource apiManagementServiceName_PetStoreSwaggerImportExample 'Microsoft.ApiManagement/service/apis@2022-08-01' = {
  parent: apiManagementService
  name: 'PetStoreSwaggerImportExample'
  properties: {
    displayName: 'Swagger Petstore'
    format: 'swagger-link-json'
    serviceUrl: 'http://petstore.swagger.io/v2/swagger.json'
    path: 'examplepetstore'
    protocols: [
      'HTTPS'
      'HTTP'
    ]
  }
}

resource apiManagementServiceName_exampleApi 'Microsoft.ApiManagement/service/apis@2022-08-01' = {
  parent: apiManagementService
  name: 'exampleApi'
  properties: {
    displayName: 'Example API Name'
    description: 'Description for example API'
    serviceUrl: 'https://example.net'
    path: 'exampleapipath'
    protocols: [
      'HTTPS'
    ]
  }
}

resource apiManagementServiceName_exampleApi_exampleOperationsDELETE 'Microsoft.ApiManagement/service/apis/operations@2022-08-01' = {
  parent: apiManagementServiceName_exampleApi
  name: 'exampleOperationsDELETE'
  properties: {
    displayName: 'DELETE resource'
    method: 'DELETE'
    urlTemplate: '/resource'
    description: 'A demonstration of a DELETE call'
  }
}

resource apiManagementServiceName_exampleApi_exampleOperationsGET 'Microsoft.ApiManagement/service/apis/operations@2022-08-01' = {
  parent: apiManagementServiceName_exampleApi
  name: 'exampleOperationsGET'
  properties: {
    displayName: 'GET resource'
    method: 'GET'
    urlTemplate: '/resource'
    description: 'A demonstration of a GET call'
  }
}

resource apiManagementServiceName_exampleApi_exampleOperationsGET_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2022-08-01' = {
  parent: apiManagementServiceName_exampleApi_exampleOperationsGET
  name: 'policy'
  properties: {
    value: operationPolicy
    format: 'xml'
  }
}

resource apiManagementServiceName_exampleApiWithPolicy 'Microsoft.ApiManagement/service/apis@2022-08-01' = {
  parent: apiManagementService
  name: 'exampleApiWithPolicy'
  properties: {
    displayName: 'Example API Name with Policy'
    description: 'Description for example API with policy'
    serviceUrl: 'https://exampleapiwithpolicy.net'
    path: 'exampleapiwithpolicypath'
    protocols: [
      'HTTPS'
    ]
  }
}

resource apiManagementServiceName_exampleApiWithPolicy_policy 'Microsoft.ApiManagement/service/apis/policies@2022-08-01' = {
  parent: apiManagementServiceName_exampleApiWithPolicy
  name: 'policy'
  properties: {
    value: apiPolicy
    format: 'xml'
  }
}

resource apiManagementServiceName_exampleProduct 'Microsoft.ApiManagement/service/products@2022-08-01' = {
  parent: apiManagementService
  name: 'exampleProduct'
  properties: {
    displayName: 'Example Product Name'
    description: 'Description for example product'
    terms: 'Terms for example product'
    subscriptionRequired: true
    approvalRequired: false
    subscriptionsLimit: 1
    state: 'published'
  }
}

resource apiManagementServiceName_exampleProduct_exampleApi 'Microsoft.ApiManagement/service/products/apis@2022-08-01' = {
  parent: apiManagementServiceName_exampleProduct
  name: 'exampleApi'
  dependsOn: [
    apiManagementServiceName_exampleApi
  ]
}

resource apiManagementServiceName_exampleProduct_policy 'Microsoft.ApiManagement/service/products/policies@2022-08-01' = {
  parent: apiManagementServiceName_exampleProduct
  name: 'policy'
  properties: {
    value: productPolicy
    format: 'xml'
  }
}

resource apiManagementServiceName_exampleUser1 'Microsoft.ApiManagement/service/users@2022-08-01' = {
  parent: apiManagementService
  name: 'exampleUser1'
  properties: {
    firstName: 'ExampleFirstName1'
    lastName: 'ExampleLastName1'
    email: 'ExampleFirst1@example.com'
    state: 'active'
    note: 'note for example user 1'
  }
}

resource apiManagementServiceName_exampleUser2 'Microsoft.ApiManagement/service/users@2022-08-01' = {
  parent: apiManagementService
  name: 'exampleUser2'
  properties: {
    firstName: 'ExampleFirstName2'
    lastName: 'ExampleLastName2'
    email: 'ExampleFirst2@example.com'
    state: 'active'
    note: 'note for example user 2'
  }
}

resource apiManagementServiceName_exampleUser3 'Microsoft.ApiManagement/service/users@2022-08-01' = {
  parent: apiManagementService
  name: 'exampleUser3'
  properties: {
    firstName: 'ExampleFirstName3'
    lastName: 'ExampleLastName3'
    email: 'ExampleFirst3@example.com'
    state: 'active'
    note: 'note for example user 3'
  }
}

resource apiManagementServiceName_exampleNamedValue 'Microsoft.ApiManagement/service/namedValues@2022-08-01' = {
  parent: apiManagementService
  name: 'exampleNamedValue'
  properties: {
    displayName: 'propertyExampleName'
    value: 'propertyExampleValue'
    tags: [
      'exampleTag'
    ]
  }
}

resource apiManagementServiceName_examplesubscription1 'Microsoft.ApiManagement/service/subscriptions@2022-08-01' = {
  parent: apiManagementService
  name: 'examplesubscription1'
  properties: {
    displayName: 'subscription 1'
    scope: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ApiManagement/service/exampleServiceName/products/exampleProduct'
    ownerId: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ApiManagement/service/exampleServiceName/users/exampleUser1'
  }
  dependsOn: [

    apiManagementServiceName_exampleProduct
    apiManagementServiceName_exampleUser1
  ]
}

resource apiManagementServiceName_examplesubscription2 'Microsoft.ApiManagement/service/subscriptions@2022-08-01' = {
  parent: apiManagementService
  name: 'examplesubscription2'
  properties: {
    displayName: 'subscription 2'
    scope: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ApiManagement/service/exampleServiceName/products/exampleProduct'
    ownerId: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ApiManagement/service/exampleServiceName/users/exampleUser3'
  }
  dependsOn: [

    apiManagementServiceName_exampleProduct
    apiManagementServiceName_exampleUser3
    apiManagementServiceName_examplesubscription1
  ]
}

resource apiManagementServiceName_exampleGroup 'Microsoft.ApiManagement/service/groups@2022-08-01' = {
  parent: apiManagementService
  name: 'exampleGroup'
  properties: {
    displayName: 'Example Group Name'
    description: 'Example group description'
  }
}

resource apiManagementServiceName_exampleGroup_exampleUser3 'Microsoft.ApiManagement/service/groups/users@2022-08-01' = {
  parent: apiManagementServiceName_exampleGroup
  name: 'exampleUser3'
}
