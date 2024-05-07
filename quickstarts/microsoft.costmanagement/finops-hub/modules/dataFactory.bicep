// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//==============================================================================
// Parameters
//==============================================================================

@description('Optional. Name of the hub. Used to ensure unique resource names. Default: "finops-hub".')
param dataFactoryName string

@description('Required. The name of the Azure Key Vault instance.')
param keyVaultName string

@description('Required. The name of the Azure storage account instance.')
param storageAccountName string

@description('Required. The name of the container where Cost Management data is exported.')
param exportContainerName string

@description('Required. The name of the container where normalized data is ingested.')
param ingestionContainerName string

@description('Optional. Indicates whether ingested data should be converted to Parquet. Default: true.')
param convertToParquet bool = true

@description('Optional. The location to use for the managed identity and deployment script to auto-start triggers. Default = (resource group location).')
param location string = resourceGroup().location

@description('Optional. Tags to apply to all resources. We will also add the cm-resource-parent tag for improved cost roll-ups in Cost Management.')
param tags object = {}

@description('Optional. Tags to apply to resources based on their resource type. Resource type specific tags will be merged with tags for all resources.')
param tagsByResource object = {}

//------------------------------------------------------------------------------
// Variables
//------------------------------------------------------------------------------

var datasetPropsDelimitedText = {
  columnDelimiter: ','
  compressionLevel: 'Optimal'
  escapeChar: '"'
  firstRowAsHeader: true
  quoteChar: '"'
}
var datasetPropsCommon = {
  location: {
    type: 'AzureBlobFSLocation'
    fileName: {
      value: '@{dataset().fileName}'
      type: 'Expression'
    }
    folderPath: {
      value: '@{dataset().folderName}'
      type: 'Expression'
    }
  }
}

var safeExportContainerName = replace('${exportContainerName}', '-', '_')
var safeIngestionContainerName = replace('${ingestionContainerName}', '-', '_')

// All hub triggers (used to auto-start)
var exportFileAddedTriggerName = '${safeExportContainerName}_FileAdded'
var allHubTriggers = [
  exportFileAddedTriggerName
]

// Roles needed to auto-start triggers
var autoStartRbacRoles = [
  '673868aa-7521-48a0-acc6-0f60742d39f5' // Data Factory contributor - https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#data-factory-contributor
  'e40ec5ca-96e0-45a2-b4ff-59039f2c2b59' // Managed Identity Contributor - https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#managed-identity-contributor
]

