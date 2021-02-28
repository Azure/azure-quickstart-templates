param location string {
  metadata: {
    description: 'The location into which the Azure Functions resources should be deployed.'
  }
}
param appName string {
  metadata: {
    description: 'The name of the Azure Functions application to create. This must be globally unique.'
  }
}
param functionRuntime string {
  default: 'dotnet'
  metadata: {
    description: 'The application runtime that the function app uses.'
  }
}
param functionPlanSkuName string {
  metadata: {
    description: 'The name of the SKU to use when creating the Azure Functions plan. Common SKUs include Y1 (consumption) and EP1, EP2, and EP3 (premium).'
  }
}

var appServicePlanName = 'FunctionPlan'
var appInsightsName = 'AppInsights'
var storageAccountName = 'fnstor${uniqueString(resourceGroup().id, appName)}'
var functionPlanKind = (functionPlanSkuName == 'Y1') ? 'functionapp' : 'elastic'
var functionNameComputed = 'MyHttpTriggeredFunction'

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource appInsights 'Microsoft.Insights/components@2018-05-01-preview' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource functionPlan 'Microsoft.Web/serverFarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  kind: functionPlanKind // TODO check if this is mandatory or not, and delete functionPlanKind variable if not
  sku: {
    name: functionPlanSkuName
  }
  properties: {} // TODO check if this is mandatory or not
}

resource functionApp 'Microsoft.Web/sites@2020-06-01' = {
  name: appName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: functionPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${appInsights.properties.InstrumentationKey}'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionRuntime
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'AzureWebJobsDisableHomepage' // This hides the default Azure Functions homepage, which means that Front Door health probe traffic is significantly reduced.
          value: 'true'
        }
      ]
    }
    httpsOnly: true
  }
}

resource function 'Microsoft.Web/sites/functions@2020-06-01' = {
  name: '${functionApp.name}/${functionNameComputed}'
  properties: {
    config: {
      disabled: false
      bindings: [
        {
          name: 'req'
          type: 'httpTrigger'
          direction: 'in'
          authLevel: 'anonymous' // The function is configured to use anonymous authentication (i.e. no function key required), since the Azure Functions infrastructure will verify that the request has come through Front Door.
          methods: [
            'get'
          ]
        }
        {
          name: '$return'
          type: 'http'
          direction: 'out'
        }
      ]
    }
    files: {
      'run.csx': '#r "Newtonsoft.Json"\n\nusing System.Net;\nusing Microsoft.AspNetCore.Mvc;\nusing Microsoft.Extensions.Primitives;\nusing Newtonsoft.Json;\n\npublic static async Task<IActionResult> Run(HttpRequest req, ILogger log)\n{\n    log.LogInformation("C# HTTP trigger function processed a request.");\n\n    string name = req.Query["name"];\n\n    string requestBody = await new StreamReader(req.Body).ReadToEndAsync();\n    dynamic data = JsonConvert.DeserializeObject(requestBody);\n    name = name ?? data?.name;\n\n    string responseMessage = string.IsNullOrEmpty(name)\n        ? "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."\n                : $"Hello, {name}. This HTTP triggered function executed successfully.";\n\n            return new OkObjectResult(responseMessage);\n}\n'
    }
  }
}

output functionAppHostName string = functionApp.properties.defaultHostName
output functionName string = functionNameComputed
output functionAppResourceId string = functionApp.id
