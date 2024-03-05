@description('First must pass Validate prior running Deploy')
@allowed([
  'Validate'
  'Deploy'
])
param deploymentMode string

@description('The deployment username for the deployment')
param deploymentusername string

@description('The deployment password for the deployment')
@secure()
param deploymentuserpassword string

var deploymentUserSecretValue = base64('${deploymentusername}:${deploymentuserpassword}')

@description('The local admin username for the deployment')
param localadminuser string

@description('The local admin password for the deployment')
@secure()
param localuserpassword string

var localAdminSecretValue = base64('${localadminuser}:${localuserpassword}')
@description('The prefix for the resource for the deployment')
param deploymentprefix string

var keyVaultName = '${deploymentprefix}-hcikv'
param softDeleteRetentionDays int = 30

var diagnosticStorageAccountName = '${deploymentprefix}diag'


@description('Specifies the number of days that logs are gonna be kept. If you do not want to apply any retention policy and retain data forever, set value to 0.')
@minValue(0)
@maxValue(365)
param logsRetentionInDays int = 30

@description('Storage Account type')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param storageAccountType string = 'Standard_LRS'

var ClusterWitnessStorageAccountName = '${deploymentprefix}witness'

@description('Specifies the number of days that logs are gonna be kept. If you do not want to apply any retention policy and retain data forever, set value to 0.')
param clusterName string

param location string = resourceGroup().location
param tenantId string = subscription().tenantId

@description('The name can not be changed')
@allowed([
  'LocalAdminCredential'
])
param localAdminSecretName string = 'LocalAdminCredential'

@description('The name can not be changed')
@allowed([
  'AzureStackLCMUserCredential'
])
param domainAdminSecretName string = 'AzureStackLCMUserCredential'

@description('The name can not be changed')
@allowed([
  'DefaultARBApplication'
])
param arbDeploymentSpnName string = 'DefaultARBApplication'

@description('The deployment username for the deployment')
param arbDeploymentSpnAppId string

@description('The deployment password for the deployment')
@secure()
param arbDeploymentSpnPassword string

var arbDeploymentSpnValue = base64('${arbDeploymentSpnAppId}:${arbDeploymentSpnPassword}')

@description('The name can not be changed')
@allowed([
  'WitnessStorageKey'
])
param storageWitnessName string = 'WitnessStorageKey'

@description('The domain name of the Active Directory Domain Services')
param domainFqdn string


@description('The ADDS OU path')
param adouPath string

@description('The security setting driftControlEnforced data for deploying a hci cluster')
@allowed([
  true
  false
])
param driftControlEnforced bool

@description('The security setting credentialGuardEnforced data for deploying a hci cluster')
@allowed([
  true
  false
])
param credentialGuardEnforced bool

@description('The security setting smbSigningEnforced data for deploying a hci cluster')
@allowed([
  true
  false
])
param smbSigningEnforced bool

@description('The security setting smbClusterEncryption data for deploying a hci cluster')
@allowed([
  true
  false
])
param smbClusterEncryption bool

@description('The security setting bitlockerBootVolume data for deploying a hci cluster')
@allowed([
  true
  false
])
param bitlockerBootVolume bool

@description('The security setting bitlockerDataVolumes data for deploying a hci cluster')
@allowed([
  true
  false
])
param bitlockerDataVolumes bool

@description('The security setting wdacEnforced data for deploying a hci cluster')
@allowed([
  true
  false
])
param wdacEnforced bool

@description('The metrics data for deploying a hci cluster')
@allowed([
  true
  false
])
param streamingDataClient bool = true

@description('The location data for deploying a hci cluster')
@allowed([
  true
  false
])
param euLocation bool = false

@description('The diagnostic data for deploying a hci cluster')
@allowed([
  true
  false
])
param episodicDataUpload bool = true

@description('The storage volume configuration mode')
@allowed([
  'Express'
  'InfraOnly'
  'KeepStorage'
])
param configurationMode string

@description('The subnet mask for deploying a hci cluster')
param subnetMask string

@description('The default gateway for deploying a hci cluster')
param defaultGateway string


param roleDefinitionResourceId string = '/providers/Microsoft.Authorization/roleDefinitions/4633458b-17de-408a-b874-0445c86b69e6'

@description('The starting ip address for deploying a hci cluster')
param startingIPAddress string

@description('The ending ip address for deploying a hci cluster')
param endingIPAddress string

@description('The dns servers for deploying a hci cluster')
param dnsServers array

param computeAdapters array

param mgmtAdapters array

param storageAdapters array

var storageNetworkList = [for (storageAdapter, index) in storageAdapters:{
  name: 'StorageNetwork${index + 1}'
  networkAdapterName: '${storageAdapter.adapter}'
  vlanId: '${storageAdapter.vlan}'
}
]

@description('The storage connectivity switchless value for deploying a hci cluster')
param storageConnectivitySwitchless bool

var customLocation = '${deploymentprefix}_cl'

@description('The Arc for Server Node Resoure Ids')
param arcNodeResourceIds array