// FocusCost 1.0-preview (v1) columns
var focusCostColumns = [
  { name: 'AvailabilityZone', type: 'String' }
  { name: 'BilledCost', type: 'Decimal' }
  { name: 'BillingAccountId', type: 'String' }
  { name: 'BillingAccountName', type: 'String' }
  { name: 'BillingAccountType', type: 'String' }
  { name: 'BillingCurrency', type: 'String' }
  { name: 'BillingPeriodEnd', type: 'DateTime' }
  { name: 'BillingPeriodStart', type: 'DateTime' }
  { name: 'ChargeCategory', type: 'String' }
  { name: 'ChargeDescription', type: 'String' }
  { name: 'ChargeFrequency', type: 'String' }
  { name: 'ChargePeriodEnd', type: 'DateTime' }
  { name: 'ChargePeriodStart', type: 'DateTime' }
  { name: 'ChargeSubcategory', type: 'String' }
  { name: 'CommitmentDiscountCategory', type: 'String' }
  { name: 'CommitmentDiscountId', type: 'String' }
  { name: 'CommitmentDiscountName', type: 'String' }
  { name: 'CommitmentDiscountType', type: 'String' }
  { name: 'EffectiveCost', type: 'Decimal' }
  { name: 'InvoiceIssuerName', type: 'String' }
  { name: 'ListCost', type: 'Decimal' }
  { name: 'ListUnitPrice', type: 'Decimal' }
  { name: 'PricingCategory', type: 'String' }
  { name: 'PricingQuantity', type: 'Decimal' }
  { name: 'PricingUnit', type: 'String' }
  { name: 'ProviderName', type: 'String' }
  { name: 'PublisherName', type: 'String' }
  { name: 'Region', type: 'String' }
  { name: 'ResourceId', type: 'String' }
  { name: 'ResourceName', type: 'String' }
  { name: 'ResourceType', type: 'String' }
  { name: 'ServiceCategory', type: 'String' }
  { name: 'ServiceName', type: 'String' }
  { name: 'SkuId', type: 'String' }
  { name: 'SkuPriceId', type: 'String' }
  { name: 'SubAccountId', type: 'String' }
  { name: 'SubAccountName', type: 'String' }
  { name: 'SubAccountType', type: 'String' }
  { name: 'Tags', type: 'String' }
  { name: 'UsageQuantity', type: 'Decimal' }
  { name: 'UsageUnit', type: 'String' }
  { name: 'x_AccountName', type: 'String' }
  { name: 'x_AccountOwnerId', type: 'String' }
  { name: 'x_BilledCostInUsd', type: 'Decimal' }
  { name: 'x_BilledUnitPrice', type: 'Decimal' }
  { name: 'x_BillingAccountId', type: 'String' }
  { name: 'x_BillingAccountName', type: 'String' }
  { name: 'x_BillingExchangeRate', type: 'Decimal' }
  { name: 'x_BillingExchangeRateDate', type: 'DateTime' }
  { name: 'x_BillingProfileId', type: 'String' }
  { name: 'x_BillingProfileName', type: 'String' }
  { name: 'x_ChargeId', type: 'String' }
  { name: 'x_CostAllocationRuleName', type: 'String' }
  { name: 'x_CostCenter', type: 'String' }
  { name: 'x_CustomerId', type: 'String' }
  { name: 'x_CustomerName', type: 'String' }
  { name: 'x_EffectiveCostInUsd', type: 'Decimal' }
  { name: 'x_EffectiveUnitPrice', type: 'Decimal' }
  { name: 'x_InvoiceId', type: 'String' }
  { name: 'x_InvoiceIssuerId', type: 'String' }
  { name: 'x_InvoiceSectionId', type: 'String' }
  { name: 'x_InvoiceSectionName', type: 'String' }
  { name: 'x_OnDemandCost', type: 'Decimal' }
  { name: 'x_OnDemandCostInUsd', type: 'Decimal' }
  { name: 'x_OnDemandUnitPrice', type: 'Decimal' }
  { name: 'x_PartnerCreditApplied', type: 'Boolean' }
  { name: 'x_PartnerCreditRate', type: 'Decimal' }
  { name: 'x_PricingBlockSize', type: 'Decimal' }
  { name: 'x_PricingCurrency', type: 'String' }
  { name: 'x_PricingSubcategory', type: 'String' }
  { name: 'x_PricingUnitDescription', type: 'String' }
  { name: 'x_PublisherCategory', type: 'String' }
  { name: 'x_PublisherId', type: 'String' }
  { name: 'x_ResellerId', type: 'String' }
  { name: 'x_ResellerName', type: 'String' }
  { name: 'x_ResourceGroupName', type: 'String' }
  { name: 'x_ResourceType', type: 'String' }
  { name: 'x_ServicePeriodEnd', type: 'DateTime' }
  { name: 'x_ServicePeriodStart', type: 'DateTime' }
  { name: 'x_SkuDescription', type: 'String' }
  { name: 'x_SkuDetails', type: 'String' }
  { name: 'x_SkuIsCreditEligible', type: 'Boolean' }
  { name: 'x_SkuMeterCategory', type: 'String' }
  { name: 'x_SkuMeterId', type: 'String' }
  { name: 'x_SkuMeterName', type: 'String' }
  { name: 'x_SkuMeterSubcategory', type: 'String' }
  { name: 'x_SkuOfferId', type: 'String' }
  { name: 'x_SkuOrderId', type: 'String' }
  { name: 'x_SkuOrderName', type: 'String' }
  { name: 'x_SkuPartNumber', type: 'String' }
  { name: 'x_SkuRegion', type: 'String' }
  { name: 'x_SkuServiceFamily', type: 'String' }
  { name: 'x_SkuTerm', type: 'String' }
  { name: 'x_SkuTier', type: 'String' }
]
var focusCostMappings = [for i in range(0, length(focusCostColumns)): {
  source: { name: focusCostColumns[i].name, type: focusCostColumns[i].type }
  sink: { name: focusCostColumns[i].name }
}]

//==============================================================================
// Resources
//==============================================================================

// Get data factory instance
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

//------------------------------------------------------------------------------
// Delete old triggers and pipelines
//------------------------------------------------------------------------------

