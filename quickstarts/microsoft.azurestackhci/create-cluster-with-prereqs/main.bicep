param location string = resourceGroup().location
param tenantId string = subscription().tenantId

@description('First must pass Validate prior running Deploy')
@allowed([
  'Validate'
  'Deploy'
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

// define custom type for storage network objects
type storageNetworksType = {
  adapterName: string
  vlan: string
}
type storageNetworksArrayType = storageNetworksType[]

@description('An array of JSON objects that define the storage network configuration for the cluster. Each object should contain the adapterName and vlan properties.')
param storageNetworks storageNetworksArrayType

@description('An array of Network Adapter names present on every cluster node intended for compute traffic')
param computeIntentAdapterNames array

@description('An array of Network Adapter names present on every cluster node intended for management traffic')
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
    arcNodeResourceIds: arcNodeResourceIds
    keyVaultName: keyVaultName
    clusterWitnessStorageAccountName: clusterWitnessStorageAccountName
  }
}

resource cluster 'Microsoft.AzureStackHCI/clusters@2024-01-01' = if (deploymentMode == 'Validate') {
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

resource deploymentSettings 'Microsoft.AzureStackHCI/clusters/deploymentSettings@2024-01-01' = {
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
              name: reference(hciNode,'2022-12-27','Full').properties.displayName
              // Getting the IP from the first management NIC of the node based on the first NIC name in the managementIntentAdapterNames array parameter
              // the edgeDevices resource is created and populated by the AzureEdgeDeviceManagement extension installation on the node
              // append '/providers/microsoft.azurestackhci/edgeDevices/default' to the HCI node URL in the Portal then click 'JSON view' to debug or check logs at C:\ProgramData\GuestConfig\
              ipv4Address: (filter(reference('${hciNode}/providers/microsoft.azurestackhci/edgeDevices/default','2024-01-01','Full').properties.deviceConfiguration.nicDetails, nic => nic.adapterName == managementIntentAdapterNames[0]))[0].ip4Address
            }
            ]
            hostNetwork: {
              intents: [
                {
                  adapter: managementIntentAdapterNames
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
          }
        }
      ]
    }
  }
}
