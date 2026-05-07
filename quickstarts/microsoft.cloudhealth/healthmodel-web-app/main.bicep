@description('Name of the health model. This also becomes the root entity name.')
param healthModelName string

@description('Location for all resources.')
param location string = resourceGroup().location

// Health Model
resource healthModel 'Microsoft.CloudHealth/healthmodels@2026-05-01-preview' = {
  name: healthModelName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

// Authentication Setting — uses the health model's system-assigned managed identity
resource authSetting 'Microsoft.CloudHealth/healthmodels/authenticationsettings@2026-05-01-preview' = {
  parent: healthModel
  name: 'default-auth'
  properties: {
    displayName: 'Default Authentication'
    authenticationKind: 'ManagedIdentity'
    managedIdentityName: 'SystemAssigned'
  }
}

// =============================================================================
// Signal Definitions — reusable metric and log signal templates
// =============================================================================

// App Service metrics
resource httpResponseTimeSignal 'Microsoft.CloudHealth/healthmodels/signaldefinitions@2026-05-01-preview' = {
  parent: healthModel
  name: 'http-response-time'
  properties: {
    signalKind: 'AzureResourceMetric'
    displayName: 'HTTP Response Time'
    metricNamespace: 'microsoft.web/sites'
    metricName: 'HttpResponseTime'
    aggregationType: 'Average'
    timeGrain: 'PT1M'
    dataUnit: 'Seconds'
    evaluationRules: {
      degradedRule: {
        operator: 'GreaterThan'
        threshold: 2
      }
      unhealthyRule: {
        operator: 'GreaterThan'
        threshold: 5
      }
    }
  }
}

resource http5xxSignal 'Microsoft.CloudHealth/healthmodels/signaldefinitions@2026-05-01-preview' = {
  parent: healthModel
  name: 'http-5xx'
  properties: {
    signalKind: 'AzureResourceMetric'
    displayName: 'HTTP Server Errors'
    metricNamespace: 'microsoft.web/sites'
    metricName: 'Http5xx'
    aggregationType: 'Total'
    timeGrain: 'PT5M'
    dataUnit: 'Count'
    evaluationRules: {
      degradedRule: {
        operator: 'GreaterThan'
        threshold: 5
      }
      unhealthyRule: {
        operator: 'GreaterThan'
        threshold: 25
      }
    }
  }
}

// API Management metrics
resource apimFailedRequestsSignal 'Microsoft.CloudHealth/healthmodels/signaldefinitions@2026-05-01-preview' = {
  parent: healthModel
  name: 'apim-failed-requests'
  properties: {
    signalKind: 'AzureResourceMetric'
    displayName: 'APIM Failed Requests'
    metricNamespace: 'microsoft.apimanagement/service'
    metricName: 'FailedRequests'
    aggregationType: 'Total'
    timeGrain: 'PT5M'
    dataUnit: 'Count'
    evaluationRules: {
      degradedRule: {
        operator: 'GreaterThan'
        threshold: 10
      }
      unhealthyRule: {
        operator: 'GreaterThan'
        threshold: 50
      }
    }
  }
}

// Cosmos DB metrics
resource cosmosDbAvailabilitySignal 'Microsoft.CloudHealth/healthmodels/signaldefinitions@2026-05-01-preview' = {
  parent: healthModel
  name: 'cosmosdb-availability'
  properties: {
    signalKind: 'AzureResourceMetric'
    displayName: 'Cosmos DB Availability'
    metricNamespace: 'microsoft.documentdb/databaseaccounts'
    metricName: 'ServiceAvailability'
    aggregationType: 'Average'
    timeGrain: 'PT5M'
    dataUnit: 'Percent'
    evaluationRules: {
      degradedRule: {
        operator: 'LessThan'
        threshold: json('99.9')
      }
      unhealthyRule: {
        operator: 'LessThan'
        threshold: 99
      }
    }
  }
}

// Redis Cache metrics
resource redisCacheHitsSignal 'Microsoft.CloudHealth/healthmodels/signaldefinitions@2026-05-01-preview' = {
  parent: healthModel
  name: 'redis-server-load'
  properties: {
    signalKind: 'AzureResourceMetric'
    displayName: 'Redis Server Load'
    metricNamespace: 'microsoft.cache/redis'
    metricName: 'serverLoad'
    aggregationType: 'Average'
    timeGrain: 'PT5M'
    dataUnit: 'Percent'
    evaluationRules: {
      degradedRule: {
        operator: 'GreaterThan'
        threshold: 70
      }
      unhealthyRule: {
        operator: 'GreaterThan'
        threshold: 90
      }
    }
  }
}

// Log Analytics signal definitions
resource failedRequestsLogSignal 'Microsoft.CloudHealth/healthmodels/signaldefinitions@2026-05-01-preview' = {
  parent: healthModel
  name: 'failed-requests-log'
  properties: {
    signalKind: 'LogAnalyticsQuery'
    displayName: 'Failed Requests (Log)'
    queryText: 'AppRequests | where Success == false | summarize FailedCount=count() by bin(TimeGenerated, 5m) | project FailedCount'
    timeGrain: 'PT5M'
    valueColumnName: 'FailedCount'
    refreshInterval: 'PT5M'
    dataUnit: 'Count'
    evaluationRules: {
      degradedRule: {
        operator: 'GreaterThan'
        threshold: 10
      }
      unhealthyRule: {
        operator: 'GreaterThan'
        threshold: 50
      }
    }
  }
}

resource exceptionRateLogSignal 'Microsoft.CloudHealth/healthmodels/signaldefinitions@2026-05-01-preview' = {
  parent: healthModel
  name: 'exception-rate-log'
  properties: {
    signalKind: 'LogAnalyticsQuery'
    displayName: 'Exception Rate (Log)'
    queryText: 'AppExceptions | summarize ExceptionCount=count() by bin(TimeGenerated, 5m) | project ExceptionCount'
    timeGrain: 'PT5M'
    valueColumnName: 'ExceptionCount'
    refreshInterval: 'PT5M'
    dataUnit: 'Count'
    evaluationRules: {
      degradedRule: {
        operator: 'GreaterThan'
        threshold: 5
      }
      unhealthyRule: {
        operator: 'GreaterThan'
        threshold: 20
      }
    }
  }
}

// =============================================================================
// T1 Entities — logical groupings
// =============================================================================

resource frontendEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'frontend'
  properties: {
    displayName: 'Frontend'
  }
}

