param location string = resourceGroup().location
param tenantId string = subscription().tenantId

@description('First must pass Validate prior running Deploy')
@allowed([
  'Validate'
  'Deploy'
])
param deploymentMode string = 'Validate'

@description('The prefix for the resource for the deployment')
@minLength(6)
@maxLength(10)
param deploymentPrefix string

// credentials for the deployment and ongoing lifecycle management
@description('The deployment username for the deployment - this is the user created in Active Directory by the preparation script')
param deploymentUsername string

@description('The deployment password for the deployment - this is for the user created in Active Directory by the preparation script')
@secure()
param deploymentUserPassword string

@description('The local admin username for the deployment - this is the local admin user for the nodes in the deployment')
param localAdminUser string

@description('The local admin password for the deployment - this is the local admin user for the nodes in the deployment')
@secure()
param localAdminPassword string

@description('The application ID of the pre-created App Registration for the Arc Resource Bridge deployment')
param arbDeploymentSpnAppId string

@description('A client secret of the pre-created App Registration for the Arc Resource Bridge deployment')
@secure()
param arbDeploymentSpnPassword string

@description('Entra ID object ID of the Azure Stack HCI Resource Provider in your tenant')
param hciResourceProviderObjectId string

// cluster and active directory settings
@description('The name of the Azure Stack HCI cluster - this name is specified in the Active Directory preparation script')
param clusterName string

@description('Names of the cluster node Arc Machine resources - ex "hci-node-1, hci-node-2"')
param clusterNodeNames array

@description('The domain name of the Active Directory Domain Services - ex "contoso.com"')
param domainFqdn string

@description('The ADDS OU path - ex "OU=HCI,DC=contoso,DC=com"')
param domainOUPath string

// retention policy for the Azure Key Vault and Key Vault diagnostics
param softDeleteRetentionDays int = 30

@description('Specifies the number of days that logs will be kept. If you do not want to apply any retention policy and retain data forever, set value to 0.')
@minValue(0)
@maxValue(365)
param logsRetentionInDays int = 30

// cluster security configuration settings
@description('Security configuration settings object')
param securityConfiguration object = {
  hvciProtection: true
  drtmProtection: true
  driftControlEnforced: true
  credentialGuardEnforced: true
  smbSigningEnforced: true
  smbClusterEncryption: true
  sideChannelMitigationEnforced: true
  bitlockerBootVolume: true
  bitlockerDataVolumes: true
  wdacEnforced: true
}

// cluster diagnostics and telemetry configuration
@description('The metrics data for deploying a hci cluster')
param streamingDataClient bool = true

@description('The location data for deploying a hci cluster')
param isEuropeanUnionLocation bool = false

@description('The diagnostic data for deploying a hci cluster')
param episodicDataUpload bool = true

// storage configuration
@description('The storage volume configuration mode')
@allowed([
  'Express'
  'InfraOnly'
  'KeepStorage'
])
param storageConfigurationMode string = 'Express'

// cluster network configuration details
@description('The subnet mask for deploying a hci cluster')
param subnetMask string

@description('The default gateway for deploying a hci cluster')
param defaultGateway string

@description('The starting ip address for deploying a hci cluster')
param startingIPAddress string

@description('The ending ip address for deploying a hci cluster')
param endingIPAddress string

@description('The dns servers for deploying a hci cluster')
param dnsServers array

// define network intent for the cluster
@description('The storage connectivity switchless value for deploying a hci cluster')
param storageConnectivitySwitchless bool

type storageNetworksType = {
  adapterName: string
  vlan: string
}

param storageNetworks [storageNetworksType]

param computeIntentAdapterNames array

param managementIntentAdapterNames array

// create base64 encoded secret values to be stored in the Azure Key Vault
var deploymentUserSecretValue = base64('${deploymentUsername}:${deploymentUserPassword}')
var localAdminSecretValue = base64('${localAdminUser}:${localAdminPassword}')
var arbDeploymentSpnValue = base64('${arbDeploymentSpnAppId}:${arbDeploymentSpnPassword}')

// secret names for the Azure Key Vault - these cannot be changed
var localAdminSecretName = 'LocalAdminCredential'
var domainAdminSecretName = 'AzureStackLCMUserCredential'
var arbDeploymentSpnName = 'DefaultARBApplication'
var storageWitnessName = 'WitnessStorageKey'

var storageAccountType = 'Standard_LRS'

var clusterWitnessStorageAccountName = '${deploymentPrefix}witness'
var diagnosticStorageAccountName = '${deploymentPrefix}diag'

var keyVaultName = '${deploymentPrefix}-hcikv'
var customLocationName = '${deploymentPrefix}_cl'

var azureConnectedMachineResourceManagerRoleID = '/providers/Microsoft.Authorization/roleDefinitions/f5819b54-e033-4d82-ac66-4fec3cbf3f4c'
var readerRoleID = '/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7'
var azureStackHCIDeviceManagementRole = '/providers/Microsoft.Authorization/roleDefinitions/865ae368-6a45-4bd1-8fbf-0d5151f56fc1'
var roleDefinitionResourceId = '/providers/Microsoft.Authorization/roleDefinitions/4633458b-17de-408a-b874-0445c86b69e6'

