@description('Location of the Cluster')
param location string = resourceGroup().location

@description('Name of your cluster - Between 3 and 23 characters. Letters and numbers only')
param clusterName string

@description('Remote desktop user Id')
param adminUsername string

@description('Remote desktop user password. Must be a strong password')
@secure()
param adminPassword string

@description('VM image Publisher')
param vmImagePublisher string = 'MicrosoftWindowsServer'

@description('VM image offer')
param vmImageOffer string = 'WindowsServer'

@description('VM image SKU')
param vmImageSku string = '2019-Datacenter'

@description('VM image version')
param vmImageVersion string = 'latest'

@description('Input endpoint1 for the application to use. Replace it with what your application uses')
param loadBalancedAppPort1 int = 80

@description('Input endpoint2 for the application to use. Replace it with what your application uses')
param loadBalancedAppPort2 int = 8081

@description('The store name where the cert will be deployed in the virtual machine')
@allowed([
  'My'
])
param certificateStoreValue string = 'My'

@description('Certificate Thumbprint')
param certificateThumbprint string

@description('Resource Id of the key vault, is should be in the format of /subscriptions/<Sub ID>/resourceGroups/<Resource group name>/providers/Microsoft.KeyVault/vaults/<vault name>')
param sourceVaultResourceId string

@description('Refers to the location URL in your key vault where the certificate was uploaded')
param certificateUrlValue string

@description('Protection level.Three values are allowed - EncryptAndSign, Sign, None. It is best to keep the default of EncryptAndSign, unless you have a need not to')
@allowed([
  'None'
  'Sign'
  'EncryptAndSign'
])
param clusterProtectionLevel string = 'EncryptAndSign'

@description('Instance count for node type')
param nt0InstanceCount int = 5

@description('The drive to use to store data on a cluster node.')
@allowed([
  'OS'
  'Temp'
])
param nodeDataDrive string = 'Temp'

@description('The VM size to use for cluster nodes.')
param nodeTypeSize string = 'Standard_D2_v3'

param tenantId string
param clusterApplication string
param clientapplication string

var dnsName = clusterName
var vmName = 'vm'
var virtualNetworkName = 'VNet'
var addressPrefix = '10.0.0.0/16'
var nicName = 'NIC'
var lbIPName = 'PublicIP-LB-FE'
var overProvision = false
var nt0applicationStartPort = 20000
var nt0applicationEndPort = 30000
var nt0ephemeralStartPort = 49152
var nt0ephemeralEndPort = 65534
var nt0fabricTcpGatewayPort = 19000
var nt0fabricHttpGatewayPort = 19080
var subnet0Name = 'Subnet-0'
var subnet0Prefix = '10.0.0.0/24'
var subnet0Ref = resourceId('Microsoft.Network/virtualNetworks/subnets/', virtualNetworkName, subnet0Name)
var supportLogStorageAccountName = '${uniqueString(resourceGroup().id)}2'
var applicationDiagnosticsStorageAccountName = '${uniqueString(resourceGroup().id)}3'
var lbName = 'LB-${clusterName}-${vmNodeType0Name}'
var lbIPConfig0 = resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations/', lbName, 'LoadBalancerIPConfig')
var lbPoolID0 = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'LoadBalancerBEAddressPool')
var lbProbeID0 = resourceId('Microsoft.Network/loadBalancers/probes', lbName, 'FabricGatewayProbe')
var lbHttpProbeID0 = resourceId('Microsoft.Network/loadBalancers/probes', lbName, 'FabricHttpGatewayProbe')
var lbNatPoolID0 = resourceId('Microsoft.Network/loadBalancers/inboundNatPools', lbName, 'LoadBalancerBEAddressNatPool')
var vmNodeType0Name = toLower('NT1${vmName}')
var vmNodeType0Size = nodeTypeSize

resource supportLogStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: supportLogStorageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  tags: {
    resourceType: 'Service Fabric'
    clusterName: clusterName
  }
  properties: {}
}

resource applicationDiagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: applicationDiagnosticsStorageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  tags: {
    resourceType: 'Service Fabric'
    clusterName: clusterName
  }
  properties: {}
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: virtualNetworkName
  location: location
  tags: {
    resourceType: 'Service Fabric'
    clusterName: clusterName
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnet0Name
        properties: {
          addressPrefix: subnet0Prefix
        }
      }
    ]
  }
}

