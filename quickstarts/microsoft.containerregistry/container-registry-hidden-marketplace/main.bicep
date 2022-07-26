@minLength(5)
@maxLength(50)
@description('Name of the azure container registry (must be globally unique)')
param acrName string

@description('Enable an admin user that has push/pull permission to the registry.')
param acrAdminUserEnabled bool = false

@description('Location for all resources.')
param location string = resourceGroup().location

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
@description('Tier of your Azure Container Registry.')
param acrSku string = 'Basic'

@description('The base URI where artifacts required by this template are located')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access artifacts')
@secure()
param _artifactsLocationSasToken string = ''

SUBSCRIPTION_ID='edf507a2-6235-46c5-b560-fd463ba2e771'
PUBLISHER='microsoftcorporation1590077852919'
OFFER='horde-storage-container-preview'
PLAN='storage-container-test'
CONFIG_GUID='1dedfbed-4caa-42e8-bc0c-4e7d77707117'

var environmentVariables = [
  {
    name: 'RESOURCEGROUP'
    secureValue: resourceGroup().name
  }
  {
    name: 'SUBSCRIPTION_ID'
    secureValue: subscription().subscriptionId
  }
  {
    name: 'PUBLISHER'
    secureValue: 'microsoftcorporation1590077852919'
  }
  {
    name: 'OFFER'
    secureValue: 'horde-storage-container-preview'
  }
  {
    name: 'PLAN'
    secureValue: 'storage-container-test'
  }
  {
    name: 'CONFIG_GUID'
    secureValue: guid()
  }    
]

module acr '../container-registry/main.bicep' = {
  name: 'ACR'
  params: {
    location: location
    acrName: acrName
    acrSku: acrSku
    acrAdminUserEnabled: acrAdminUserEnabled
  }
}

module loadContainer 'nested_template/deploymentScripts.bicep' = {
  name: 'ContainerDeployment'
  params: {
    location: location
    installScriptUri: uri(_artifactsLocation, 'scripts/container_deploy.sh${_artifactsLocationSasToken}')
    environmentVariables: environmentVariables
  }
}