resource deleteOldResources 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${dataFactory.name}_deleteOldResources'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  kind: 'AzurePowerShell'
  dependsOn: [
    identityRoleAssignments
  ]
  tags: tags
  properties: {
    azPowerShellVersion: '8.0'
    retentionInterval: 'PT1H'
    cleanupPreference: 'OnSuccess'
    scriptContent: loadTextContent('./scripts/Remove-OldResources.ps1')
    environmentVariables: [
      {
        name: 'DataFactorySubscriptionId'
        value: subscription().id
      }
      {
        name: 'DataFactoryResourceGroup'
        value: resourceGroup().name
      }
      {
        name: 'DataFactoryName'
        value: dataFactory.name
      }
    ]
  }
}

//------------------------------------------------------------------------------
// Stop all triggers before deploying
//------------------------------------------------------------------------------

// Create managed identity to start/stop triggers
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${dataFactoryName}_triggerManager'
  location: location
  tags: union(tags, contains(tagsByResource, 'Microsoft.ManagedIdentity/userAssignedIdentities') ? tagsByResource['Microsoft.ManagedIdentity/userAssignedIdentities'] : {})
}

// Assign access to the identity
resource identityRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for role in autoStartRbacRoles: {
  name: guid(dataFactory.id, role, identity.id)
  scope: dataFactory
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}]

// Stop hub triggers if they're already running
resource stopHubTriggers 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${dataFactoryName}_stopHubTriggers'
  // chinaeast2 is the only region in China that supports deployment scripts
  location: startsWith(location, 'china') ? 'chinaeast2' : location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  kind: 'AzurePowerShell'
  dependsOn: [
    identityRoleAssignments
  ]
  tags: union(tags, contains(tagsByResource, 'Microsoft.Resources/deploymentScripts') ? tagsByResource['Microsoft.Resources/deploymentScripts'] : {})
  properties: {
    azPowerShellVersion: '8.0'
    retentionInterval: 'PT1H'
    cleanupPreference: 'OnSuccess'
    scriptContent: loadTextContent('./scripts/Start-Triggers.ps1')
    arguments: '-Stop'
    environmentVariables: [
      {
        name: 'DataFactorySubscriptionId'
        value: subscription().id
      }
      {
        name: 'DataFactoryResourceGroup'
        value: resourceGroup().name
      }
      {
        name: 'DataFactoryName'
        value: dataFactoryName
      }
      {
        name: 'Triggers'
        value: join(allHubTriggers, '|')
      }
    ]
  }
}

//------------------------------------------------------------------------------
// Linked services
//------------------------------------------------------------------------------

resource keyVault 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: keyVaultName
}

resource linkedService_keyVault 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'keyVault'
  parent: dataFactory
  properties: {
    annotations: []
    parameters: {}
    type: 'AzureKeyVault'
    typeProperties: {
      baseUrl: keyVault.properties.vaultUri
    }
  }
}

resource linkedService_storageAccount 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'storage'
  parent: dataFactory
  properties: {
    annotations: []
    parameters: {}
    type: 'AzureBlobFS'
    typeProperties: {
      url: storageAccount.properties.primaryEndpoints.dfs
      accountKey: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: linkedService_keyVault.name
          type: 'LinkedServiceReference'
        }
        secretName: storageAccountName
      }
    }
  }
}

//------------------------------------------------------------------------------
// Datasets
//------------------------------------------------------------------------------

resource dataset_msexports 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: safeExportContainerName
  parent: dataFactory
  dependsOn: [
    linkedService_keyVault
  ]
  properties: {
    annotations: []
    parameters: {
      fileName: {
        type: 'String'
      }
      folderName: {
        type: 'String'
      }
    }
    type: 'DelimitedText'
    typeProperties: union(datasetPropsCommon, datasetPropsDelimitedText, { compressionCodec: 'none' })
    linkedServiceName: {
      parameters: {}
      referenceName: linkedService_storageAccount.name
      type: 'LinkedServiceReference'
    }
  }
}

resource dataset_ingestion 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: safeIngestionContainerName
  parent: dataFactory
  dependsOn: [
    linkedService_keyVault
  ]
  properties: {
    annotations: []
    parameters: {
      fileName: {
        type: 'String'
      }
      folderName: {
        type: 'String'
      }
    }
    type: any(convertToParquet ? 'Parquet' : 'DelimitedText')
    typeProperties: union(
      datasetPropsCommon,
      convertToParquet ? {} : datasetPropsDelimitedText,
      { compressionCodec: 'gzip' }
    )
    linkedServiceName: {
      parameters: {}
      referenceName: linkedService_storageAccount.name
      type: 'LinkedServiceReference'
    }
  }
}

