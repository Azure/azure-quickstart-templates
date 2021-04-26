@description('The location into which the Azure Functions resources should be deployed.')
param location string = resourceGroup().location

@description('The name of the Azure Functions application to create. This must be globally unique.')
param appName string = 'fn-${uniqueString(resourceGroup().id)}'

@description('The runtime to deploy onto the Azure Functions application.')
param functionRuntime string = 'dotnet'

@description('The name of the SKU to use when creating the Azure Functions plan. Common SKUs include Y1 (consumption) and EP1, EP2, and EP3 (premium).')
param functionPlanSkuName string = 'Y1'

var appServicePlanName = 'FunctionPlan'
var appInsightsName = 'AppInsights'
var storageAccountName = 'fnstor${uniqueString(resourceGroup().id, appName)}'
var functionPlanKind = (functionPlanSkuName == 'Y1') ? 'functionapp' : 'elastic'
var functionName = 'MyHttpTriggeredFunction'
var contributorRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') // as per https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#:~:text=b24988ac-6180-42a0-ab88-20f7382dd24c
var managedIdentityName = 'EventGridFunctionEnabler'
var deploymentScriptName = 'GetFunctionAppEventGridKey'

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
  kind: functionPlanKind
  sku: {
    name: functionPlanSkuName
  }
  properties: {}
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
  name: '${functionApp.name}/${functionName}'
  properties: {
    config: {
      disabled: false
      bindings: [
        {
          name: 'eventGridEvent'
          type: 'eventGridTrigger'
          direction: 'in'
        }
      ]
    }
    files: {
      'run.csx': '''
      #r "Microsoft.Azure.EventGrid"
      using Microsoft.Azure.EventGrid.Models;
      using Microsoft.Extensions.Logging;

      public static void Run(EventGridEvent eventGridEvent, ILogger log)
      {
          log.LogInformation(eventGridEvent.Data.ToString());
      }
      '''
    }
  }
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: functionApp
  name: guid(resourceGroup().id, managedIdentity.id, contributorRoleDefinitionId)
  properties: {
    roleDefinitionId: contributorRoleDefinitionId
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: deploymentScriptName
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  dependsOn: [
    roleAssignment
  ]
  properties: {
    azPowerShellVersion: '5.4'
    scriptContent: '''
    param([string] $FunctionHostResourceId)

    $ErrorActionPreference = 'Stop'

    # Try to get the key. If this fails, retry up to 5 times.
    $loopAttempts = 0
    while ($loopAttempts -lt 5)
    {
      $listKeysOutput = Invoke-AzResourceAction -ResourceId $FunctionHostResourceId -Action listKeys -ApiVersion 2020-06-01 -Force
      $eventGridKey = $listKeysOutput.systemKeys.eventgrid_extension
      if ($null -ne $eventGridKey)
      {
        break
      }

      $loopAttempts += 1
      Write-Output 'Event Grid key is not included in response. Sleeping for 5 seconds.'
      Start-Sleep -Seconds 5
    }

    if ($null -eq $eventGridKey)
    {
      Write-Error 'Event Grid key could not be obtained.'
      return 1
    }

    # Propagate to the deployment script output.
    $DeploymentScriptOutputs = @{}
    $DeploymentScriptOutputs['eventGridExtensionSystemKey'] = $eventGridKey
    '''
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'PT4H'
    arguments: '-FunctionHostResourceId ${functionApp.id}/host/default'
  }
}

output functionUrl string = 'https://${functionApp.properties.defaultHostName}/runtime/webhooks/EventGrid?functionName=${functionName}&code=${deploymentScript.properties.outputs.eventGridExtensionSystemKey}'