resource lbIP 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: lbIPName
  location: location
  tags: {
    resourceType: 'Service Fabric'
    clusterName: clusterName
  }
  properties: {
    dnsSettings: {
      domainNameLabel: dnsName
    }
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource lb 'Microsoft.Network/loadBalancers@2023-09-01' = {
  name: lbName
  location: location
  tags: {
    resourceType: 'Service Fabric'
    clusterName: clusterName
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'LoadBalancerIPConfig'
        properties: {
          publicIPAddress: {
            id: lbIP.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'LoadBalancerBEAddressPool'
        properties: {}
      }
    ]
    loadBalancingRules: [
      {
        name: 'LBRule'
        properties: {
          backendAddressPool: {
            id: lbPoolID0
          }
          backendPort: nt0fabricTcpGatewayPort
          enableFloatingIP: false
          frontendIPConfiguration: {
            id: lbIPConfig0
          }
          frontendPort: nt0fabricTcpGatewayPort
          idleTimeoutInMinutes: 5
          probe: {
            id: lbProbeID0
          }
          protocol: 'Tcp'
        }
      }
      {
        name: 'LBHttpRule'
        properties: {
          backendAddressPool: {
            id: lbPoolID0
          }
          backendPort: nt0fabricHttpGatewayPort
          enableFloatingIP: false
          frontendIPConfiguration: {
            id: lbIPConfig0
          }
          frontendPort: nt0fabricHttpGatewayPort
          idleTimeoutInMinutes: 5
          probe: {
            id: lbHttpProbeID0
          }
          protocol: 'Tcp'
        }
      }
      {
        name: 'AppPortLBRule1'
        properties: {
          backendAddressPool: {
            id: lbPoolID0
          }
          backendPort: loadBalancedAppPort1
          enableFloatingIP: false
          frontendIPConfiguration: {
            id: lbIPConfig0
          }
          frontendPort: loadBalancedAppPort1
          idleTimeoutInMinutes: 5
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, 'AppPortProbe1')
          }
          protocol: 'Tcp'
        }
      }
      {
        name: 'AppPortLBRule2'
        properties: {
          backendAddressPool: {
            id: lbPoolID0
          }
          backendPort: loadBalancedAppPort2
          enableFloatingIP: false
          frontendIPConfiguration: {
            id: lbIPConfig0
          }
          frontendPort: loadBalancedAppPort2
          idleTimeoutInMinutes: 5
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, 'AppPortProbe2')
          }
          protocol: 'Tcp'
        }
      }
    ]
    probes: [
      {
        name: 'FabricGatewayProbe'
        properties: {
          intervalInSeconds: 5
          numberOfProbes: 2
          port: nt0fabricTcpGatewayPort
          protocol: 'Tcp'
        }
      }
      {
        name: 'FabricHttpGatewayProbe'
        properties: {
          intervalInSeconds: 5
          numberOfProbes: 2
          port: nt0fabricHttpGatewayPort
          protocol: 'Tcp'
        }
      }
      {
        name: 'AppPortProbe1'
        properties: {
          intervalInSeconds: 5
          numberOfProbes: 2
          port: loadBalancedAppPort1
          protocol: 'Tcp'
        }
      }
      {
        name: 'AppPortProbe2'
        properties: {
          intervalInSeconds: 5
          numberOfProbes: 2
          port: loadBalancedAppPort2
          protocol: 'Tcp'
        }
      }
    ]
    inboundNatPools: [
      {
        name: 'LoadBalancerBEAddressNatPool'
        properties: {
          backendPort: 3389
          frontendIPConfiguration: {
            id: lbIPConfig0
          }
          frontendPortRangeEnd: 4500
          frontendPortRangeStart: 3389
          protocol: 'Tcp'
        }
      }
    ]
  }
}