//------------------------------------------------------------------------------
// Export container extract pipeline + trigger
// Trigger: New CSV files in exportContainer
//
// Queues the transform pipeline.
// This pipeline must complete ASAP due to ADF's hard limit of 100 concurrent executions per pipeline.
// If multiple large, partitioned exports run concurrently and this pipeline doesn't finish quickly, the transform pipeline won't get triggered.
// Queuing up the transform pipeline and exiting immediately greatly reduces the likelihood of this happening.
//------------------------------------------------------------------------------

// Get storage account instance
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

// Create trigger
resource trigger_msexports_FileAdded 'Microsoft.DataFactory/factories/triggers@2018-06-01' = {
  name: exportFileAddedTriggerName
  parent: dataFactory
  dependsOn: [
    stopHubTriggers
    pipeline_ExecuteETL
  ]
  properties: {
    annotations: []
    pipelines: [
      {
        pipelineReference: {
          referenceName: '${exportContainerName}_ExecuteETL'
          type: 'PipelineReference'
        }
        parameters: {
          folderName: '@triggerBody().folderPath'
          fileName: '@triggerBody().fileName'
        }
      }
    ]
    type: 'BlobEventsTrigger'
    typeProperties: {
      blobPathBeginsWith: '/${exportContainerName}/blobs/'
      blobPathEndsWith: '.csv'
      ignoreEmptyBlobs: true
      scope: storageAccount.id
      events: [
        'Microsoft.Storage.BlobCreated'
      ]
    }
  }
}

resource pipeline_ExecuteETL 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${safeExportContainerName}_ExecuteETL'
  parent: dataFactory
  dependsOn: [
    pipeline_msexports_ETL_ingestion
  ]
  properties: {
    activities: [
      {
        name: 'Execute'
        type: 'ExecutePipeline'
        dependsOn: []
        userProperties: []
        typeProperties: {
          pipeline: {
            referenceName: '${safeExportContainerName}_ETL_${safeIngestionContainerName}'
            type: 'PipelineReference'
          }
          waitOnCompletion: false
          parameters: {
            folderName: {
              value: '@pipeline().parameters.folderName'
              type: 'Expression'
            }
            fileName: {
              value: '@pipeline().parameters.fileName'
              type: 'Expression'
            }
          }
        }
      }
    ]
    parameters: {
      folderName: {
        type: 'string'
      }
      fileName: {
        type: 'string'
      }
    }
    annotations: []
  }
}

//------------------------------------------------------------------------------
// Export container transform pipeline
// Trigger: pipeline_ExecuteETL
//
// Converts CSV files to Parquet or .CSV.GZ files.
//------------------------------------------------------------------------------

