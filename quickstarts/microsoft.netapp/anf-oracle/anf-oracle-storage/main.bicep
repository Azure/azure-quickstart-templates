@description('System ID for Oracle to create unique volume group and volume names. Minimum 3 and maximum 12 characters.')
@minLength(3)
@maxLength(12)
param UniqueSystemID string

@description('Availability Zone. This is None when proximity placement group is selected.')
@allowed([
  'None'
  '1'
  '2'
  '3'
])
param AvailabilityZone string

@description('Name of proximity placement group. This is optional when Availability Zone is selected.')
@minLength(0)
@maxLength(80)
param ProximityPlacementGroupName string = ''

@description('Resource group name for the proximity placement group. This is optional when Availability Zone is selected.')
@minLength(0)
@maxLength(90)
param ProximityPlacementGroupResourceGroup string = ''

@description('Basic or Standard network features available to the volume')
@allowed([
  'Basic'
  'Standard'
])
param NetworkFeatures string = 'Basic'

@description('Specifies whether LDAP is enabled or not for all the volumes.')
param LdapEnabled bool = false

@description('Number of Oracle data volumes. Minimum 1 and maximum 8 data volumes.')
@minValue(1)
@maxValue(8)
param NoOfOracleDataVolumes int

@description('Total size of the database. This and the number of data volumes and addition capacity for snapshots will be used to calculate the size of each individual data volume.')
@minValue(1)
@maxValue(800)
param OracleDatabaseSizeInTebibytes int

@description('Total throughput in MiB/s for the database. This will be used to calculate the throughput of each data volume.')
@minLength(1)
@maxLength(16)
param OracleThroughputInMebibytesPerSecond string

@description('Name of Capacity Pool in Azure NetApp Files (ANF) account. All the volumes are created using this capacity pool.')
@minLength(1)
@maxLength(64)
param CapacityPool string

@description('Additional capacity provisioned for each data volume to keep local snapshots. Possible values 0% - 100%. The default of 20% is usually sufficient to retain multiple snapshots.')
@minValue(0)
@maxValue(100)
param AdditionalCapacityForSnapshotsPercentage int = 20

@description('If a Tag Key is specified, it will be added to each volume created by this ARM template.')
@maxLength(512)
param TagKey string = ''

@description('If a Tag Value is specified, it will be added to each volume created by this ARM template. The value will only be added if Tag Key was specified.')
@maxLength(256)
param TagValue string = ''

@description('Azure NetApp Files (ANF) Location. If the resource group location is different than ANF location, ANF location needs to be specified.')
@minLength(1)
@maxLength(1024)
param AzureNetappFilesLocation string = resourceGroup().location

@description('Name of Azure NetApp Files (ANF) account.')
@minLength(1)
@maxLength(128)
param ANFNetappAccount string

@description('Virtual Network name for the subnet.')
@minLength(1)
@maxLength(1024)
param VirtualNetwork string

@description('Delegated Subnet name.')
@minLength(1)
@maxLength(1024)
param DelegatedSubnet string = 'default'

@description('Manually specify the size of each data volume or use “auto” to let ARM calculate. See documentation for details.')
@minLength(1)
@maxLength(16)
param DataSizeInGibibytes string = 'auto'

@description('Manually specify the performance of each data volume or use “auto” to let ARM calculate. See documentation for details.')
@minLength(1)
@maxLength(16)
param DataPerformanceInMebibytesPerSecond string = 'auto'

@description('NFS Protocol version for all volumes.')
@allowed([
  'NFSv3'
  'NFSv4.1'
])
param NFSVersion string = 'NFSv4.1'

@description('Specify capacity (in GiB). Possible values can be auto or integer value representing size.')
@minLength(1)
@maxLength(16)
param LogSizeInGibibytes string = 'auto'

@description('Specify throughput in MiB/s. Possible values can be "auto" or integer values (min 1 MiB/s) representing throughput.')
@minLength(1)
@maxLength(16)
param LogPerformanceInMebibytesPerSecond string = 'auto'

@description('Specify capacity (in GiB). Possible values can be "auto", none or integer values (min 100 GiB) representing size.')
@minLength(1)
@maxLength(16)
param LogMirrorSizeInGibibytes string = 'auto'

@description('Specify throughput in MiB/s. Possible values can be "auto" or integer values (min 1 MiB/s) representing throughput.')
@minLength(1)
@maxLength(16)
param LogMirrorPerformanceInMebibytesPerSecond string = 'auto'

