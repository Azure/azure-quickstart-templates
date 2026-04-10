param location string
param prefix string
param subnetId string
param userAssignedIdentities string
param vmSize string
param utcValue string = utcNow()

@description('Public Helm Repo Name')
param helmRepo string = 'prometheus-community'

@description('Public Helm Repo URL')
param helmRepoURL string = 'https://prometheus-community.github.io/helm-charts'

@description('Public Helm App')
param helmApp string = 'prometheus-community/kube-prometheus-stack'

@description('Public Helm App Name')
param helmAppName string = 'prometheus'

var helmRoleDefinitionId   = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var helmRoleAssignmentName = guid(helmRoleDefinitionId, helmManagedIdentity.id, resourceGroup().id)

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
        vmSize: vmSize
        osType: 'Linux'
        osSKU: 'Ubuntu'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        maxPods: 110
        enableNodePublicIP: false
        vnetSubnetID: subnetId
      }
    ]
  }
}

resource helmManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: 'helmIdentityName'
  location: location
}

resource helmIdentityRoleAssignDeployment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: resourceGroup()
  name: helmRoleAssignmentName
  properties: {
    roleDefinitionId: helmRoleDefinitionId 
    principalId     : helmManagedIdentity.properties.principalId
    principalType   : 'ServicePrincipal'
  }
}

resource helmCustomScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'helmCustomScript'
  location: location
  dependsOn: [
    helmIdentityRoleAssignDeployment
  ]
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${helmManagedIdentity.id}': {}
    }
  }
  properties: {
    forceUpdateTag: utcValue
    azCliVersion: '2.63.0'
    timeout: 'PT300M'
    environmentVariables: [
      {
        name: 'RESOURCEGROUP'
        secureValue: resourceGroup().name
      }
      {
        name: 'CLUSTER_NAME'
        secureValue: aks.name
      }
      {
        name: 'HELM_REPO'
        secureValue: helmRepo
      }
      {
        name: 'HELM_REPO_URL'
        secureValue: helmRepoURL
      }
      {
        name: 'HELM_APP'
        secureValue: helmApp
      }
      {
        name: 'HELM_APP_NAME'
        secureValue: helmAppName
      }
    ]
    scriptContent: loadTextContent('../../scripts/helm.sh')
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

output kubernetesName string = aks.name
output kubernetesId string = aks.id
output nodeResourceGroup string = aks.properties.nodeResourceGroup
output helmOutput string = helmCustomScript.properties.outputs.plsName
