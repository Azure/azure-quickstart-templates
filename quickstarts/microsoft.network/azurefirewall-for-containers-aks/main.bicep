@description('Location for all resources. Must be an Azure Firewall for Containers preview region (centraluseuap, eastus2euap, westcentralus, eastasia, uksouth, centralus).')
param location string = resourceGroup().location

@description('Prefix used to name the resources.')
@maxLength(12)
param namePrefix string = 'afc'

@description('VM size for the AKS nodes. Must be available in the selected region.')
param nodeVmSize string = 'Standard_DS3_v2'

@description('Number of AKS nodes.')
@minValue(1)
@maxValue(10)
param nodeCount int = 2

@description('Azure Firewall for Containers controller Helm chart version.')
param controllerVersion string = '20261103.2'

@description('Kubernetes namespace for the controller. Used in the workload identity federated credential subject.')
param controllerNamespace string = 'firewall-namespace'

@description('false (default): deploy Azure resources only; the outputs contain the remaining commands. true: also run a deployment script that installs the controller and applies a sample security policy, attachment, and test pods. The script needs a storage account with shared key access, so it fails where Azure Policy denies shared key access.')
param deployControllerAndSample bool = false

@description('Azure CLI version used by the deployment script.')
param azCliVersion string = '2.61.0'

@description('Unique suffix that forces the deployment script to rerun on each deployment. Leave the default.')
param utcValue string = utcNow()

var vnetName = '${namePrefix}-vnet'
var aksSubnetName = 'aks-subnet'
var vnetAddressPrefix = '10.224.0.0/12'
var aksSubnetPrefix = '10.224.0.0/16'
var firewallSubnetPrefix = '10.225.0.0/26'
var firewallMgmtSubnetPrefix = '10.225.1.0/26'
var clusterName = '${namePrefix}-aks'
var firewallName = '${namePrefix}-firewall'
var firewallPolicyName = '${namePrefix}-firewall-policy'
var routeTableName = '${namePrefix}-aks-rt'
var controllerServiceAccount = 'azurefirewall-controller-sa'

var networkContributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7')
var aksClusterAdminRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '0ab0b1a8-8aac-4efd-b8c2-3ee1fb270be8')

// ---------------------------------------------------------------- Identities
resource aksIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: '${namePrefix}-aks-identity'
  location: location
}

resource controllerIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: '${namePrefix}-controller-identity'
  location: location
}

// ---------------------------------------------------------------- Network
resource vnet 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: aksSubnetName
        properties: {
          addressPrefix: aksSubnetPrefix
          defaultOutboundAccess: false
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: firewallSubnetPrefix
          defaultOutboundAccess: false
        }
      }
      {
        name: 'AzureFirewallManagementSubnet'
        properties: {
          addressPrefix: firewallMgmtSubnetPrefix
          defaultOutboundAccess: false
        }
      }
    ]
  }
}

var aksSubnetId = '${vnet.id}/subnets/${aksSubnetName}'

resource firewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' existing = {
  parent: vnet
  name: 'AzureFirewallSubnet'
}

resource firewallMgmtSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' existing = {
  parent: vnet
  name: 'AzureFirewallManagementSubnet'
}

// The AKS control-plane identity manages load balancers and IPs in the BYO virtual network.
resource aksIdentityNetworkContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(vnet.id, aksIdentity.id, networkContributorRoleId)
  scope: vnet
  properties: {
    roleDefinitionId: networkContributorRoleId
    principalId: aksIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource firewallPublicIp 'Microsoft.Network/publicIPAddresses@2025-05-01' = {
  name: '${namePrefix}-fw-ip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource firewallMgmtPublicIp 'Microsoft.Network/publicIPAddresses@2025-05-01' = {
  name: '${namePrefix}-fw-mgmt-ip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

// ---------------------------------------------------------------- Firewall
// Base policy with the same rules the controller adds to a base policy it creates: AKS required egress and the AFC service.
resource firewallPolicy 'Microsoft.Network/firewallPolicies@2025-05-01' = {
  name: firewallPolicyName
  location: location
  properties: {
    sku: {
      tier: 'Premium'
    }
    threatIntelMode: 'Alert'
  }
}

resource baseRules 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2025-05-01' = {
  parent: firewallPolicy
  name: 'default-allow-aks-controlplane'
  properties: {
    priority: 100
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'AllowAksControlPlaneNetwork'
        priority: 100
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'Allow_AKS_ControlPlane_Network'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: [
              'AzureKubernetesService'
            ]
            destinationPorts: [
              '443'
            ]
          }
        ]
      }
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'AllowAksControlPlaneApp'
        priority: 101
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'Allow_AKS_ControlPlane_App'
            sourceAddresses: [
              '*'
            ]
            fqdnTags: [
              'AzureKubernetesService'
            ]
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Allow_AFC_Service'
            sourceAddresses: [
              '*'
            ]
            targetFqdns: [
              '*.afc.azure.com'
            ]
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
          }
        ]
      }
    ]
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2025-05-01' = {
  name: firewallName
  location: location
  dependsOn: [
    baseRules
  ]
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Premium'
    }
    firewallPolicy: {
      id: firewallPolicy.id
    }
    ipConfigurations: [
      {
        name: 'data-ipconfig'
        properties: {
          subnet: {
            id: firewallSubnet.id
          }
          publicIPAddress: {
            id: firewallPublicIp.id
          }
        }
      }
    ]
    managementIpConfiguration: {
      name: 'mgmt-ipconfig'
      properties: {
        subnet: {
          id: firewallMgmtSubnet.id
        }
        publicIPAddress: {
          id: firewallMgmtPublicIp.id
        }
      }
    }
  }
}

