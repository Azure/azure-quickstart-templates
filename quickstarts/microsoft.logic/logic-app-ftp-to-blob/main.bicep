@description('The name of the logic app.')
param logicAppName string

@description('Account name of the Azure Blob storage account.')
param azureBlobAccountName string

@description('Account key of the Azure Blob storage account.')
@secure()
param azureBlobAccessKey string

@description('The name of the Azure Blob connection being created.')
param azureBlobConnectionName string

@description('The address of the FTP server.')
param ftpServerAddress string

@description('The username for the FTP server.')
param ftpUsername string

@description('The password for the FTP server.')
@secure()
param ftpPassword string

@description('The port for the FTP server.')
param ftpServerPort int = 21

@description('The name of the FTP connection being created.')
param ftpConnectionName string

@description('The path to the FTP folder you want to listen to.')
param ftpFolderPath string = '/'

@description('The container/path of the folder you want to add files to.')
param blobContainerPath string = '/mycontainer'

@description('Location for all resources.')
param location string = resourceGroup().location

var ftpisssl = true
var ftpisBinaryTransportftpisssl = true
var ftpdisableCertificateValidation = true

resource ftpConnection 'Microsoft.Web/connections@2018-07-01-preview' = {
  location: location
  name: ftpConnectionName
  properties: {
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'ftp')
    }
    displayName: 'ftp'
    parameterValues: {
      serverAddress: ftpServerAddress
      userName: ftpUsername
      password: ftpPassword
      serverPort: ftpServerPort
      isssl: ftpisssl
      isBinaryTransport: ftpisBinaryTransportftpisssl
      disableCertificateValidation: ftpdisableCertificateValidation
    }
  }
}

resource azureBlobConnection 'Microsoft.Web/connections@2018-07-01-preview' = {
  location: location
  name: azureBlobConnectionName
  properties: {
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'azureblob')
    }
    displayName: 'azureblob'
    parameterValues: {
      accountName: azureBlobAccountName
      accessKey: azureBlobAccessKey
    }
  }
}

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  properties: {
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {
          }
          type: 'Object'
        }
      }
      triggers: {
        When_a_file_is_added_or_modified: {
          recurrence: {
            frequency: 'Minute'
            interval: 1
          }
          metadata: {
            '${base64(ftpFolderPath)}': ftpFolderPath
          }
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'ftp\'][\'connectionId\']'
              }
            }
            method: 'get'
            path: '/datasets/default/triggers/onupdatedfile'
            queries: {
              folderId: base64(ftpFolderPath)
            }
          }
        }
      }
      actions: {
        Create_file: {
          type: 'ApiConnection'
          inputs: {
            body: '@triggerBody()'
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azureblob\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/datasets/default/files'
            queries: {
              folderPath: blobContainerPath
              name: '@{triggerOutputs()[\'headers\'][\'x-ms-file-name\']}'
            }
          }
        }
      }
      outputs: {
      }
    }
    parameters: {
      '$connections': {
        value: {
          azureblob: {
            id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'azureblob')
            connectionId: azureBlobConnection.id
          }
          ftp: {
            id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'ftp')
            connectionId: ftpConnection.id
          }
        }
      }
    }
  }
}