var AzureConnectedMachineResourceManagerRoleID = '/providers/Microsoft.Authorization/roleDefinitions/f5819b54-e033-4d82-ac66-4fec3cbf3f4c'
var ReaderRoleID = '/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7'
var AzureStackHCIDeviceManagementRole = '/providers/Microsoft.Authorization/roleDefinitions/865ae368-6a45-4bd1-8fbf-0d5151f56fc1'

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
  name: ClusterWitnessStorageAccountName
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

resource keyVaultName_Microsoft_Insights_service 'Microsoft.KeyVault/vaults/providers/diagnosticsettings@2016-09-01' = {
  name: '${keyVaultName}/Microsoft.Insights/service'
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
  dependsOn: [
    keyVault
  ]
}

resource SPConnectedMachineResourceManagerRolePermissions 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('ConnectedMachineResourceManagerRolePermissions',resourceGroup().id)
  scope: resourceGroup()
  properties:  {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/f5819b54-e033-4d82-ac66-4fec3cbf3f4c'
    principalId: 'ceeba60a-c19b-41b0-b437-737c0b76d3ec'
    principalType: 'ServicePrincipal'
  }
}

resource NodeAzureConnectedMachineResourceManagerRolePermissions 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for hciNode in arcNodeResourceIds:{
  name: guid(hciNode, AzureConnectedMachineResourceManagerRoleID)
  properties:  {
    roleDefinitionId: AzureConnectedMachineResourceManagerRoleID
    principalId: reference(hciNode,'2023-10-03-preview','Full').identity.principalId
    principalType: 'ServicePrincipal'
  }
}
]
resource NodeAzureStackHCIDeviceManagementRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for hciNode in arcNodeResourceIds:{
  name: guid(hciNode, AzureStackHCIDeviceManagementRole)
  properties:  {
    roleDefinitionId: AzureStackHCIDeviceManagementRole
    principalId: reference(hciNode,'2023-10-03-preview','Full').identity.principalId
    principalType: 'ServicePrincipal'
  }
}
]

resource NodeReaderRoleIDPermissions 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for hciNode in arcNodeResourceIds:{
  name: guid(hciNode, ReaderRoleID)
  properties:  {
    roleDefinitionId: ReaderRoleID
    principalId: reference(hciNode,'2023-10-03-preview','Full').identity.principalId
    principalType: 'ServicePrincipal'
  }
}
]

resource KeyVaultSecretsUserPermissions 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for hciNode in arcNodeResourceIds:{
  name: guid(hciNode, roleDefinitionResourceId)
  scope: keyVault
  properties:  {
    roleDefinitionId: roleDefinitionResourceId
    principalId: reference(hciNode,'2023-10-03-preview','Full').identity.principalId
    principalType: 'ServicePrincipal'
  }
}
]

resource cluster 'Microsoft.AzureStackHCI/clusters@2023-08-01-preview' = if (deploymentMode == 'Validate') {
  name: '${clusterName}'
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
  location: location
  scale: null
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
  location: location
  scale: null
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
  location: location
  scale: null
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
  location: location
  scale: null
  properties: {
    contentType: 'Secret'
    value: base64(witnessStorageAccount.listKeys().keys[0].value)
    attributes: {
      enabled: true
    }
  }
}

resource clusterName_default 'microsoft.azurestackhci/clusters/deploymentSettings@2023-08-01-preview' = {
  name: '${clusterName}/default'
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
              driftControlEnforced: driftControlEnforced
              credentialGuardEnforced: credentialGuardEnforced
              smbSigningEnforced: smbSigningEnforced
              smbClusterEncryption: smbClusterEncryption
              sideChannelMitigationEnforced: true
              bitlockerBootVolume: bitlockerBootVolume
              bitlockerDataVolumes: bitlockerDataVolumes
              wdacEnforced: wdacEnforced
            }
            observability: {
              streamingDataClient: streamingDataClient
              euLocation: euLocation
              episodicDataUpload: episodicDataUpload
            }
            cluster: {
              name: clusterName
              witnessType: 'Cloud'
              witnessPath: ''
              cloudAccountName: ClusterWitnessStorageAccountName
              azureServiceEndpoint: 'core.windows.net'
            }
            storage: {
              configurationMode: configurationMode
            }
            namingPrefix: deploymentprefix
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
              name: reference(hciNode,'2023-10-03-preview','Full').properties.displayName
              ipv4Address: reference(hciNode,'2023-10-03-preview','Full').properties.networkProfile.networkInterfaces[0].ipAddresses[0].address
            }
            ]
            hostNetwork: {
              enableStorageAutoIp: true
              intents: [
                {
                  adapter: mgmtAdapters
                  name: 'managment'
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
                    'Management'
                  ]
                }
                {
                  adapter: computeAdapters
                  name: 'compute'
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
                    loadBalancingAlgorithm: 'Dynamic'
                  }
                  trafficType: [
                    'Compute'
                  ]
                }
                {
                  adapter: [for network in storageNetworkList: network.networkAdapterName]
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
            adouPath: adouPath
            secretsLocation: reference(keyVaultName,'2021-06-01-preview').vaultUri
            optionalServices: {
              customLocation: customLocation
            }
          }
        }
      ]
    }
  }
  dependsOn: [
    cluster
  ]
}
