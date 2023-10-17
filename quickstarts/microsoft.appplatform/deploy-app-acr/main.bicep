@description('Azure Spring Apps resource name.')
param name string

@description('Docker image deployed to the app')
param image string = 'azurespringapps/samples/hello-world:0.0.1'

@description('Docker image language framework')
param imageFramework string = 'springboot'

@description('Docker image server registry')
param imageServer string = 'mcr.microsoft.com'

@description('Docker image server auth username')
param imageServerUsername string = ''

@description('Docker image server password')
@secure()
param imageServerPassword string = ''

@description('App name')
param appName string = 'hello-world'

@description('Deployment name')
param deploymentName string = 'default'

@description('Bind to Service Registry. Used for Enterprise tier only.')
param bindServiceRegistry bool = true

@description('Pattern retrieved from Application Configuration Service. Used for Enterprise tier only.')
param applicationConfigurationServicePattern array = []

resource spring 'Microsoft.AppPlatform/Spring@2022-12-01' existing = {
  name: name
}

var bindAppWithServiceRegistry = bindServiceRegistry && spring.sku.name == 'E0'

resource serviceRegistry 'Microsoft.AppPlatform/Spring/serviceRegistries@2022-12-01' existing = if (bindAppWithServiceRegistry) {
  name: 'default'
  parent: spring
}

var bindAppWithACS = length(applicationConfigurationServicePattern) > 0 && spring.sku.name == 'E0'

resource applicationConfigurationService 'Microsoft.AppPlatform/Spring/configurationServices@2022-12-01' existing = if (bindAppWithACS) {
  name: 'default'
  parent: spring
}

resource app 'Microsoft.AppPlatform/Spring/apps@2022-12-01' = {
  name: appName
  parent: spring
  properties: {
    addonConfigs: {
      serviceRegistry: bindAppWithServiceRegistry ? {
        resourceId: serviceRegistry.id
      } : null
      applicationConfigurationService: bindAppWithACS ? {
        resourceId: applicationConfigurationService.id
      } : null
    }
    public: true
  }
}

resource deployment 'Microsoft.AppPlatform/Spring/apps/deployments@2022-12-01' = {
  name: deploymentName
  parent: app
  properties: {
    source: {
      type: 'Container'
      customContainer: {
        containerImage: image
        server: imageServer
        languageFramework: imageFramework
        imageRegistryCredential: imageServerUsername == '' || imageServerUsername == null ? null : {
          username: imageServerUsername
          password: imageServerPassword
        }
      }
    }
    deploymentSettings: {
      addonConfigs: {
        applicationConfigurationService: bindAppWithACS ? {
          patterns: applicationConfigurationServicePattern
        } : null
      }
      resourceRequests: {
        cpu: '1'
        memory: '2Gi'
      }
    }
    active: true
  }
  sku: {
    tier: 'Enterprise'
    name: 'E0'
    capacity: 1
  }
}

output endpoint string = app.properties.url