@description('Specify capacity (in GiB). Possible values can be "auto", none or integer values (min 100 GiB) representing size.')
@minLength(1)
@maxLength(16)
param BinarySizeInGibibytes string = 'auto'

@description('Specify throughput in MiB/s. Possible values can be "auto" or integer values (min 1 MiB/s) representing throughput.')
@minLength(1)
@maxLength(16)
param BinaryPerformanceInMebibytesPerSecond string = 'auto'

@description('Specify capacity (in GiB). Possible values can be "auto", none or integer values (min 100 GiB) representing size.')
@minLength(1)
@maxLength(16)
param BackupSizeInGibibytes string = 'auto'

@description('Specify throughput in MiB/s. Possible values can be "auto" or integer values (min 1 MiB/s) representing throughput.')
@minLength(1)
@maxLength(16)
param BackupPerformanceInMebibytesPerSecond string = 'auto'

var location = AzureNetappFilesLocation
var OracleApplicationType = 'ORACLE'
var _1GBInBytes = (1024 * (1024 * 1024))
var _1TBInGiB = 1024
var volumeGroupName = '${ANFNetappAccount}/Oracle-${UniqueSystemID}-VolumeGroup'
var tagPayload = {
  '${TagKey}': TagValue
}
var emptyTag = {}
var volumeTag = ((TagKey == '') ? emptyTag : tagPayload)
var zones = (empty(ProximityPlacementGroupName) ? ((AvailabilityZone == 'None') ? [] : array(AvailabilityZone)) : null)
var proximityPlacementGroup = (empty(ProximityPlacementGroupName) ? null : resourceId(ProximityPlacementGroupResourceGroup, 'Microsoft.Compute/proximityPlacementGroups', ProximityPlacementGroupName))
var autoDataVolumeSize = min((_1TBInGiB * 100), int((((_1TBInGiB * OracleDatabaseSizeInTebibytes) + int(((AdditionalCapacityForSnapshotsPercentage * (_1TBInGiB * OracleDatabaseSizeInTebibytes)) / 100))) / NoOfOracleDataVolumes)))
var dataVolumeSize = ((DataSizeInGibibytes == 'auto') ? autoDataVolumeSize : int(DataSizeInGibibytes))
var dataVolumeThroughput = ((DataPerformanceInMebibytesPerSecond == 'auto') ? int((int(OracleThroughputInMebibytesPerSecond) / NoOfOracleDataVolumes)) : int(DataPerformanceInMebibytesPerSecond))
var autoLogVolumeSize = 100
var autoLogThroughput = 150
var logVolumeSize = ((LogSizeInGibibytes == 'auto') ? autoLogVolumeSize : int(LogSizeInGibibytes))
var logVolumeThroughput = ((LogPerformanceInMebibytesPerSecond == 'auto') ? autoLogThroughput : int(LogPerformanceInMebibytesPerSecond))
var autoLogMirrorVolumeSize = 100
var autoLogMirrorThroughput = 150
var logMirrorVolumeSize = ((LogMirrorSizeInGibibytes == 'auto') ? autoLogMirrorVolumeSize : ((LogMirrorSizeInGibibytes == 'none') ? 0 : int(LogMirrorSizeInGibibytes)))
var logMirrorVolumeThroughput = ((LogMirrorPerformanceInMebibytesPerSecond == 'auto') ? autoLogMirrorThroughput : int(LogMirrorPerformanceInMebibytesPerSecond))
var autoBinaryVolumeSize = 100
var autoBinaryThroughput = 64
var binaryVolumeSize = ((BinarySizeInGibibytes == 'auto') ? autoBinaryVolumeSize : ((BinarySizeInGibibytes == 'none') ? 0 : int(BinarySizeInGibibytes)))
var binaryVolumeThroughput = ((BinaryPerformanceInMebibytesPerSecond == 'auto') ? autoBinaryThroughput : int(BinaryPerformanceInMebibytesPerSecond))
var autoBackupVolumeSize = min((_1TBInGiB * 100), int(((_1TBInGiB * OracleDatabaseSizeInTebibytes) / 2)))
var autoBackupThroughput = 150
var backupVolumeSize = ((BackupSizeInGibibytes == 'auto') ? autoBackupVolumeSize : ((BackupSizeInGibibytes == 'none') ? 0 : int(BackupSizeInGibibytes)))
var backupVolumeThroughput = ((BackupPerformanceInMebibytesPerSecond == 'auto') ? autoBackupThroughput : int(BackupPerformanceInMebibytesPerSecond))
var logVolumePayload = {
  type: 'Microsoft.NetApp/netAppAccounts/capacityPools/volumes'
  name: '${UniqueSystemID}-ora-log'
  tags: volumeTag
  zones: zones
  properties: {
    creationToken: '${UniqueSystemID}-ora-log'
    ldapEnabled: LdapEnabled
    networkFeatures: NetworkFeatures
    proximityPlacementGroup: proximityPlacementGroup
    usageThreshold: (_1GBInBytes * logVolumeSize)
    capacityPoolResourceId: resourceId('Microsoft.NetApp/netAppAccounts/capacityPools', ANFNetappAccount, CapacityPool)
    volumeSpecName: 'ora-log'
    kerberosEnabled: false
    throughputMibps: logVolumeThroughput
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', VirtualNetwork, DelegatedSubnet)
    exportPolicy: {
      rules: [
        {
          ruleIndex: 1
          unixReadOnly: false
          unixReadWrite: true
          cifs: false
          kerberos5ReadOnly: false
          kerberos5ReadWrite: false
          kerberos5iReadOnly: false
          kerberos5iReadWrite: false
          kerberos5pReadOnly: false
          kerberos5pReadWrite: false
          nfsv3: ((NFSVersion == 'NFSv3') ? 'true' : 'false')
          nfsv41: ((NFSVersion == 'NFSv4.1') ? 'true' : 'false')
          allowedClients: '0.0.0.0/0'
          hasRootAccess: true
        }
      ]
    }
    protocolTypes: [
      NFSVersion
    ]
  }
}
var logMirrorVolumePayload = {
  type: 'Microsoft.NetApp/netAppAccounts/capacityPools/volumes'
  name: '${UniqueSystemID}-ora-log-mirror'
  tags: volumeTag
  zones: zones
  properties: {
    creationToken: '${UniqueSystemID}-ora-log-mirror'
    ldapEnabled: LdapEnabled
    networkFeatures: NetworkFeatures
    proximityPlacementGroup: proximityPlacementGroup
    usageThreshold: (_1GBInBytes * logMirrorVolumeSize)
    capacityPoolResourceId: resourceId('Microsoft.NetApp/netAppAccounts/capacityPools', ANFNetappAccount, CapacityPool)
    volumeSpecName: 'ora-log-mirror'
    kerberosEnabled: false
    throughputMibps: logMirrorVolumeThroughput
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', VirtualNetwork, DelegatedSubnet)
    exportPolicy: {
      rules: [
        {
          ruleIndex: 1
          unixReadOnly: false
          unixReadWrite: true
          cifs: false
          kerberos5ReadOnly: false
          kerberos5ReadWrite: false
          kerberos5iReadOnly: false
          kerberos5iReadWrite: false
          kerberos5pReadOnly: false
          kerberos5pReadWrite: false
          nfsv3: ((NFSVersion == 'NFSv3') ? 'true' : 'false')
          nfsv41: ((NFSVersion == 'NFSv4.1') ? 'true' : 'false')
          allowedClients: '0.0.0.0/0'
          hasRootAccess: true
        }
      ]
    }
    protocolTypes: [
      NFSVersion
    ]
  }
}
var binaryVolumePayload = {
  type: 'Microsoft.NetApp/netAppAccounts/capacityPools/volumes'
  name: '${UniqueSystemID}-ora-binary'
  tags: volumeTag
  zones: zones
  properties: {
    creationToken: '${UniqueSystemID}-ora-binary'
    ldapEnabled: LdapEnabled
    networkFeatures: NetworkFeatures
    proximityPlacementGroup: proximityPlacementGroup
    usageThreshold: (_1GBInBytes * binaryVolumeSize)
    capacityPoolResourceId: resourceId('Microsoft.NetApp/netAppAccounts/capacityPools', ANFNetappAccount, CapacityPool)
    volumeSpecName: 'ora-binary'
    kerberosEnabled: false
    throughputMibps: binaryVolumeThroughput
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', VirtualNetwork, DelegatedSubnet)
    exportPolicy: {
      rules: [
        {
          ruleIndex: 1
          unixReadOnly: false
          unixReadWrite: true
          cifs: false
          kerberos5ReadOnly: false
          kerberos5ReadWrite: false
          kerberos5iReadOnly: false
          kerberos5iReadWrite: false
          kerberos5pReadOnly: false
          kerberos5pReadWrite: false
          nfsv3: ((NFSVersion == 'NFSv3') ? 'true' : 'false')
          nfsv41: ((NFSVersion == 'NFSv4.1') ? 'true' : 'false')
          allowedClients: '0.0.0.0/0'
          hasRootAccess: true
        }
      ]
    }
    protocolTypes: [
      NFSVersion
    ]
  }
}
var backupVolumePayload = {
  type: 'Microsoft.NetApp/netAppAccounts/capacityPools/volumes'
  name: '${UniqueSystemID}-ora-backup'
  tags: volumeTag
  zones: zones
  properties: {
    creationToken: '${UniqueSystemID}-ora-backup'
    ldapEnabled: LdapEnabled
    networkFeatures: NetworkFeatures
    proximityPlacementGroup: proximityPlacementGroup
    usageThreshold: (_1GBInBytes * backupVolumeSize)
    capacityPoolResourceId: resourceId('Microsoft.NetApp/netAppAccounts/capacityPools', ANFNetappAccount, CapacityPool)
    volumeSpecName: 'ora-backup'
    kerberosEnabled: false
    throughputMibps: backupVolumeThroughput
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', VirtualNetwork, DelegatedSubnet)
    exportPolicy: {
      rules: [
        {
          ruleIndex: 1
          unixReadOnly: false
          unixReadWrite: true
          cifs: false
          kerberos5ReadOnly: false
          kerberos5ReadWrite: false
          kerberos5iReadOnly: false
          kerberos5iReadWrite: false
          kerberos5pReadOnly: false
          kerberos5pReadWrite: false
          nfsv3: ((NFSVersion == 'NFSv3') ? 'true' : 'false')
          nfsv41: ((NFSVersion == 'NFSv4.1') ? 'true' : 'false')
          allowedClients: '0.0.0.0/0'
          hasRootAccess: true
        }
      ]
    }
    protocolTypes: [
      NFSVersion
    ]
  }
}
var emptyArray = []
var volumesPayloadArray = concat(array(dataVolumePayloads), array(logVolumePayload), ((LogMirrorSizeInGibibytes == 'none') ? emptyArray : array(logMirrorVolumePayload)), ((BinarySizeInGibibytes == 'none') ? emptyArray : array(binaryVolumePayload)), ((BackupSizeInGibibytes == 'none') ? emptyArray : array(backupVolumePayload)))
var dataVolumePayloads = [for i in range(0, NoOfOracleDataVolumes): {
  type: 'Microsoft.NetApp/netAppAccounts/capacityPools/volumes'
  name: '${UniqueSystemID}-ora-data${(i + 1)}'
  tags: volumeTag
  zones: zones
  properties: {
    creationToken: '${UniqueSystemID}-ora-data${(i + 1)}'
    ldapEnabled: LdapEnabled
    networkFeatures: NetworkFeatures
    proximityPlacementGroup: proximityPlacementGroup
    usageThreshold: (_1GBInBytes * dataVolumeSize)
    capacityPoolResourceId: resourceId('Microsoft.NetApp/netAppAccounts/capacityPools', ANFNetappAccount, CapacityPool)
    volumeSpecName: 'ora-data${(i + 1)}'
    kerberosEnabled: false
    throughputMibps: dataVolumeThroughput
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', VirtualNetwork, DelegatedSubnet)
    exportPolicy: {
      rules: [
        {
          ruleIndex: 1
          unixReadOnly: false
          unixReadWrite: true
          cifs: false
          kerberos5ReadOnly: false
          kerberos5ReadWrite: false
          kerberos5iReadOnly: false
          kerberos5iReadWrite: false
          kerberos5pReadOnly: false
          kerberos5pReadWrite: false
          nfsv3: ((NFSVersion == 'NFSv3') ? 'true' : 'false')
          nfsv41: ((NFSVersion == 'NFSv4.1') ? 'true' : 'false')
          allowedClients: '0.0.0.0/0'
          hasRootAccess: true
        }
      ]
    }
    protocolTypes: [
      NFSVersion
    ]
  }
}]

resource volumeGroup 'Microsoft.NetApp/netAppAccounts/volumeGroups@2023-05-01' = {
  name: volumeGroupName
  location: location
  properties: {
    groupMetaData: {
      groupDescription: 'Primary database for ${UniqueSystemID}'
      applicationType: OracleApplicationType
      applicationIdentifier: UniqueSystemID
    }
    volumes: volumesPayloadArray
  }
}
