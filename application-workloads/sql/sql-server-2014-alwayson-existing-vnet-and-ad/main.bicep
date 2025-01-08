@description('Naming prefix for each new resource created. 8-char max, lowercase alphanumeric')
@maxLength(8)
param namePrefix string

@description('Type of Storage to be used for VM disks')
@allowed([
  'Standard_LRS'
  'Premium_LRS'
])
param diskType string = 'Premium_LRS'

@description('Size of the SQL VMs to be created')
param sqlVMSize string = 'Standard_D4s_v3'

@description('Size of the Witness VM to be created')
param sqlWitnessVMSize string = 'Standard_D2s_v3'

@description('DNS domain name for existing Active Directory domain')
param existingDomainName string

@description('Name of the Administrator of the existing Active Directory Domain')
param adminUsername string

@description('Password for the Administrator account of the existing Active Directory Domain')
@secure()
param adminPassword string

@description('The SQL Server Service account name')
param sqlServerServiceAccountUserName string

@description('The SQL Server Service account password')
@secure()
param sqlServerServiceAccountPassword string

@description('Name of the existing subnet in the existing VNET to which the SQL & Witness VMs should be deployed')
param existingSqlSubnetName string

@description('Name of the existing VNET')
param existingVirtualNetworkName string

@description('Computer name of the existing Primary AD domain controller & DNS server')
@maxLength(15)
param existingAdPDCVMName string

@description('IP address of ILB for the SQL Server availability group listener to be created')
param sqlLBIPAddress string = '10.0.0.9'

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated.')
@secure()
param _artifactsLocationSasToken string = ''

@description('Location for all resources.')
param location string = resourceGroup().location

var sqlSubnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', existingVirtualNetworkName, existingSqlSubnetName)
var deploySqlClusterName = 'deploySqlCluster'

module deploySqlCluster 'modules/deploy-sql-cluster.bicep' = {
  name: deploySqlClusterName
  params: {
    location: location
    namePrefix: namePrefix
    domainName: existingDomainName
    diskType: diskType
    dnsServerName: existingAdPDCVMName
    adminUsername: adminUsername
    adminPassword: adminPassword
    sqlServerServiceAccountUserName: sqlServerServiceAccountUserName
    sqlServerServiceAccountPassword: sqlServerServiceAccountPassword
    nicSubnetUri: sqlSubnetRef
    lbSubnetUri: sqlSubnetRef
    sqlLBIPAddress: sqlLBIPAddress
    sqlVMSize: sqlVMSize
    sqlWitnessVMSize: sqlWitnessVMSize
    _artifactsLocation: _artifactsLocation
    _artifactsLocationSasToken: _artifactsLocationSasToken
  }
}