var storageNetworkList = [for (storageAdapter, index) in storageNetworks:{
    name: 'StorageNetwork${index + 1}'
    networkAdapterName: storageAdapter.adapterName
    vlanId: storageAdapter.vlan
  }
]

var arcNodeResourceIds = [for (nodeName, index) in clusterNodeNames:{
    resourceId: resourceId('Microsoft.HybridCompute/machines', nodeName)
  }
]

resource diagnosticStorageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: diagnosticStorageAccountName
  location: location
  sku: {
    name: storageAccountType
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

resource witnessStorageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: clusterWitnessStorageAccountName
  location: location
  sku: {
    name: storageAccountType
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enableSoftDelete: true
    softDeleteRetentionInDays: softDeleteRetentionDays
    enableRbacAuthorization: true
    publicNetworkAccess: 'Enabled'
    accessPolicies: []
    tenantId: tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
  dependsOn: [
    diagnosticStorageAccount
  ]
}

resource keyVaultName_Microsoft_Insights_service 'Microsoft.Insights/diagnosticsettings@2016-09-01' = {
  name: 'service'
  location: location
  scope: keyVault
  properties: {
    storageAccountId: diagnosticStorageAccount.id
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionInDays
        }
      }
    ]
  }
}

resource SPConnectedMachineResourceManagerRolePermissions 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('ConnectedMachineResourceManagerRolePermissions',resourceGroup().id)
  scope: resourceGroup()
  properties:  {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/f5819b54-e033-4d82-ac66-4fec3cbf3f4c'
    principalId: hciResourceProviderObjectId
    principalType: 'ServicePrincipal'
  }
}

resource NodeAzureConnectedMachineResourceManagerRolePermissions 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for hciNode in arcNodeResourceIds:{
  name: guid(hciNode.resourceId, azureConnectedMachineResourceManagerRoleID)
  properties:  {
    roleDefinitionId: azureConnectedMachineResourceManagerRoleID
    principalId: reference(hciNode.resourceId,'2023-10-03-preview','Full').identity.principalId
    principalType: 'ServicePrincipal'
  }
}
]
resource NodeazureStackHCIDeviceManagementRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for hciNode in arcNodeResourceIds:{
  name: guid(hciNode.resourceId, azureStackHCIDeviceManagementRole)
  properties:  {
    roleDefinitionId: azureStackHCIDeviceManagementRole
    principalId: reference(hciNode.resourceId,'2023-10-03-preview','Full').identity.principalId
    principalType: 'ServicePrincipal'
  }
}
]

resource NodereaderRoleIDPermissions 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for hciNode in arcNodeResourceIds:{
  name: guid(hciNode.resourceId, readerRoleID)
  properties:  {
    roleDefinitionId: readerRoleID
    principalId: reference(hciNode.resourceId,'2023-10-03-preview','Full').identity.principalId
    principalType: 'ServicePrincipal'
  }
}
]

resource KeyVaultSecretsUserPermissions 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for hciNode in arcNodeResourceIds:{
  name: guid(hciNode.resourceId, roleDefinitionResourceId)
  scope: keyVault
  properties:  {
    roleDefinitionId: roleDefinitionResourceId
    principalId: reference(hciNode.resourceId,'2023-10-03-preview','Full').identity.principalId
    principalType: 'ServicePrincipal'
  }
}
]

resource cluster 'Microsoft.AzureStackHCI/clusters@2023-08-01-preview' = if (deploymentMode == 'Validate') {
  name: clusterName
  identity: {
    type: 'SystemAssigned'
  }
  location: location
  properties: {}
  dependsOn: [
    KeyVaultSecretsUserPermissions
  ]
}

resource keyVaultName_domainAdminSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: domainAdminSecretName
  properties: {
    contentType: 'Secret'
    value: deploymentUserSecretValue
    attributes: {
      enabled: true
    }
  }
}

resource keyVaultName_localAdminSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: localAdminSecretName
  properties: {
    contentType: 'Secret'
    value: localAdminSecretValue
    attributes: {
      enabled: true
    }
  }
}

resource keyVaultName_arbDeploymentSpn 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: arbDeploymentSpnName
  properties: {
    contentType: 'Secret'
    value: arbDeploymentSpnValue
    attributes: {
      enabled: true
    }
  }
}

resource keyVaultName_storageWitness 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: storageWitnessName
  properties: {
    contentType: 'Secret'
    value: base64(witnessStorageAccount.listKeys().keys[0].value)
    attributes: {
      enabled: true
    }
  }
}

