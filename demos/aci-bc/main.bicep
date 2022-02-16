@description('Name for the container group')
param contGroupName string = 'msdyn365bc'

@description('The DNS label for the public IP address. It must be lowercase. It should match the following regular expression, or it will raise an error: ^[a-z][a-z0-9-]{1,61}[a-z0-9]$')
@maxLength(50)
param dnsPrefix string

@description('The eMail address to be used when requesting a Let\'s Encrypt certificate')
param letsEncryptMail string

@description('Dynamics 365 Business Central Generic image (10.0.19041.985 is the version of Windows Server). See https://mcr.microsoft.com/v2/businesscentral/tags/list')
param bcRelease string = 'mcr.microsoft.com/businesscentral:10.0.19041.985'

@description('Dynamics 365 Business Central artifact URL. See https://freddysblog.com/2020/06/25/working-with-artifacts/ to understand how to find the right one.')
param bcArtifactUrl string = 'https://bcartifacts.azureedge.net/onprem/19.2.32968.33504/w1'

@description('Username for your BC super user')
param username string

@description('Password for your BC super user and your sa user on the database')
@secure()
param password string

@description('The number of CPU cores to allocate to the container')
param cpuCores int = 2

@description('The amount of memory to allocate to the container in gigabytes. Provide a minimum of 3 as he container will include SQL Server and BCST')
param memoryInGb int = 4

@description('Custom settings for the BCST')
param customNavSettings string = ''

@description('Custom settings for the Web Client')
param customWebSettings string = ''

@description('Change to \'Y\' to accept the end user license agreement available at https://go.microsoft.com/fwlink/?linkid=861843. This is necessary to successfully run the container')
@allowed([
  'Y'
  'N'
])
param acceptEula string = 'N'

@description('Please select the Azure container URL suffix for your current region. For the standard Azure cloud, this is azurecontainer.io')
@allowed([
  '.azurecontainer.io'
])
param azurecontainerSuffix string = '.azurecontainer.io'

@description('Default location for all resources.')
param location string = resourceGroup().location

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated. Use the defaultValue if the staging location is not secured.')
@secure()
param _artifactsLocationSasToken string = ''

var image = bcRelease
var publicdnsname = '${dnsPrefix}.${location}${azurecontainerSuffix}'
var foldersZipUri = uri(_artifactsLocation, 'scripts/SetupCertificate.zip${_artifactsLocationSasToken}')

resource contGroup 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = {
  name: contGroupName
  location: location
  properties: {
    containers: [
      {
        name: contGroupName
        properties: {
          environmentVariables: [
            {
              name: 'ACCEPT_EULA'
              value: acceptEula
            }
            {
              name: 'accept_outdated'
              value: 'y'
            }
            {
              name: 'username'
              value: username
            }
            {
              name: 'password'
              value: password
            }
            {
              name: 'customNavSettings'
              value: customNavSettings
            }
            {
              name: 'customWebSettings'
              value: customWebSettings
            }
            {
              name: 'PublicDnsName'
              value: publicdnsname
            }
            {
              name: 'folders'
              value: 'c:\\run\\my=${foldersZipUri}'
            }
            {
              name: 'ContactEMailForLetsEncrypt'
              value: letsEncryptMail
            }
            {
              name: 'artifacturl'
              value: bcArtifactUrl
            }
            {
              name: 'certificatePfxPassword'
              value: password
            }
          ]
          image: image
          ports: [
            {
              protocol: 'TCP'
              port: 443
            }
            {
              protocol: 'TCP'
              port: 8080
            }
            {
              protocol: 'TCP'
              port: 7049
            }
            {
              protocol: 'TCP'
              port: 7048
            }
            {
              protocol: 'TCP'
              port: 80
            }
          ]
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
        }
      }
    ]
    restartPolicy: 'Never'
    osType: 'Windows'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          protocol: 'TCP'
          port: 443
        }
        {
          protocol: 'TCP'
          port: 8080
        }
        {
          protocol: 'TCP'
          port: 7049
        }
        {
          protocol: 'TCP'
          port: 7048
        }
        {
          protocol: 'TCP'
          port: 80
        }
      ]
      dnsNameLabel: dnsPrefix
    }
  }
}

output containerIPAddressFqdn string = contGroup.properties.ipAddress.fqdn
