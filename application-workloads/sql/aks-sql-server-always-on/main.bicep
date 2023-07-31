@description('The name to use for the AKS Cluster.')
param aksClusterName string = 'sql-server-aks'

@description('The name of the resource group to create the AKS Cluster in.')
param aksResourceGroupName string = 'sql-server-always-on'

@description('AAD Client ID for Azure account authentication - used to authenticate to Azure using Service Principal for ACI creation to run CNAB operation and also for AKS Cluster.')
@secure()
param azureClientId string

@description('AAD Client Secret for Azure account authentication - used to authenticate to Azure using Service Principal for ACI creation to run CNAB operation and also for AKS Cluster.')
@secure()
param azureClientSecret string

@description('The name of the action to be performed on the application instance.')
param cnabAction string = 'install'

@description('The name of the application instance.')
param cnabInstallationName string = 'porter-sql-server-always-on'

@description('The file share name in the storage account for the CNAB state to be stored in')
param cnabStateShareName string = ''

@secure()
@description('The storage account key for the account for the CNAB state to be stored in, if this is left blank it will be looked up at runtime')
param cnabStateStorageAccountKey string = ''

@description('The storage account name for the account for the CNAB state to be stored in, by default this will be in the current resource group and will be created if it does not exist')
param cnabStateStorageAccountName string = 'cnabstate${uniqueString(resourceGroup().id)}'

@description('The resource group name for the storage account for the CNAB state to be stored in, by default this will be in the current resource group, if this is changed to a different resource group the storage account is expected to already exist')
param cnabStateStorageAccountResourceGroupName string = resourceGroup().name

@description('Name for the container group')
param containerGroupName string = 'cg-${uniqueString(resourceGroup().id)}'

@description('Name for the container')
param containerName string = 'cn-${uniqueString(resourceGroup().id)}'

@description('The location in which the resources will be created.')
param location string = resourceGroup().location

@description('The Password for the SQL Server Master Key.')
@secure()
param sqlMasterkeyPassword string

@description('The Password for the sa user in SQL Server.')
@secure()
param sqlSaPassword string

resource cnabStateStorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = if (cnabStateStorageAccountResourceGroupName == resourceGroup().name) {
  name: cnabStateStorageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        file: {
          enabled: true
        }
      }
    }
  }
}

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: containerGroupName
  location: location
  properties: {
    containers: [
      {
        name: containerName
        properties: {
          image: 'cnabquickstartstest.azurecr.io/simongdavies/run-duffle:latest'
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 2
            }
          }
          environmentVariables: [
            {
              name: 'CNAB_ACTION'
              value: cnabAction
            }
            {
              name: 'CNAB_INSTALLATION_NAME'
              value: cnabInstallationName
            }
            {
              name: 'ACI_LOCATION'
              value: location
            }
            {
              name: 'CNAB_STATE_STORAGE_ACCOUNT_NAME'
              value: cnabStateStorageAccountName
            }
            {
              name: 'CNAB_STATE_STORAGE_ACCOUNT_KEY'
              secureValue: cnabStateStorageAccountKey
            }
            {
              name: 'CNAB_STATE_SHARE_NAME'
              value: cnabStateShareName
            }
            {
              name: 'VERBOSE'
              value: 'false'
            }
            {
              name: 'CNAB_BUNDLE_NAME'
              value: 'porter/sql-server-always-on'
            }
            {
              name: 'AKS_CLUSTER_NAME'
              value: aksClusterName
            }
            {
              name: 'AKS_RESOURCE_GROUP'
              value: aksResourceGroupName
            }
            {
              name: 'LOCATION'
              value: location
            }
            {
              name: 'SQL_MASTERKEYPASSWORD'
              secureValue: sqlMasterkeyPassword
            }
            {
              name: 'SQL_SAPASSWORD'
              secureValue: sqlSaPassword
            }
            {
              name: 'AZURE_CLIENT_ID'
              secureValue: azureClientId
            }
            {
              name: 'AZURE_CLIENT_SECRET'
              secureValue: azureClientSecret
            }
            {
              name: 'AZURE_SUBSCRIPTION_ID'
              value: subscription().subscriptionId
            }
            {
              name: 'AZURE_TENANT_ID'
              value: subscription().tenantId
            }
          ]
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: 'Never'
  }
  dependsOn: [
    cnabStateStorageAccount
  ]
}

output CNAB_Package_Action_Logs_Command string = 'az container logs -g ${resourceGroup().name} -n ${containerGroupName}  --container-name ${containerName} --follow'