resource pipeline_msexports_ETL_ingestion 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${safeExportContainerName}_ETL_${safeIngestionContainerName}'
  parent: dataFactory
  dependsOn: [
    dataset_msexports
    dataset_ingestion
  ]
  properties: {
    activities: [
      // (start) -> Wait -> FolderArray -> Scope -> Metric -> Date -> File -> Folder -> Delete Target -> Convert CSV -> Delete CSV -> (end)
      // Wait
      {
        name: 'Wait'
        type: 'Wait'
        dependsOn: []
        userProperties: []
        typeProperties: {
          waitTimeInSeconds: 60
        }
      }
      // Set FolderArray
      {
        name: 'Set FolderArray'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Wait'
            dependencyConditions: [ 'Completed' ]
          }
        ]
        userProperties: []
        typeProperties: {
          variableName: 'folderArray'
          value: {
            value: '@split(pipeline().parameters.folderName, \'/\')'
            type: 'Expression'
          }
        }
      }
      // Set FolderCount
      {
        name: 'Set FolderCount'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Set FolderArray'
            dependencyConditions: [ 'Completed' ]
          }
        ]
        policy: {
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          variableName: 'folderCount'
          value: '@length(split(pipeline().parameters.folderName, \'/\'))'
        }
      }
      // Set SecondToLastFolder
      {
        name: 'Set SecondToLastFolder'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Set FolderCount'
            dependencyConditions: [ 'Completed' ]
          }
        ]
        policy: {
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          variableName: 'secondToLastFolder'
          value: '@variables(\'folderArray\')[sub(variables(\'folderCount\'), 2)]'
        }
      }
      // Set ThirdToLastFolder
      {
        name: 'Set ThirdToLastFolder'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Set SecondToLastFolder'
            dependencyConditions: [ 'Succeeded' ]
          }
        ]
        policy: {
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          variableName: 'thirdToLastFolder'
          value: '@variables(\'folderArray\')[sub(variables(\'folderCount\'), 3)]'
        }
      }
      // Set FourthToLastFolder
      {
        name: 'Set FourthToLastFolder'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Set ThirdToLastFolder'
            dependencyConditions: [ 'Succeeded' ]
          }
        ]
        policy: {
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          variableName: 'fourthToLastFolder'
          value: '@variables(\'folderArray\')[sub(variables(\'folderCount\'), 4)]'
        }
      }
      // Set Scope
      {
        name: 'Set Scope'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Set FourthToLastFolder'
            dependencyConditions: [ 'Completed' ]
          }
        ]
        userProperties: []
        typeProperties: {
          variableName: 'scope'
          value: {
            value: '@replace(split(pipeline().parameters.folderName, if(greater(length(variables(\'secondToLastFolder\')), 12), variables(\'thirdToLastFolder\'), variables(\'fourthToLastFolder\')))[0], \'${exportContainerName}\', \'${ingestionContainerName}\')'
            type: 'Expression'
          }
        }
      }
      // Set Metric
      {
        name: 'Set Metric'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Set Scope'
            dependencyConditions: [ 'Completed' ]
          }
        ]
        userProperties: []
        typeProperties: {
          variableName: 'metric'
          value: {
            // TODO: Parse metric out of the manifest file @ msexports/<scope>/<export-name>/<date-range>/[<timestamp?>/]<guid>/manifest.json
            value: 'focuscost'
            type: 'Expression'
          }
        }
      }
      // Set Date
      {
        name: 'Set Date'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Set Metric'
            dependencyConditions: [ 'Completed' ]
          }
        ]
        userProperties: []
        typeProperties: {
          variableName: 'date'
          value: {
            value: '@substring(if(greater(length(variables(\'secondToLastFolder\')), 12), variables(\'secondToLastFolder\'), variables(\'thirdToLastFolder\')), 0, 6)'
            type: 'Expression'
          }
        }
      }
      // Set Destination File Name
      {
        name: 'Set Destination File Name'
        description: ''
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Set Date'
            dependencyConditions: [ 'Completed' ]
          }
        ]
        userProperties: []
        typeProperties: {
          variableName: 'destinationFile'
          value: {
            value: '@replace(pipeline().parameters.fileName, \'.csv\', \'${convertToParquet ? '.parquet' : '.csv.gz'}\')'
            type: 'Expression'
          }
        }
      }
      // Set Destination Folder Name
      {
        name: 'Set Destination Folder Name'
        type: 'SetVariable'
        dependsOn: [
          {
            activity: 'Set Destination File Name'
            dependencyConditions: [ 'Completed' ]
          }
        ]
        userProperties: []
        typeProperties: {
          variableName: 'destinationFolder'
          value: {
            value: '@replace(concat(variables(\'scope\'),variables(\'date\'),\'/\',variables(\'metric\')),\'//\',\'/\')'
            type: 'Expression'
          }
        }
      }
      // Delete Target
      {
        name: 'Delete Target'
        type: 'Delete'
        dependsOn: [
          {
            activity: 'Set Destination Folder Name'
            dependencyConditions: [ 'Completed' ]
          }
        ]
        policy: {
          timeout: '0.12:00:00'
          retry: 0
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          dataset: {
            referenceName: safeIngestionContainerName
            type: 'DatasetReference'
            parameters: {
              folderName: {
                value: '@variables(\'destinationFolder\')'
                type: 'Expression'
              }
              fileName: {
                value: '@variables(\'destinationFile\')'
                type: 'Expression'
              }
            }
          }
          enableLogging: false
          storeSettings: {
            type: 'AzureBlobFSReadSettings'
            recursive: true
            enablePartitionDiscovery: false
          }
        }
      }
      // Convert CSV
      {
        name: 'Convert CSV'
        type: 'Copy'
        dependsOn: [
          {
            activity: 'Delete Target'
            dependencyConditions: [ 'Completed' ]
          }
        ]
        policy: {
          timeout: '0.12:00:00'
          retry: 0
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          source: {
            type: 'DelimitedTextSource'
            storeSettings: {
              type: 'AzureBlobFSReadSettings'
              recursive: true
              enablePartitionDiscovery: false
            }
            formatSettings: {
              type: 'DelimitedTextReadSettings'
            }
          }
          sink: {
            type: 'DelimitedTextSink'
            storeSettings: {
              type: 'AzureBlobFSWriteSettings'
            }
            formatSettings: convertToParquet ? {
              type: 'ParquetWriteSettings'
              fileExtension: '.parquet'
            } : {
              type: 'DelimitedTextWriteSettings'
              quoteAllText: true
              fileExtension: '.csv.gz'
            }
          }
          enableStaging: false
          parallelCopies: 1
          validateDataConsistency: false
          translator: {
            type: 'TabularTranslator'
            mappings: focusCostMappings
          }
        }
        inputs: [
          {
            referenceName: safeExportContainerName
            type: 'DatasetReference'
            parameters: {
              folderName: {
                value: '@pipeline().parameters.folderName'
                type: 'Expression'
              }
              fileName: {
                value: '@pipeline().parameters.fileName'
                type: 'Expression'
              }
            }
          }
        ]
        outputs: [
          {
            referenceName: safeIngestionContainerName
            type: 'DatasetReference'
            parameters: {
              folderName: {
                value: '@variables(\'destinationFolder\')'
                type: 'Expression'
              }
              fileName: {
                value: '@variables(\'destinationFile\')'
                type: 'Expression'
              }
            }
          }
        ]
      }
      // Delete CSV
      {
        name: 'Delete CSV'
        type: 'Delete'
        dependsOn: [
          {
            activity: 'Convert CSV'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        policy: {
          timeout: '0.12:00:00'
          retry: 0
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          dataset: {
            referenceName: safeExportContainerName
            type: 'DatasetReference'
            parameters: {
              folderName: {
                value: '@pipeline().parameters.folderName'
                type: 'Expression'
              }
              fileName: {
                value: '@pipeline().parameters.fileName'
                type: 'Expression'
              }
            }
          }
          enableLogging: false
          storeSettings: {
            type: 'AzureBlobFSReadSettings'
            recursive: true
            enablePartitionDiscovery: false
          }
        }
      }
    ]
    parameters: {
      fileName: {
        type: 'string'
      }
      folderName: {
        type: 'string'
      }
    }
    variables: {
      destinationFile: {
        type: 'String'
      }
      destinationFolder: {
        type: 'String'
      }
      folderArray: {
        type: 'Array'
      }
      folderCount: {
        type: 'Integer'
      }
      secondToLastFolder: {
        type: 'String'
      }
      thirdToLastFolder: {
        type: 'String'
      }
      fourthToLastFolder: {
        type: 'String'
      }
      scope: {
        type: 'String'
      }
      date: {
        type: 'String'
      }
      metric: {
        type: 'String'
      }
    }
    annotations: []
  }
}