resource vmNodeType0 'Microsoft.Compute/virtualMachineScaleSets@2023-09-01' = {
  name: vmNodeType0Name
  location: location
  sku: {
    name: vmNodeType0Size
    capacity: nt0InstanceCount
    tier: 'Standard'
  }
  tags: {
    resourceType: 'Service Fabric'
    clusterName: clusterName
  }
  properties: {
    overprovision: overProvision
    upgradePolicy: {
      mode: 'Automatic'
    }
    virtualMachineProfile: {
      extensionProfile: {
        extensions: [
          {
            name: 'ServiceFabricNodeVmExt_vmNodeType0Name'
            properties: {
              type: 'ServiceFabricNode'
              autoUpgradeMinorVersion: true
              protectedSettings: {
                StorageAccountKey1:  supportLogStorageAccount.listKeys().keys[0].value
                StorageAccountKey2: supportLogStorageAccount.listkeys().keys[1].value
              }
              publisher: 'Microsoft.Azure.ServiceFabric'
              settings: {
                clusterEndpoint: cluster.properties.clusterEndpoint
                nodeTypeRef: vmNodeType0Name
                dataPath: '${((nodeDataDrive == 'OS') ? 'C' : 'D')}:\\\\SvcFab'
                durabilityLevel: 'Silver'
                nicPrefixOverride: subnet0Prefix
                certificate: {
                  thumbprint: certificateThumbprint
                  x509StoreName: certificateStoreValue
                }
              }
              typeHandlerVersion: '1.0'
            }
          }
          {
            name: 'VMDiagnosticsVmExt_vmNodeType0Name'
            properties: {
              type: 'IaaSDiagnostics'
              autoUpgradeMinorVersion: true
              protectedSettings: {
                storageAccountName: applicationDiagnosticsStorageAccountName
                storageAccountKey: listKeys(applicationDiagnosticsStorageAccount.id, '2021-01-01').keys[0].value
                storageAccountEndPoint: 'https://${environment().suffixes.storage}'
              }
              publisher: 'Microsoft.Azure.Diagnostics'
              settings: {
                WadCfg: {
                  DiagnosticMonitorConfiguration: {
                    overallQuotaInMB: '50000'
                    EtwProviders: {
                      EtwEventSourceProviderConfiguration: [
                        {
                          provider: 'Microsoft-ServiceFabric-Actors'
                          scheduledTransferKeywordFilter: '1'
                          scheduledTransferPeriod: 'PT5M'
                          DefaultEvents: {
                            eventDestination: 'ServiceFabricReliableActorEventTable'
                          }
                        }
                        {
                          provider: 'Microsoft-ServiceFabric-Services'
                          scheduledTransferPeriod: 'PT5M'
                          DefaultEvents: {
                            eventDestination: 'ServiceFabricReliableServiceEventTable'
                          }
                        }
                      ]
                      EtwManifestProviderConfiguration: [
                        {
                          provider: 'cbd93bc2-71e5-4566-b3a7-595d8eeca6e8'
                          scheduledTransferLogLevelFilter: 'Information'
                          scheduledTransferKeywordFilter: '4611686018427387904'
                          scheduledTransferPeriod: 'PT5M'
                          DefaultEvents: {
                            eventDestination: 'ServiceFabricSystemEventTable'
                          }
                        }
                      ]
                    }
                  }
                }
                StorageAccount: applicationDiagnosticsStorageAccountName
              }
              typeHandlerVersion: '1.5'
            }
          }
        ]
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: '${nicName}-0'
            properties: {
              ipConfigurations: [
                {
                  name: '${nicName}-0'
                  properties: {
                    loadBalancerBackendAddressPools: [
                      {
                        id: lbPoolID0
                      }
                    ]
                    loadBalancerInboundNatPools: [
                      {
                        id: lbNatPoolID0
                      }
                    ]
                    subnet: {
                      id: subnet0Ref
                    }
                  }
                }
              ]
              primary: true
            }
          }
        ]
      }
      osProfile: {
        adminPassword: adminPassword
        adminUsername: adminUsername
        computerNamePrefix: vmNodeType0Name
        secrets: [
          {
            sourceVault: {
              id: sourceVaultResourceId
            }
            vaultCertificates: [
              {
                certificateStore: certificateStoreValue
                certificateUrl: certificateUrlValue
              }
            ]
          }
        ]
      }
      storageProfile: {
        imageReference: {
          publisher: vmImagePublisher
          offer: vmImageOffer
          sku: vmImageSku
          version: vmImageVersion
        }
        osDisk: {
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
          }
          caching: 'ReadOnly'
          createOption: 'FromImage'
        }
      }
    }
  }
  dependsOn: [
    virtualNetwork
    lb
  ]
}

resource cluster 'Microsoft.ServiceFabric/clusters@2023-11-01-preview' = {
  name: clusterName
  location: location
  tags: {
    resourceType: 'Service Fabric'
    clusterName: clusterName
  }
  properties: {
    azureActiveDirectory: {
      clientApplication: clientapplication
      clusterApplication: clusterApplication
      tenantId: tenantId
    }
    certificate: {
      thumbprint: certificateThumbprint
      x509StoreName: certificateStoreValue
    }
    diagnosticsStorageAccountConfig: {
      blobEndpoint: reference(supportLogStorageAccount.id, '2021-01-01').primaryEndpoints.blob
      protectedAccountKeyName: 'StorageAccountKey1'
      queueEndpoint: reference(supportLogStorageAccount.id, '2021-01-01').primaryEndpoints.queue
      storageAccountName: supportLogStorageAccountName
      tableEndpoint: reference(supportLogStorageAccount.id, '2021-01-01').primaryEndpoints.table
    }
    fabricSettings: [
      {
        parameters: [
          {
            name: 'ClusterProtectionLevel'
            value: clusterProtectionLevel
          }
        ]
        name: 'Security'
      }
    ]
    managementEndpoint: 'https://${lbIP.properties.dnsSettings.fqdn}:${nt0fabricHttpGatewayPort}'
    nodeTypes: [
      {
        name: vmNodeType0Name
        applicationPorts: {
          endPort: nt0applicationEndPort
          startPort: nt0applicationStartPort
        }
        clientConnectionEndpointPort: nt0fabricTcpGatewayPort
        durabilityLevel: 'Silver'
        ephemeralPorts: {
          endPort: nt0ephemeralEndPort
          startPort: nt0ephemeralStartPort
        }
        httpGatewayEndpointPort: nt0fabricHttpGatewayPort
        isPrimary: true
        vmInstanceCount: nt0InstanceCount
      }
    ]
    reliabilityLevel: 'Silver'
    upgradeMode: 'Automatic'
    vmImage: 'Windows'
  }
}

output location string = location
output name string = cluster.name
output resourceGroupName string = resourceGroup().name
output resourceId string = cluster.id
output clusterProperties object = cluster.properties
