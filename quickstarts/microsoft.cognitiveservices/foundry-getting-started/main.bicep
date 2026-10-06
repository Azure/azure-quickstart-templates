@description('Name of the Microsoft Foundry account. Also used as the developer API subdomain.')
param foundryName string = 'foundry-${uniqueString(resourceGroup().id)}'

@description('Name of the default project created in the Microsoft Foundry account.')
param projectName string = '${foundryName}-proj'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the model deployment created in the Microsoft Foundry account.')
param modelDeploymentName string = 'gpt-4.1-mini'

@description('Model to deploy. See the Microsoft Foundry model catalog for available models, publishers and versions.')
param modelName string = 'gpt-4.1-mini'

@description('Publisher/format of the model to deploy.')
param modelFormat string = 'OpenAI'

@description('Version of the model to deploy.')
param modelVersion string = '2025-04-14'

@description('Capacity (in thousands of tokens per minute) for the model deployment.')
param modelCapacity int = 1

/*
  A Microsoft Foundry account is a variant of a Microsoft.CognitiveServices/accounts
  resource with kind 'AIServices'. It is the successor to standalone Azure AI services
  such as Azure OpenAI, Azure Speech, and Azure Language, and exposes their capabilities
  through a single account and developer API endpoint.

  The account is where common, security-sensitive settings live: networking, compute,
  and customer-managed key encryption. These settings apply to all projects in the account.
*/
resource foundry 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: foundryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  properties: {
    // Required to create and manage projects in Microsoft Foundry.
    allowProjectManagement: true
    // Defines the developer API endpoint subdomain.
    customSubDomainName: foundryName
    disableLocalAuth: false
  }
}

/*
  Every Foundry account has one default project, and more can be added over time.
  A project is a lightweight organizational folder for your work - it groups the inputs
  and outputs of a use case (files and other assets) and isolates that state from other
  projects. It can have its own RBAC and identity, but it does not carry the account-level
  security settings (networking, compute, encryption); those are inherited from the account.
  Creating the default project up front lets development teams get started immediately.
*/
resource project 'Microsoft.CognitiveServices/accounts/projects@2025-06-01' = {
  name: projectName
  parent: foundry
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

/*
  Optionally deploy a model to use in the playground, agents and other tools.
*/
resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2025-06-01' = {
  parent: foundry
  name: modelDeploymentName
  sku: {
    capacity: modelCapacity
    name: 'GlobalStandard'
  }
  properties: {
    model: {
      name: modelName
      format: modelFormat
      version: modelVersion
    }
  }
}

@description('Resource ID of the Microsoft Foundry account.')
output foundryId string = foundry.id

@description('Developer API endpoint for the Microsoft Foundry account.')
output foundryEndpoint string = foundry.properties.endpoint

@description('Resource ID of the default project.')
output projectId string = project.id

@description('Name of the deployed model.')
output modelDeploymentName string = modelDeployment.name
