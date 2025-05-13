param location string = resourceGroup().location
param tenantId string = subscription().tenantId

@description('First must pass with this parameter set to Validate prior running with it set to Deploy. If either Validation or Deployment phases fail, fix the issue, then resubmit the template with the same deploymentMode to retry. Use LocksOnly if the deployment was not completed by executing this template (for example, if the Re-run Deployment option from the Portal was used instead).')
@allowed([
  'Validate'
  'Deploy'
  'LocksOnly'
])
param deploymentMode string = 'Validate'

@description('The prefix for the resource for the deployment. This value is used in key vault and storage account names in this template, as well as for the deploymentSettings.properties.deploymentConfiguration.scaleUnits.deploymentData.namingPrefix property which requires regex pattern: ^[a-zA-Z0-9-]{1,8}$')
@minLength(4)
@maxLength(8)
param deploymentPrefix string

// credentials for the deployment and ongoing lifecycle management
@description('The deployment username for the deployment - this is the user created in Active Directory by the preparation script')
param deploymentUsername string

@description('The deployment password for the deployment - this is for the user created in Active Directory by the preparation script')
@secure()
param deploymentUserPassword string

@description('The local admin username for the deployment - this is the local admin user for the nodes in the deployment - ex "deployuser"')
param localAdminUsername string

@description('The local admin password for the deployment - this is the local admin user for the nodes in the deployment')
@secure()
param localAdminPassword string

@description('The application ID of the pre-created App Registration for the Arc Resource Bridge deployment')
param arbDeploymentAppId string

@description('The service principal object ID of the pre-created App Registration for the Arc Resource Bridge deployment')
param arbDeploymentSPObjectId string

@description('A client secret of the pre-created App Registration for the Arc Resource Bridge deployment')
@secure()
param arbDeploymentServicePrincipalSecret string

@description('Entra ID object ID of the Azure Stack HCI Resource Provider in your tenant - to get, run `Get-AzADServicePrincipal -ApplicationId 1412d89f-b8a8-4111-b4fd-e82905cbd85d`')
param hciResourceProviderObjectId string

// cluster and active directory settings
@description('The name of the Azure Stack HCI cluster - this must be a valid Active Directory computer name and will be the name of your cluster in Azure.')
@maxLength(15)
@minLength(4)
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
type securityConfigurationType = {
  hvciProtection: bool
  drtmProtection: bool
  driftControlEnforced: bool
  credentialGuardEnforced: bool
  smbSigningEnforced: bool
  smbClusterEncryption: bool
  sideChannelMitigationEnforced: bool
  bitlockerBootVolume: bool
  bitlockerDataVolumes: bool
  wdacEnforced: bool
}