resource clusterName_default 'microsoft.azurestackhci/clusters/deploymentSettings@2023-08-01-preview' = {
  name: 'default'
  parent: cluster
  properties: {
    arcNodeResourceIds: arcNodeResourceIds
    deploymentMode: deploymentMode
    deploymentConfiguration: {
      version: '10.0.0.0'
      scaleUnits: [
        {
          deploymentData: {
            securitySettings: {
              hvciProtection: true
              drtmProtection: true
              driftControlEnforced: securityConfiguration.driftControlEnforced
              credentialGuardEnforced: securityConfiguration.credentialGuardEnforced
              smbSigningEnforced: securityConfiguration.smbSigningEnforced
              smbClusterEncryption: securityConfiguration.smbClusterEncryption
              sideChannelMitigationEnforced: true
              bitlockerBootVolume: securityConfiguration.bitlockerBootVolume
              bitlockerDataVolumes: securityConfiguration.bitlockerDataVolumes
              wdacEnforced: securityConfiguration.wdacEnforced
            }
            observability: {
              streamingDataClient: streamingDataClient
              euLocation: isEuropeanUnionLocation
              episodicDataUpload: episodicDataUpload
            }
            cluster: {
              name: clusterName
              witnessType: 'Cloud'
              witnessPath: ''
              cloudAccountName: clusterWitnessStorageAccountName
              azureServiceEndpoint: environment().suffixes.storage
            }
            storage: {
              configurationMode: storageConfigurationMode
            }
            namingPrefix: deploymentPrefix
            domainFqdn: domainFqdn
            infrastructureNetwork: [
              {
                subnetMask: subnetMask
                gateway: defaultGateway
                ipPools: [
                  {
                    startingAddress: startingIPAddress
                    endingAddress: endingIPAddress
                  }
                ]
                dnsServers: dnsServers
              }
            ]
            physicalNodes: [for hciNode in arcNodeResourceIds: {
              name: reference(hciNode.resourceId,'2023-10-03-preview','Full').properties.displayName
              ipv4Address: reference(hciNode.resourceId,'2023-10-03-preview','Full').properties.networkProfile.networkInterfaces[0].ipAddresses[0].address
            }
            ]
            hostNetwork: {
              enableStorageAutoIp: true
              intents: [
                {
                  adapter: managementIntentAdapterNames
                  name: 'managment'
                  // overrideAdapterProperty: false
                  // adapterPropertyOverrides: {
                  //   jumboPacket: '9014'
                  //   networkDirect: 'Enabled'
                  //   networkDirectTechnology: 'RoCEv2'
                  // }
                  // overrideQosPolicy: false
                  // qosPolicyOverrides: {
                  //   bandwidthPercentage_SMB: '50'
                  //   priorityValue8021Action_Cluster: '7'
                  //   priorityValue8021Action_SMB: '3'
                  //   }
                  // overrideVirtualSwitchConfiguration: false
                  // virtualSwitchConfigurationOverrides: {
                  //   enableIov: ''
                  //   loadBalancingAlgorithm: ''
                  // }
                  trafficType: [
                    'Management'
                  ]
                }
                {
                  adapter: computeIntentAdapterNames
                  name: 'compute'
                  // overrideAdapterProperty: false
                  // adapterPropertyOverrides: {
                  //   jumboPacket: '9014'
                  //   networkDirect: 'Enabled'
                  //   networkDirectTechnology: 'RoCEv2'
                  // }
                  // overrideQosPolicy: false
                  // qosPolicyOverrides: {
                  //   bandwidthPercentage_SMB: '50'
                  //   priorityValue8021Action_Cluster: '7'
                  //   priorityValue8021Action_SMB: '3'
                  //   }
                  // overrideVirtualSwitchConfiguration: false
                  // virtualSwitchConfigurationOverrides: {
                  //   enableIov: ''
                  //   loadBalancingAlgorithm: 'Dynamic'
                  // }
                  trafficType: [
                    'Compute'
                  ]
                }
                {
                  adapter: [for storageNetwork in storageNetworks: storageNetwork.adapterName]
                  name: 'storage'
                  overrideAdapterProperty: false
                  adapterPropertyOverrides: {
                    jumboPacket: '9014'
                    networkDirect: 'Enabled'
                    networkDirectTechnology: 'RoCEv2'
                  }
                  overrideQosPolicy: false
                  qosPolicyOverrides: {
                    bandwidthPercentage_SMB: '50'
                    priorityValue8021Action_Cluster: '7'
                    priorityValue8021Action_SMB: '3'
                    }
                  overrideVirtualSwitchConfiguration: false
                  virtualSwitchConfigurationOverrides: {
                    enableIov: ''
                    loadBalancingAlgorithm: ''
                  }
                  trafficType: [
                    'Storage'
                  ]
                }
              ]
              storageConnectivitySwitchless: storageConnectivitySwitchless
              storageNetworks: storageNetworkList
            }
            adouPath: domainOUPath
            secretsLocation: keyVault.properties.vaultUri
            optionalServices: {
              customLocation: customLocationName
            }
          }
        }
      ]
    }
  }
}
