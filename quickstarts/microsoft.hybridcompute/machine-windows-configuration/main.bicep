@description('The Azure region where resources in the template should be deployed.')
param location string

@description('Name of the machine.')
param machineName string

@description('The base URI where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated.')
param artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.')
@secure()
param artifactsLocationSasToken string = ''

@description('Name of subfolder containing the configuration package.')
param configurationFolder string = 'configuration'

@description('File name of the configuration package.')
param configurationFileName string = 'netcore6.zip'

resource machine 'Microsoft.HybridCompute/Machines@2021-05-20' = {
  name: machineName
  location: location
  identity: {
    type:'SystemAssigned'
  }
  properties:{
  }
}

resource configuration 'Microsoft.GuestConfiguration/guestConfigurationAssignments@2020-06-25' = {
  name: 'netcore6'
  scope: machine
  location: location
  properties: {
    guestConfiguration: {
      assignmentType: 'ApplyAndMonitor'
      name: 'netcore6'
      contentUri: uri(artifactsLocation, '${configurationFolder}/${configurationFileName}${artifactsLocationSasToken}')
      contentHash: '1B7C29568FE05CB0C6A2BF097777F3051E584A66AB23B6AE36BA97ADCE42126D'
      version: '1.0.0'
    }
  }
}
