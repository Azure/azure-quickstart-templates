@description('Storage Account Name')
param storageAccountName string

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_ZRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Region')
@allowed([
  'northcentralus'
  'eastus2'
  'eastus2euap'
  'centralus'
  'canadaeast'
  'canadacentral'
  'northeurope'
  'australiaeast'
  'switzerlandnorth'
  'germanywestcentral'
  'eastasia'
  'francecentral'
])
param location string

@description('Username of primary user')
param userName string

@description('Home directory of primary user. Should be a container.')
param homeDirectory string

@description('SSH Public Key for primary user. If not specified, Azure will generate a password which can be accessed securely')
param publicKey string = ''

resource sa 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: true
    isLocalUserEnabled: true
    isSftpEnabled: true
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  name: '${sa.name}/default/${homeDirectory}'
  properties: {
    publicAccess: 'None'
  }

}

resource user 'Microsoft.Storage/storageAccounts/localUsers@2023-05-01' = {
  parent: sa
  name: userName
  properties: {
    permissionScopes: [
      {
        permissions: 'rcwdl'
        service: 'blob'
        resourceName: homeDirectory
      }
    ]
    homeDirectory: homeDirectory
    sshAuthorizedKeys: empty(publicKey) ? null : [
      {
        description: '${userName} public key'
        key: publicKey
      }
    ]
    hasSharedKey: false
  }
}
