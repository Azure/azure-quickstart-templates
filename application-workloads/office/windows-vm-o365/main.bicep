@description('Local name for the VM can be whatever you want')
param vmName string = 'O365VM'

@description('VM admin user name')
param vmAdminUserName string

@description('VM admin password. The supplied password must be between 8-123 characters long and must satisfy at least 3 of password complexity requirements from the following: 1) Contains an uppercase character 2) Contains a lowercase character 3) Contains a numeric digit 4) Contains a special character.')
@secure()
param vmAdminPassword string

@description('Desired Size of the VM.')
param vmSize string = 'Standard_D2s_v3'

@description('VM Image SKU')
param vmSku string = 'vs-2019-comm-latest-ws2019'

@description('DNS Label for the Public IP. Must be lowercase. It should match with the following regular expression: ^[a-z][a-z0-9-]{1,61}[a-z0-9]$ or it will raise an error.')
param dnsLabelPrefix string

@description('Which version of Office would you would like to deploy')
@allowed([
  'Office2016'
  'Office2013'
])
param officeVersion string = 'Office2016'

@description('PowerShell script name to execute')
param setupOfficeScriptFileName string = 'DeployO365SilentWithVersion.ps1'

@description('The base URI where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated.')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated.')
@secure()
param _artifactsLocationSasToken string = ''

@description('Location for all resources.')
param location string = resourceGroup().location

var vnet01Prefix = '10.0.0.0/16'
var vnet01Subnet1Name = 'Subnet-1'
var vnet01Subnet1Prefix = '10.0.0.0/24'
var vmImageReference = {
  publisher: 'MicrosoftVisualStudio'
  offer: 'visualstudio2019latest'
  sku: vmSku
  version: 'latest'
}
var vmSubnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, vnet01Subnet1Name)
var vmNicName = '${vmName}_NIC'
var vmIPName = 'VM_IP'
var vnetName = 'VNet01'

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  tags: {
    displayName: vnetName
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet01Prefix
      ]
    }
    subnets: [
      {
        name: vnet01Subnet1Name
        properties: {
          addressPrefix: vnet01Subnet1Prefix
        }
      }
    ]
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: vmIPName
  location: location
  tags: {
    displayName: 'VMIP'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: vmNicName
  location: location
  tags: {
    displayName: 'VMNIC'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vmSubnetRef
          }
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: vmName
  location: location
  tags: {
    displayName: 'VM01'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: vmAdminUserName
      adminPassword: vmAdminPassword
    }
    storageProfile: {
      imageReference: vmImageReference
      osDisk: {
        name: '${vmName}_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

resource SetupOffice 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  parent: vm
  name: 'SetupOffice'
  location: location
  tags: {
    displayName: 'SetupOffice'
  }
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.9'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        uri(_artifactsLocation, '${setupOfficeScriptFileName}${_artifactsLocationSasToken}')
        'https://raw.githubusercontent.com/officedev/Office-IT-Pro-Deployment-Scripts/master/Office-ProPlus-Deployment/Deploy-OfficeClickToRun/DefaultConfiguration.xml'
        'https://raw.githubusercontent.com/officedev/Office-IT-Pro-Deployment-Scripts/master/Office-ProPlus-Deployment/Deploy-OfficeClickToRun/Office2013Setup.exe'
        'https://raw.githubusercontent.com/officedev/Office-IT-Pro-Deployment-Scripts/master/Office-ProPlus-Deployment/Deploy-OfficeClickToRun/Office2016Setup.exe'
        'https://raw.githubusercontent.com/officedev/Office-IT-Pro-Deployment-Scripts/master/Office-ProPlus-Deployment/Deploy-OfficeClickToRun/Edit-OfficeConfigurationFile.ps1'
        'https://raw.githubusercontent.com/officedev/Office-IT-Pro-Deployment-Scripts/master/Office-ProPlus-Deployment/Deploy-OfficeClickToRun/Generate-ODTConfigurationXML.ps1'
        'https://raw.githubusercontent.com/officedev/Office-IT-Pro-Deployment-Scripts/master/Office-ProPlus-Deployment/Deploy-OfficeClickToRun/Install-OfficeClickToRun.ps1'
      ]
      commandToExecute: 'powershell -ExecutionPolicy bypass -File ${setupOfficeScriptFileName} -OfficeVersion ${officeVersion}'
    }
  }
}