// ---------------------------------------------------------------- AKS
resource aks 'Microsoft.ContainerService/managedClusters@2025-07-01' = {
  name: clusterName
  location: location
  dependsOn: [
    aksIdentityNetworkContributor
  ]
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${aksIdentity.id}': {}
    }
  }
  properties: {
    dnsPrefix: clusterName
    agentPoolProfiles: [
      {
        name: 'nodepool1'
        mode: 'System'
        count: nodeCount
        vmSize: nodeVmSize
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: aksSubnetId
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      outboundType: 'loadBalancer'
      loadBalancerSku: 'standard'
      serviceCidr: '10.240.0.0/16'
      dnsServiceIP: '10.240.0.10'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
  }
}

// ---------------------------------------------------------------- Controller identity
resource controllerNetworkContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, controllerIdentity.id, networkContributorRoleId)
  properties: {
    roleDefinitionId: networkContributorRoleId
    principalId: controllerIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource controllerFederatedCredential 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2024-11-30' = {
  parent: controllerIdentity
  name: 'azurefirewall-controller'
  properties: {
    issuer: aks.properties.oidcIssuerProfile.issuerURL
    subject: 'system:serviceaccount:${controllerNamespace}:${controllerServiceAccount}'
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
}

// ---------------------------------------------------------------- Route AKS egress through the firewall
// Attached after the cluster exists and before any security policy is attached (attachments turn off pod SNAT).
resource routeTable 'Microsoft.Network/routeTables@2025-05-01' = {
  name: routeTableName
  location: location
  properties: {
    routes: [
      {
        name: 'to-firewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewall.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}

resource aksSubnetWithRoute 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' = {
  parent: vnet
  name: aksSubnetName
  dependsOn: [
    aks
  ]
  properties: {
    addressPrefix: aksSubnetPrefix
    defaultOutboundAccess: false
    routeTable: {
      id: routeTable.id
    }
  }
}

// ---------------------------------------------------------------- Optional: install the controller and a sample policy
resource scriptIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = if (deployControllerAndSample) {
  name: '${namePrefix}-script-identity'
  location: location
}

resource scriptAksAdmin 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (deployControllerAndSample) {
  name: guid(aks.id, '${namePrefix}-script-identity', aksClusterAdminRoleId)
  scope: aks
  properties: {
    roleDefinitionId: aksClusterAdminRoleId
    principalId: scriptIdentity!.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource installControllerAndSample 'Microsoft.Resources/deploymentScripts@2023-08-01' = if (deployControllerAndSample) {
  name: '${namePrefix}-install-controller'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${scriptIdentity.id}': {}
    }
  }
  dependsOn: [
    scriptAksAdmin
    controllerNetworkContributor
    controllerFederatedCredential
    aksSubnetWithRoute
  ]
  properties: {
    azCliVersion: azCliVersion
    timeout: 'PT1H'
    retentionInterval: 'P1D'
    cleanupPreference: 'OnSuccess'
    forceUpdateTag: utcValue
    environmentVariables: [
      {
        name: 'RESOURCE_GROUP'
        value: resourceGroup().name
      }
      {
        name: 'CLUSTER_NAME'
        value: aks.name
      }
      {
        name: 'CONTROLLER_VERSION'
        value: controllerVersion
      }
      {
        name: 'CONTROLLER_NAMESPACE'
        value: controllerNamespace
      }
      {
        name: 'CONTROLLER_CLIENT_ID'
        value: controllerIdentity.properties.clientId
      }
      {
        name: 'FIREWALL_ID'
        value: firewall.id
      }
      {
        name: 'AKS_SUBNET_ID'
        value: aksSubnetId
      }
    ]
    scriptContent: loadTextContent('scripts/install-controller.sh')
  }
}

// ---------------------------------------------------------------- Outputs
output clusterName string = aks.name
output firewallId string = firewall.id
output firewallPrivateIp string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
output firewallPolicyId string = firewallPolicy.id
output aksSubnetId string = aksSubnetId
output controllerIdentityClientId string = controllerIdentity.properties.clientId
output getCredentialsCommand string = 'az aks get-credentials --resource-group ${resourceGroup().name} --name ${aks.name}'
output helmInstallCommand string = 'helm install azfw-controller oci://mcr.microsoft.com/firewall/charts/azurefirewall-controller --namespace ${controllerNamespace} --create-namespace --version ${controllerVersion} --set azfwController.podIdentity.clientID=${controllerIdentity.properties.clientId}'
output attachmentFirewallRef string = 'firewallRef: { id: ${firewall.id} }'
output controllerAndSampleInstalled bool = deployControllerAndSample
