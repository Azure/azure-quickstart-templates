targetScope = 'subscription'

// PARAMETERS
param dcrResourceID string

// VARIABLES
var policyDefCategory = 'Custom'
var policySource = 'Bicep'
var vmExtensionName = 'AzureMonitorWindowsAgent'
var vmExtensionPublisher = 'Microsoft.Azure.Monitor'
var vmExtensionType = 'AzureMonitorWindowsAgent'
var vmExtensionTypeHandlerVersion = '1.0'
var dcrAssociationName = 'association1'

// OUTPUTS
output monitoringGovernanceId string = monitoringGovernance.id

// RESOURCES
resource deployAzureMonitorAgentWindowsDCR 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: 'deployAzureMonitorAgentWindowsDCR'
  properties: {
    displayName: 'Deploy new Azure Monitor Agent to Windows VMs and tie to DCR'
    policyType: 'Custom'
    mode: 'All'
    description: 'Deploy new Azure Monitor Agent to Windows VMs and tie to DCR'
    metadata: {
      category: policyDefCategory
      source: policySource
      version: '0.1.0'
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Compute/virtualMachines'
          }
          {
            anyOf: [
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftWindowsServer'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'WindowsServer'
                  }
                  {
                    field: 'Microsoft.Compute/imageSKU'
                    in: [
                      '2008-R2-SP1'
                      '2008-R2-SP1-smalldisk'
                      '2012-Datacenter'
                      '2012-Datacenter-smalldisk'
                      '2012-R2-Datacenter'
                      '2012-R2-Datacenter-smalldisk'
                      '2016-Datacenter'
                      '2016-Datacenter-Server-Core'
                      '2016-Datacenter-Server-Core-smalldisk'
                      '2016-Datacenter-smalldisk'
                      '2016-Datacenter-with-Containers'
                      '2016-Datacenter-with-RDSH'
                      '2019-Datacenter'
                      '2019-Datacenter-Core'
                      '2019-Datacenter-Core-smalldisk'
                      '2019-Datacenter-Core-with-Containers'
                      '2019-Datacenter-Core-with-Containers-smalldisk'
                      '2019-Datacenter-smalldisk'
                      '2019-Datacenter-with-Containers'
                      '2019-Datacenter-with-Containers-smalldisk'
                      '2019-Datacenter-zhcn'
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftWindowsServer'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'WindowsServerSemiAnnual'
                  }
                  {
                    field: 'Microsoft.Compute/imageSKU'
                    in: [
                      'Datacenter-Core-1709-smalldisk'
                      'Datacenter-Core-1709-with-Containers-smalldisk'
                      'Datacenter-Core-1803-with-Containers-smalldisk'
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftWindowsServerHPCPack'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'WindowsServerHPCPack'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftSQLServer'
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2016'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2016-BYOL'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2012R2'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2012R2-BYOL'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftRServer'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: ' MLServer-WS2016'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftVisualStudio'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'VisualStudio'
                      'Windows'
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftDynamicsAX'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'Dynamics'
                  }
                  {
                    field: 'Microsoft.Compute/imageSKU'
                    equals: 'Pre-Req-AX7-Onebox-U8'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'microsoft-ads'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'windows-data-science-vm'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftWindowsDesktop'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'Windows-10'
                  }
                ]
              }
            ]
          }
        ]
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/dataCollectionRuleAssociations'
          name: dcrAssociationName
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c' // contributor RBAC role for deployIfNotExists effect
          ]
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/type'
                equals: 'AzureMonitorWindowsAgent'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/publisher'
                equals: 'Microsoft.Azure.Monitor'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/provisioningState'
                equals: 'Succeeded'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  resourceName: {
                    type: 'String'
                    metadata: {
                      displayName: 'resourceName'
                      description: 'Name of the resource'
                    }
                  }
                  resourcelocation: {
                    type: 'String'
                    metadata: {
                      displayName: 'resourceLocation'
                      description: 'Location of the resource'
                    }
                  }
                  DCRResourceID: {
                    type: 'String'
                    metadata: {
                      displayName: 'DCRResourceID'
                      description: 'Resource ID of the Data Collection Rule'
                    }
                  }
                }
                resources: [
                  {
                    name: '[concat(parameters(\'resourceName\'), \'/${vmExtensionName}\')]'
                    type: 'Microsoft.Compute/virtualMachines/extensions'
                    location: '[parameters(\'resourceLocation\')]'
                    apiVersion: '2018-06-01'
                    properties: {
                      publisher: vmExtensionPublisher
                      type: vmExtensionType
                      typeHandlerVersion: vmExtensionTypeHandlerVersion
                      autoUpgradeMinorVersion: 'true'
                    }
                  }
                  {
                    name: '[concat(parameters(\'resourceName\'), \'/Microsoft.Insights/${dcrAssociationName}\')]'
                    type: 'Microsoft.Compute/virtualMachines/providers/dataCollectionRuleAssociations'
                    location: '[parameters(\'resourceLocation\')]'
                    apiVersion: '2019-11-01-preview'
                    properties: {
                      dataCollectionRuleId: '[parameters(\'DCRResourceID\')]'
                    }
                  }
                ]
              }
              parameters: {
                resourceName: {
                  value: '[field(\'name\')]'
                }
                resourceLocation: {
                  value: '[field(\'location\')]'
                }
                DCRResourceID: {
                  value: dcrResourceID
                }
              }
            }
          }
        }
      }
    }
  }
}

resource monitoringGovernance 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: 'monitoringGovernance'
  properties: {
    policyType: 'Custom'
    displayName: 'Monitoring Governance Initiative'
    description: 'Monitoring Governance Initiative'
    metadata: {
      category: policyDefCategory
      source: policySource
      version: '0.1.0'
    }
    parameters: {}
    policyDefinitions: [
      {
        policyDefinitionId: deployAzureMonitorAgentWindowsDCR.id
        parameters: {}
      }
    ]
  }
}
