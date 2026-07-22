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
// Signal definitions define WHAT to measure and WHEN it's degraded or unhealthy.
// They are not attached to any entity or Azure resource by default.
//
// To use them, update an entity's signalGroups to reference the definition:
//
//   signalGroups: {
//     azureResource: {
//       authenticationSetting: authSetting.name
//       azureResourceId: '<your-resource-id>'
//       signals: [
//         {
//           name: 'my-signal'
//           signalKind: 'AzureResourceMetric'
//           signalDefinitionName: httpResponseTimeSignal.name
//         }
//       ]
//     }
//   }
//
// For log signals, use signalGroups.azureLogAnalytics with a workspace ID.
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
  name: 'redis-cache-hits'
  properties: {
    signalKind: 'AzureResourceMetric'
    displayName: 'Redis Cache Hits'
    metricNamespace: 'microsoft.cache/redis'
    metricName: 'cachehits'
    aggregationType: 'Average'
    timeGrain: 'PT5M'
    dataUnit: 'Count'
    evaluationRules: {
      degradedRule: {
        operator: 'LessThan'
        threshold: 100
      }
      unhealthyRule: {
        operator: 'LessThan'
        threshold: 10
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
    canvasPosition: {
      x: 0
      y: 200
    }
  }
}

resource backendEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'backend'
  properties: {
    displayName: 'Backend'
    canvasPosition: {
      x: 450
      y: 200
    }
  }
}

resource dataEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'data'
  properties: {
    displayName: 'Data'
    canvasPosition: {
      x: 900
      y: 200
    }
  }
}

// =============================================================================
// T2 Entities — attach your Azure resources and signal definitions to these.
// Uncomment the signalGroups block and replace the azureResourceId placeholder.
// =============================================================================

resource webEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'web'
  properties: {
    displayName: 'Web (attach App Service)'
    canvasPosition: {
      x: -100
      y: 400
    }
    // Uncomment to wire up an App Service:
    // signalGroups: {
    //   azureResource: {
    //     authenticationSetting: authSetting.name
    //     azureResourceId: '<your-app-service-resource-id>'
    //     signals: [
    //       {
    //         name: 'web-response-time'
    //         signalKind: 'AzureResourceMetric'
    //         signalDefinitionName: httpResponseTimeSignal.name
    //       }
    //       {
    //         name: 'web-http-5xx'
    //         signalKind: 'AzureResourceMetric'
    //         signalDefinitionName: http5xxSignal.name
    //       }
    //     ]
    //   }
    // }
  }
}

resource apiGatewayEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'api-gateway'
  properties: {
    displayName: 'API Gateway (attach APIM)'
    canvasPosition: {
      x: 100
      y: 400
    }
    // Uncomment to wire up an API Management instance:
    // signalGroups: {
    //   azureResource: {
    //     authenticationSetting: authSetting.name
    //     azureResourceId: '<your-apim-resource-id>'
    //     signals: [
    //       {
    //         name: 'apim-failed-requests'
    //         signalKind: 'AzureResourceMetric'
    //         signalDefinitionName: apimFailedRequestsSignal.name
    //       }
    //     ]
    //   }
    // }
  }
}

resource apiEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'api'
  properties: {
    displayName: 'API (attach App Service)'
    canvasPosition: {
      x: 350
      y: 400
    }
    // Uncomment to wire up an App Service:
    // signalGroups: {
    //   azureResource: {
    //     authenticationSetting: authSetting.name
    //     azureResourceId: '<your-api-app-service-resource-id>'
    //     signals: [
    //       {
    //         name: 'api-response-time'
    //         signalKind: 'AzureResourceMetric'
    //         signalDefinitionName: httpResponseTimeSignal.name
    //       }
    //       {
    //         name: 'api-http-5xx'
    //         signalKind: 'AzureResourceMetric'
    //         signalDefinitionName: http5xxSignal.name
    //       }
    //     ]
    //   }
    // }
  }
}

resource workerEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'worker'
  properties: {
    displayName: 'Worker'
    canvasPosition: {
      x: 550
      y: 400
    }
  }
}

resource databaseEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'database'
  properties: {
    displayName: 'Database (attach Cosmos DB)'
    canvasPosition: {
      x: 800
      y: 400
    }
    // Uncomment to wire up a Cosmos DB account:
    // signalGroups: {
    //   azureResource: {
    //     authenticationSetting: authSetting.name
    //     azureResourceId: '<your-cosmosdb-resource-id>'
    //     signals: [
    //       {
    //         name: 'db-availability'
    //         signalKind: 'AzureResourceMetric'
    //         signalDefinitionName: cosmosDbAvailabilitySignal.name
    //       }
    //     ]
    //   }
    // }
  }
}

resource cacheEntity 'Microsoft.CloudHealth/healthmodels/entities@2026-05-01-preview' = {
  parent: healthModel
  name: 'cache'
  properties: {
    displayName: 'Cache (attach Redis)'
    canvasPosition: {
      x: 1050
      y: 400
    }
    // Uncomment to wire up a Redis Cache:
    // signalGroups: {
    //   azureResource: {
    //     authenticationSetting: authSetting.name
    //     azureResourceId: '<your-redis-cache-resource-id>'
    //     signals: [
    //       {
    //         name: 'cache-hits'
    //         signalKind: 'AzureResourceMetric'
    //         signalDefinitionName: redisCacheHitsSignal.name
    //       }
    //     ]
    //   }
    // }
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
    canvasPosition: {
      x: 400
      y: 0
    }
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
    childEntityName: frontendEntity.name
  }
}

resource rootToBackend 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: '${healthModelName}-backend'
  properties: {
    parentEntityName: healthModelName
    childEntityName: backendEntity.name
  }
}

resource rootToData 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: '${healthModelName}-data'
  properties: {
    parentEntityName: healthModelName
    childEntityName: dataEntity.name
  }
}

// T2 → T1 relationships
resource frontendToWeb 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'frontend-web'
  properties: {
    parentEntityName: frontendEntity.name
    childEntityName: webEntity.name
  }
}

resource frontendToApiGateway 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'frontend-api-gateway'
  properties: {
    parentEntityName: frontendEntity.name
    childEntityName: apiGatewayEntity.name
  }
}

resource backendToApi 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'backend-api'
  properties: {
    parentEntityName: backendEntity.name
    childEntityName: apiEntity.name
  }
}

resource backendToWorker 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'backend-worker'
  properties: {
    parentEntityName: backendEntity.name
    childEntityName: workerEntity.name
  }
}

resource dataToDatabase 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'data-database'
  properties: {
    parentEntityName: dataEntity.name
    childEntityName: databaseEntity.name
  }
}

resource dataToCache 'Microsoft.CloudHealth/healthmodels/relationships@2026-05-01-preview' = {
  parent: healthModel
  name: 'data-cache'
  properties: {
    parentEntityName: dataEntity.name
    childEntityName: cacheEntity.name
  }
}

output healthModelName string = healthModel.name
output healthModelId string = healthModel.id
output location string = healthModel.location
