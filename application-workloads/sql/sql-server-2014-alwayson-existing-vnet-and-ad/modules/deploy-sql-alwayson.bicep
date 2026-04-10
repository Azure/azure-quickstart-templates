param sqlNamePrefix string
param domainName string
param namePrefix string
param sharePath string
param sqlWitnessVMName string
param sqlLBName string
param sqlLBIPAddress string
param dnsServerName string
param sqlServerServiceAccountUserName string

@secure()
param sqlServerServiceAccountPassword string
param adminUsername string

@secure()
param adminPassword string
param sqlAlwaysOnEndpointName string
param sqlAlwaysOnAvailabilityGroupName1 string
param sqlAlwaysOnAvailabilityGroupListenerName1 string
param _artifactsLocation string

@secure()
param _artifactsLocationSasToken string

@description('Location for all resources.')
param location string

var sqlAOPrepareModulesURL = uri(_artifactsLocation, 'dsc/prepare-sql-alwayson-server.ps1.zip${_artifactsLocationSasToken}')
var sqlAOPrepareConfigurationFunction = 'PrepareAlwaysOnSqlServer.ps1\\PrepareAlwaysOnSqlServer'
var createClusterModulesURL = uri(_artifactsLocation, 'dsc/create-failover-cluster.ps1.zip${_artifactsLocationSasToken}')
var createClusterConfigurationFunction = 'CreateFailoverCluster.ps1\\CreateFailoverCluster'
var clusterName = '${namePrefix}-c'

resource sqlAOPrepare 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  name: '${sqlNamePrefix}0/sqlAOPrepare'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.17'
    autoUpgradeMinorVersion: true
    settings: {
      wmfVersion: '5.0'
      modulesUrl: sqlAOPrepareModulesURL
      configurationFunction: sqlAOPrepareConfigurationFunction
      properties: {
        domainName: domainName
        sqlAlwaysOnEndpointName: sqlAlwaysOnEndpointName
        adminCreds: {
          userName: adminUsername
          password: 'PrivateSettingsRef:adminPassword'
        }
        sqlServiceCreds: {
          userName: sqlServerServiceAccountUserName
          password: 'PrivateSettingsRef:sqlServerServiceAccountPassword'
        }
      }
    }
    protectedSettings: {
      items: {
        adminPassword: adminPassword
        sqlServerServiceAccountPassword: sqlServerServiceAccountPassword
      }
    }
  }
}

resource createCluster 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  name: '${sqlNamePrefix}1/CreateCluster'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.17'
    autoUpgradeMinorVersion: true
    settings: {
      wmfVersion: '5.0'
      modulesUrl: createClusterModulesURL
      configurationFunction: createClusterConfigurationFunction
      properties: {
        domainName: domainName
        clusterName: clusterName
        sharePath: '\\\\${sqlWitnessVMName}\\${sharePath}'
        nodes: [
          '${sqlNamePrefix}0'
          '${sqlNamePrefix}1'
        ]
        sqlAlwaysOnEndpointName: sqlAlwaysOnEndpointName
        sqlAlwaysOnAvailabilityGroupName: sqlAlwaysOnAvailabilityGroupName1
        sqlAlwaysOnAvailabilityGroupListenerName: sqlAlwaysOnAvailabilityGroupListenerName1
        sqlAlwaysOnAvailabilityGroupListenerPort: 1433
        lbName: sqlLBName
        lbAddress: sqlLBIPAddress
        primaryReplica: '${sqlNamePrefix}1'
        secondaryReplica: '${sqlNamePrefix}0'
        dnsServerName: dnsServerName
        adminCreds: {
          userName: adminUsername
          password: 'PrivateSettingsRef:adminPassword'
        }
        sqlServiceCreds: {
          userName: sqlServerServiceAccountUserName
          password: 'PrivateSettingsRef:sqlServerServiceAccountPassword'
        }
      }
    }
    protectedSettings: {
      items: {
        adminPassword: adminPassword
        sqlServerServiceAccountPassword: sqlServerServiceAccountPassword
      }
    }
  }
  dependsOn: [
    sqlAOPrepare
  ]
}
