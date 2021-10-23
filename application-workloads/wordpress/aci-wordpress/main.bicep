@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Storage Account Name')
param storageAccountName string = uniqueString(resourceGroup().id)

@description('WordPress Site Name')
param siteName string = storageAccountName

@description('MySQL database password')
@secure()
param mySqlPassword string

@description('Location for all resources.')
param location string = resourceGroup().location

var cpuCores = '0.5'
var memoryInGb = '0.7'
var wordpressContainerGroupName = 'wordpress-containerinstance'
var wordpressShareName = 'wordpress-share'
var mysqlShareName = 'mysql-share'
var scriptName = 'createFileShare'
var identityName = 'scratch'

var roleDefinitionId = resourceId('microsoft.authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var roleAssignmentName = guid(mi.name, roleDefinitionId, resourceGroup().id)

var sqlScriptToExecute = 'Get-AzStorageAccount -StorageAccountName ${storageAccountName} -ResourceGroupName ${resourceGroup().name} | New-AzStorageShare -Name ${mysqlShareName}'

resource mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: identityName
  location: location
}

resource miRoleAssign 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleAssignmentName
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: mi.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  dependsOn: [
    miRoleAssign
  ]
}

// create file share for wordpress
var wpScriptToExecute = 'Get-AzStorageAccount -StorageAccountName ${storageAccountName} -ResourceGroupName ${resourceGroup().name} | New-AzStorageShare -Name ${wordpressShareName}'
resource dScriptWp 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${scriptName}-${wordpressShareName}'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${mi.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '3.0'
    storageAccountSettings: {
      storageAccountName: stg.name
      storageAccountKey: stg.listKeys().keys[0].value
    }
    scriptContent: wpScriptToExecute
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
    timeout: 'PT5M'
  }
}

// create second file share for sql
resource dScriptSql 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${scriptName}-${mysqlShareName}'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${mi.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '3.0'
    storageAccountSettings: {
      storageAccountName: stg.name
      storageAccountKey: stg.listKeys().keys[0].value
    }
    scriptContent: sqlScriptToExecute
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
    timeout: 'PT5M'
  }
}

resource wpAci 'Microsoft.ContainerInstance/containerGroups@2019-12-01' = {
  name: wordpressContainerGroupName
  location: location
  dependsOn: [
    dScriptSql
    dScriptWp
  ]
  properties: {
    containers: [
      {
        name: 'wordpress'
        properties: {
          image: 'wordpress:4.9-apache'
          ports: [
            {
              protocol: 'TCP'
              port: 80
            }
          ]
          environmentVariables: [
            {
              name: 'WORDPRESS_DB_HOST'
              value: '127.0.0.1:3306'
            }
            {
              name: 'WORDPRESS_DB_PASSWORD'
              secureValue: mySqlPassword
            }
          ]
          volumeMounts: [
            {
              mountPath: '/var/www/html'
              name: 'wordpressfile'
            }
          ]
          resources: {
            requests: {
              cpu: any(cpuCores)
              memoryInGB: any(memoryInGb)
            }
          }
        }
      }
      {
        name: 'mysql'
        properties: {
          image: 'mysql:5.6'
          ports: [
            {
              protocol: 'TCP'
              port: 3306
            }
          ]
          environmentVariables: [
            {
              name: 'MYSQL_ROOT_PASSWORD'
              value: mySqlPassword
            }
          ]
          volumeMounts: [
            {
              mountPath: '/var/lib/mysql'
              name: 'mysqlfile'
            }
          ]
          resources: {
            requests: {
              cpu: any(cpuCores)
              memoryInGB: any(memoryInGb)
            }
          }
        }
      }
    ]
    volumes: [
      {
        azureFile: {
          shareName: wordpressShareName
          storageAccountKey: stg.listKeys().keys[0].value
          storageAccountName: stg.name
        }
        name: 'wordpressfile'
      }
      {
        azureFile: {
          shareName: mysqlShareName
          storageAccountKey: stg.listKeys().keys[0].value
          storageAccountName: stg.name
        }
        name: 'mysqlfile'
      }
    ]
    ipAddress: {
      ports: [
        {
          protocol: 'TCP'
          port: 80
        }
      ]
      type: 'Public'
      dnsNameLabel: siteName
    }
    osType: 'Linux'
  }
}

output siteFQDN string = wpAci.properties.ipAddress.fqdn