//------------------------------------------------------------------------------
// Start all triggers
//------------------------------------------------------------------------------

// Start hub triggers
resource startHubTriggers 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${dataFactoryName}_startHubTriggers'
  // chinaeast2 is the only region in China that supports deployment scripts
  location: startsWith(location, 'china') ? 'chinaeast2' : location
  tags: union(tags, contains(tagsByResource, 'Microsoft.Resources/deploymentScripts') ? tagsByResource['Microsoft.Resources/deploymentScripts'] : {})
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  kind: 'AzurePowerShell'
  dependsOn: [
    identityRoleAssignments
    trigger_msexports_FileAdded
  ]
  properties: {
    azPowerShellVersion: '8.0'
    retentionInterval: 'PT1H'
    cleanupPreference: 'OnSuccess'
    scriptContent: loadTextContent('./scripts/Start-Triggers.ps1')
    environmentVariables: [
      {
        name: 'DataFactorySubscriptionId'
        value: subscription().id
      }
      {
        name: 'DataFactoryResourceGroup'
        value: resourceGroup().name
      }
      {
        name: 'DataFactoryName'
        value: dataFactoryName
      }
      {
        name: 'Triggers'
        value: join(allHubTriggers, '|')
      }
    ]
  }
}

//==============================================================================
// Outputs
//==============================================================================

@description('The Resource ID of the Data factory.')
output resourceId string = dataFactory.id

@description('The Name of the Azure Data Factory instance.')
output name string = dataFactory.name