resource backendEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'backend'
  properties: {
    displayName: 'Backend'
  }
}

resource dataEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'data'
  properties: {
    displayName: 'Data'
  }
}

// =============================================================================
// T2 Entities — components to attach signals to after deployment
// =============================================================================

resource webEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'web'
  properties: {
    displayName: 'Web'
  }
}

resource apiGatewayEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'api-gateway'
  properties: {
    displayName: 'API Gateway'
  }
}

resource apiEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'api'
  properties: {
    displayName: 'API'
  }
}

resource workerEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'worker'
  properties: {
    displayName: 'Worker'
  }
}

resource databaseEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'database'
  properties: {
    displayName: 'Database'
  }
}

resource cacheEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'cache'
  properties: {
    displayName: 'Cache'
  }
}

// =============================================================================
// Root Entity — override the auto-created root to add alerts
// =============================================================================

resource rootEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: healthModelName
  properties: {
    displayName: healthModelName
    alerts: {
      unhealthy: {
        severity: 'Sev1'
        description: 'The health model root entity is unhealthy. One or more tiers have critical issues.'
      }
      degraded: {
        severity: 'Sev3'
        description: 'The health model root entity is degraded. One or more tiers are experiencing issues.'
      }
    }
  }
}

// T1 → Root relationships (root entity is auto-created with the health model name)
resource rootToFrontend 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: '${healthModelName}-frontend'
  properties: {
    parentEntityName: healthModelName
    childEntityName: 'frontend'
  }
  dependsOn: [frontendEntity]
}

resource rootToBackend 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: '${healthModelName}-backend'
  properties: {
    parentEntityName: healthModelName
    childEntityName: 'backend'
  }
  dependsOn: [backendEntity]
}

resource rootToData 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: '${healthModelName}-data'
  properties: {
    parentEntityName: healthModelName
    childEntityName: 'data'
  }
  dependsOn: [dataEntity]
}

// T2 → T1 relationships
resource frontendToWeb 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'frontend-web'
  properties: {
    parentEntityName: 'frontend'
    childEntityName: 'web'
  }
  dependsOn: [frontendEntity, webEntity]
}

resource frontendToApiGateway 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'frontend-api-gateway'
  properties: {
    parentEntityName: 'frontend'
    childEntityName: 'api-gateway'
  }
  dependsOn: [frontendEntity, apiGatewayEntity]
}

resource backendToApi 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'backend-api'
  properties: {
    parentEntityName: 'backend'
    childEntityName: 'api'
  }
  dependsOn: [backendEntity, apiEntity]
}

resource backendToWorker 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'backend-worker'
  properties: {
    parentEntityName: 'backend'
    childEntityName: 'worker'
  }
  dependsOn: [backendEntity, workerEntity]
}

resource dataToDatabase 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'data-database'
  properties: {
    parentEntityName: 'data'
    childEntityName: 'database'
  }
  dependsOn: [dataEntity, databaseEntity]
}

resource dataToCache 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'data-cache'
  properties: {
    parentEntityName: 'data'
    childEntityName: 'cache'
  }
  dependsOn: [dataEntity, cacheEntity]
}

output healthModelName string = healthModel.name
output healthModelId string = healthModel.id
output location string = healthModel.location
