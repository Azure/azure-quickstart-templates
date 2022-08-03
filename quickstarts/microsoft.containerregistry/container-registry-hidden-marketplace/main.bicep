@minLength(5)
@maxLength(50)
@description('Name of the azure container registry (must be globally unique)')
param acrName string

@description('Enable an admin user that has push/pull permission to the registry.')
param acrAdminUserEnabled bool = false

@description('Location for all resources.')
param location  string = resourceGroup().location

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
@description('Tier of your Azure Container Registry.')
param acrSku    string = 'Basic'

@description('Marketplace Publisher')
param publisher string = 'bitnami'

@description('Marketplace Offer')
param offer     string = 'opencart-chart'

@description('Marketplace Plan')
param plan      string = 'default'

@description('Accept Container Terms of Usage, must be set to true by user.')
param acceptTerms bool = false

@description('The base URI where artifacts required by this template are located')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access artifacts')
@secure()
param _artifactsLocationSasToken string = ''

module acr '../container-registry/main.bicep' = {
  name: 'ACR'
  params: {
    location           : location
    acrName            : acrName
    acrSku             : acrSku
    acrAdminUserEnabled: acrAdminUserEnabled
  }
}

module acceptTerms 'nested_template/deploymentScripts.bicep' = if (acceptTerms) {
  name: 'ContainerDeployment'
  params: {
    location        : location
    installScriptUri: uri(_artifactsLocation, 'scripts/accept_container_terms.sh${_artifactsLocationSasToken}')
    publisher       : publisher
    offer           : offer
    plan            : plan
  }
}

module loadContainer 'nested_template/deploymentScripts.bicep' = {
  name: 'ContainerDeployment'
  params: {
    location        : location
    installScriptUri: uri(_artifactsLocation, 'scripts/container_deploy.sh${_artifactsLocationSasToken}')
    publisher       : publisher
    offer           : offer
    plan            : plan
  }
}