@description('Security configuration settings object')
param securityConfiguration securityConfigurationType = {
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
@description('The subnet mask for deploying a HCI cluster - ex: 255.255.252.0')
param subnetMask string

@description('The default gateway for deploying a HCI cluster')
param defaultGateway string

@description('The starting IP address for the Infrastructure Network IP pool. There must be at least 6 IPs between startingIPAddress and endingIPAddress and this pool should be not include the node IPs')
param startingIPAddress string

@description('The ending IP address for the Infrastructure Network IP pool. There must be at least 6 IPs between startingIPAddress and endingIPAddress and this pool should be not include the node IPs')
param endingIPAddress string

@description('The DNS servers for deploying a HCI cluster')
param dnsServers array

// define network intent for the cluster
@description('The storage connectivity switchless value for deploying a HCI cluster (less common)')
param storageConnectivitySwitchless bool

@description('The enable storage auto IP value for deploying a HCI cluster - this should be true for most deployments except when deploying a three-node switchless cluster, in which case storage IPs should be configured before deployment and this value set to false')
param enableStorageAutoIp bool = true

// define custom type for storage adapter IP info for 3-node switchless deployments
type storageAdapterIPInfoType = {
  physicalNode: string
  ipv4Address: string
  subnetMask: string
}

// define custom type for storage network objects
type storageNetworksType = {
  adapterName: string
  vlan: string
  storageAdapterIPInfo: storageAdapterIPInfoType[]? // optional for non-switchless deployments
}
type storageNetworksArrayType = storageNetworksType[]

@description('An array of JSON objects that define the storage network configuration for the cluster. Each object should contain the adapterName and vlan properties.')
param storageNetworks storageNetworksArrayType

@description('An array of Network Adapter names present on every cluster node intended for compute traffic')
param computeIntentAdapterNames array

@description('An array of Network Adapter names present on every cluster node intended for management traffic')
param managementIntentAdapterNames array

@description('Optional. The name of the storage account used for the Windows Failover Cluster Witness. If not provided, a new storage account will be created.')
param clusterWitnessStorageAccountName string = '${deploymentPrefix}${uniqueString(resourceGroup().id)}wit'

param customLocationName string = '${deploymentPrefix}_cl'

param keyVaultName string = '${deploymentPrefix}${uniqueString(resourceGroup().id)}kv'

var storageNetworkList = [for (storageAdapter, index) in storageNetworks:{
    name: 'StorageNetwork${index + 1}'
    networkAdapterName: storageAdapter.adapterName
    vlanId: storageAdapter.vlan
    storageAdapterIPInfo: storageAdapter.?storageAdapterIPInfo
  }
]

var deploymentSecretEceNames = [
  'LocalAdminCredential'
  'AzureStackLCMUserCredential'
  'DefaultARBApplication'
  'WitnessStorageKey'
]

var arcNodeResourceIds = [for (nodeName, index) in clusterNodeNames: resourceId('Microsoft.HybridCompute/machines', nodeName)]

module ashciPreReqResources 'modules/ashciPrereqs.bicep' = if (deploymentMode == 'Validate') {
  name: 'ashciPreReqResources'
  params: {
    location: location
    tenantId: tenantId
    deploymentPrefix: deploymentPrefix
    deploymentUsername: deploymentUsername
    deploymentUserPassword: deploymentUserPassword
    localAdminUsername: localAdminUsername
    localAdminPassword: localAdminPassword
    arbDeploymentAppId: arbDeploymentAppId
    arbDeploymentServicePrincipalSecret: arbDeploymentServicePrincipalSecret
    hciResourceProviderObjectId: hciResourceProviderObjectId
    softDeleteRetentionDays: softDeleteRetentionDays
    logsRetentionInDays: logsRetentionInDays
    arcNodePrincipalIds: [for arcNodeResourceId in arcNodeResourceIds: reference(arcNodeResourceId, '2022-12-27', 'Full').identity.principalId]
    keyVaultName: keyVaultName
    clusterWitnessStorageAccountName: clusterWitnessStorageAccountName
    arbDeploymentSPObjectId: arbDeploymentSPObjectId
    cloudId: cluster.properties.cloudId
    clusterName: clusterName
  }
}

resource cluster 'Microsoft.AzureStackHCI/clusters@2024-09-01-preview' = {
  name: clusterName
  identity: {
    type: 'SystemAssigned'
  }
  location: location
  properties: {}
}

resource deploymentSettings 'Microsoft.AzureStackHCI/clusters/deploymentSettings@2024-09-01-preview' = if (deploymentMode != 'LocksOnly') {
  name: 'default'
  parent: cluster
  dependsOn: [
    ashciPreReqResources
  ]
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
              name: reference(hciNode,'2022-12-27','Full').properties.displayName
              // Getting the IP from the first management NIC of the node based on the first NIC name in the managementIntentAdapterNames array parameter
              //
              // During deployment, a management vNIC will be created with the name 'vManagement(management)' and the IP config will be moved to the new vNIC--
              // this causes a null-index error when re-running the template mid-deployment, after net intents have applied. To workaround, change the name of
              // the management NIC in parameter file to 'vManagement(management)' 
              ipv4Address: (filter(reference('${hciNode}/providers/microsoft.azurestackhci/edgeDevices/default','2024-01-01','Full').properties.deviceConfiguration.nicDetails, nic => nic.adapterName == managementIntentAdapterNames[0]))[0].ip4Address
            }
            ]
            hostNetwork: {
              intents: [
                {
                  adapter: managementIntentAdapterNames
                  name: 'management'
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
                  adapter: computeIntentAdapterNames
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
              enableStorageAutoIp: enableStorageAutoIp
            }
            adouPath: domainOUPath
            secretsLocation: 'https://${keyVaultName}${environment().suffixes.keyvaultDns}'
            optionalServices: {
              customLocation: customLocationName
            }
            secrets: [
              for secretName in deploymentSecretEceNames: {
                secretName: '${clusterName}-${secretName}-${cluster.properties.cloudId}'
                eceSecretName: secretName
                secretLocation: 'https://${keyVaultName}${environment().suffixes.keyvaultDns}/secrets/${clusterName}-${secretName}-${cluster.properties.cloudId}'
              }
            ]
          }
        }
      ]
    }
  }
}

// create delete locks on critical HCI resources to prevent accidental deletion
module lockResources 'modules/ashciLocks.bicep' = if (deploymentMode != 'Validate') {
  name: 'lockResources'
  params: {
    clusterName: clusterName
    clusterNodeNames: clusterNodeNames
    keyVaultName: keyVaultName
    clusterWitnessStorageAccountName: clusterWitnessStorageAccountName
    customLocationName: customLocationName
  }
  dependsOn: [
    deploymentSettings
  ]
}
