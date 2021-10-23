@description('The name of the HDInsight cluster to create.')
param clusterName string

@description('These credentials can be used to submit jobs to the cluster and to log into cluster dashboards. The username must consist of digits, upper or lowercase letters, and/or the following special characters: (!#$%&\'()-^_`{}~).')
@minLength(2)
@maxLength(20)
param clusterLoginUserName string

@description('The password must be at least 10 characters in length and must contain at least one digit, one upper case letter, one lower case letter, and one non-alphanumeric character except (single-quote, double-quote, backslash, right-bracket, full-stop). Also, the password must not contain 3 consecutive characters from the cluster username or SSH username.')
@minLength(10)
@secure()
param clusterLoginPassword string

@description('These credentials can be used to remotely access the cluster. The sshUserName can only consit of digits, upper or lowercase letters, and/or the following special characters (%&\'^_`{}~). Also, it cannot be the same as the cluster login username or a reserved word')
@minLength(2)
param sshUserName string

@description('SSH password must be 6-72 characters long and must contain at least one digit, one upper case letter, and one lower case letter.  It must not contain any 3 consecutive characters from the cluster login name')
@minLength(6)
@maxLength(72)
@secure()
param sshPassword string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('This is the headnode Azure Virtual Machine size, and will affect the cost. If you don\'t know, just leave the default value.')
@allowed([
  'Standard_A4_v2'
  'Standard_A8_v2'
  'Standard_E2_v3'
  'Standard_E4_v3'
  'Standard_E8_v3'
  'Standard_E16_v3'
  'Standard_E20_v3'
  'Standard_E32_v3'
  'Standard_E48_v3'
])
param headNodeVirtualMachineSize string = 'Standard_E8_v3'

@description('This is the workernode Azure Virtual Machine size, and will affect the cost. If you don\'t know, just leave the default value.')
@allowed([
  'Standard_A4_v2'
  'Standard_A8_v2'
  'Standard_E2_v3'
  'Standard_E4_v3'
  'Standard_E8_v3'
  'Standard_E16_v3'
  'Standard_E20_v3'
  'Standard_E32_v3'
  'Standard_E48_v3'
])
param workerNodeVirtualMachineSize string = 'Standard_E8_v3'

resource defaultStorageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'storage${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource cluster 'Microsoft.HDInsight/clusters@2018-06-01-preview' = {
  name: clusterName
  location: location
  properties: {
    clusterVersion: '4.0'
    osType: 'Linux'
    tier: 'Standard'
    clusterDefinition: {
      kind: 'spark'
      configurations: {
        gateway: {
          'restAuthCredential.isEnabled': true
          'restAuthCredential.username': clusterLoginUserName
          'restAuthCredential.password': clusterLoginPassword
        }
      }
    }
    storageProfile: {
      storageaccounts: [
        {
          name: replace(replace(defaultStorageAccount.properties.primaryEndpoints.blob, 'https://', ''), '/', '')
          isDefault: true
          container: clusterName
          key: defaultStorageAccount.listKeys('2021-04-01').keys[0].value
        }
      ]
    }
    computeProfile: {
      roles: [
        {
          name: 'headnode'
          targetInstanceCount: 2
          hardwareProfile: {
            vmSize: headNodeVirtualMachineSize
          }
          osProfile: {
            linuxOperatingSystemProfile: {
              username: sshUserName
              password: sshPassword
            }
          }
        }
        {
          name: 'workernode'
          targetInstanceCount: 2
          hardwareProfile: {
            vmSize: workerNodeVirtualMachineSize
          }
          osProfile: {
            linuxOperatingSystemProfile: {
              username: sshUserName
              password: sshPassword
            }
          }
        }
      ]
    }
  }
}

output storage object = defaultStorageAccount.properties
output cluster object = cluster.properties
