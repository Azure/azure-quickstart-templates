param location string
param prefix string
param subnetId string
param userAssignedIdentities string
@description('Public Helm Repo Name')
param helmRepo string

@description('Public Helm Repo URL')
param helmRepoURL string

@description('Public Helm App')
param helmApp string

@description('Public Helm App Name')
param helmAppName string

resource aks 'Microsoft.ContainerService/managedClusters@2024-04-02-preview' = {
  name: '${prefix}-aks'
  location: location
  
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentities}': {}
    }
  }
  sku: {
     name: 'Base'
     tier: 'Standard'
  }
  properties: {
    nodeResourceGroup: '${prefix}-aks-MC'
    dnsPrefix: '${prefix}-aks-dns'
    disableLocalAccounts: false
    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'azure'
      networkPolicy: 'azure'
    }
    addonProfiles: {
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'false'
          rotationPollInterval: '2m'
        }
      }
    }
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: 128
        count: 1
        enableAutoScaling: true
        minCount: 1
        maxCount: 2
        vmSize: 'Standard_D2as_v4'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        maxPods: 110
        availabilityZones: []
        //nodeLabels: {
        //  system_pool: 'pool1'
        //}
        nodeTaints: []
        enableNodePublicIP: false
        vnetSubnetID: subnetId
      }
    ]
  }
}

module helm 'helm.bicep' = {
  name: 'HelmScripts'
  params: {
    location                  : location
    clusterName               : aks.name
    helmRepo                  : helmRepo
    helmRepoURL               : helmRepoURL
    helmApp                   : helmApp
    helmAppName               : helmAppName
  }
}

output kubernetesName string = aks.name
output kubernetesId string = aks.id
output nodeResourceGroup string = aks.properties.nodeResourceGroup
output helmOutput string = helm.outputs.helmOutput
