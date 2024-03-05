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

@description('Entra ID object ID of the Azure Stack HCI Resource Provider in your tenant - to get, run `Get-AzADServicePrincipal -ApplicationId 1412d89f-b8a8-4111-b4fd-e82905cbd85d`')
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

var clusterWitnessStorageAccountName = '${deploymentPrefix}witness'

var keyVaultName = '${deploymentPrefix}-hcikv'
var customLocationName = '${deploymentPrefix}_cl'

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

module ashciPreReqResources 'modules/ashciPrereqs.bicep' = if (deploymentMode == 'Validate') {
  name: 'ashciPreReqResources'
  params: {
    location: location
    tenantId: tenantId
    deploymentPrefix: deploymentPrefix
    deploymentUsername: deploymentUsername
    deploymentUserPassword: deploymentUserPassword
    localAdminUser: localAdminUser
    localAdminPassword: localAdminPassword
    arbDeploymentSpnAppId: arbDeploymentSpnAppId
    arbDeploymentSpnPassword: arbDeploymentSpnPassword
    hciResourceProviderObjectId: hciResourceProviderObjectId
    softDeleteRetentionDays: softDeleteRetentionDays
    logsRetentionInDays: logsRetentionInDays
    arcNodeResourceIds: arcNodeResourceIds
    keyVaultName: keyVaultName
    clusterWitnessStorageAccountName: clusterWitnessStorageAccountName
  }
}

resource cluster 'Microsoft.AzureStackHCI/clusters@2023-08-01-preview' = if (deploymentMode == 'Validate') {
  name: clusterName
  identity: {
    type: 'SystemAssigned'
  }
  location: location
  properties: {}
  dependsOn: [
    ashciPreReqResources
  ]
}

resource deploymentSettings 'microsoft.azurestackhci/clusters/deploymentSettings@2023-08-01-preview' = {
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
            secretsLocation: '${keyVaultName}${environment().suffixes.keyvaultDns}'
            optionalServices: {
              customLocation: customLocationName
            }
          }
        }
      ]
    }
  }
}
