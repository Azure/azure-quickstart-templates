@description('Linux VM user account name')
param adminUsername string

@description('Type of authentication to use on the Virtual Machine')
@allowed([
  'password'
  'sshPublicKey'
])
param authenticationType string = 'password'

@description('Password or SSH key for the Virtual Machine')
@secure()
param adminPasswordOrSSHKey string

@description('User name for JBoss EAP Manager')
param jbossEAPUserName string

@description('Password for JBoss EAP Manager')
@minLength(12)
@secure()
param jbossEAPPassword string

@description('Select the of RHEL OS License Type for deploying your Virtual Machine. Please read through the guide and make sure you follow the steps mentioned under section \'Licenses, Subscriptions and Costs\' if you are selecting BYOS')
@allowed([
  'PAYG'
  'BYOS'
])
param rhelOSLicenseType string = 'PAYG'

@description('User name for Red Hat subscription Manager')
param rhsmUserName string

@description('Password for Red Hat subscription  Manager')
@secure()
param rhsmPassword string

@description('Red Hat Subscription Manager Pool ID (Should have EAP entitlement)')
param rhsmPoolEAP string

@description('Red Hat Subscription Manager Pool ID (Should have RHEL entitlement). Mandartory if you select the BYOS RHEL OS License Type')
param rhsmPoolRHEL string = ''

@description('Select the Java version to be installed')
@allowed([
  'JAVA_8'
  'JAVA_11'
])
param javaVersion string = 'JAVA_8'

@description('The base URI where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated')
@secure()
param _artifactsLocationSasToken string = ''

@description('Location for all resources')
param location string = resourceGroup().location

@description('The size of the Virtual Machine')
@allowed([
  'Standard_D2s_v3'
  'Standard_D4s_v3'
  'Standard_D8s_v3'
  'Standard_E2S_v3'
  'Standard_E4S_v3'
  'Standard_E8S_v3'
  'Standard_F2S_v2'
  'Standard_F4S_v2'
  'Standard_F8S_v2'
])
param vmSize string = 'Standard_D2s_v3'

var nicName = 'jbosseap-server-nic'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'jbosseap-server-subnet'
var subnetPrefix = '10.0.0.0/24'
var vmNameMap = {
  BYOS: 'jbosseap-byos-server'
  PAYG: 'jbosseap-payg-server'
}
var vmName = vmNameMap[rhelOSLicenseType]
var virtualNetworkName = 'jbosseap-vnet'
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
var bootStorageAccountName = 'bootstrg${uniqueString(resourceGroup().id)}'
var storageAccountType = 'Standard_LRS'
var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrSSHKey
      }
    ]
  }
}
var imageSku = ((rhelOSLicenseType == 'PAYG') ? '8_6' : 'rhel-lvm86')
var offerMap = {
  BYOS: 'rhel-byos'
  PAYG: 'rhel'
}
var imageOffer = offerMap[rhelOSLicenseType]
var imageReference = {
  publisher: 'redhat'
  offer: imageOffer
  sku: imageSku
  version: 'latest'
}
var plan = {
  name: imageSku
  publisher: 'redhat'
  product: 'rhel-byos'
}
var guidName = 'pid-9a72dd7b-3568-469b-a84f-d953207f2a1a'
var scriptFolder = 'scripts'
var fileToBeDownloaded = 'JBoss-EAP_on_Azure.war'
var scriptArgs = '-a ${uri(_artifactsLocation, '.')} -t "${_artifactsLocationSasToken}" -p ${scriptFolder} -f ${fileToBeDownloaded}'

module guid './nested_guid.bicep' = {
  name: guidName
  params: {
  }
}

resource bootStorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: bootStorageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
  tags: {
    QuickstartName: 'JBoss EAP on RHEL (stand-alone VM)'
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: virtualNetworkName
  location: location
  tags: {
    QuickstartName: 'JBoss EAP on RHEL (stand-alone VM)'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: nicName
  location: location
  tags: {
    QuickstartName: 'JBoss EAP on RHEL (stand-alone VM)'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork
  ]
}

resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmName
  location: location
  plan: ((rhelOSLicenseType == 'PAYG') ? json('null') : plan)
  tags: {
    QuickstartName: 'JBoss EAP on RHEL (stand-alone VM)'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrSSHKey
      linuxConfiguration: ((authenticationType == 'password') ? json('null') : linuxConfiguration)
    }
    storageProfile: {
      osDisk: {
        name: '${vmName}_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
      imageReference: imageReference
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: bootStorageAccount.properties.primaryEndpoints.blob
      }
    }
  }
}

resource setupJbossApp 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  parent: vm
  name: 'jbosseap-setup-extension'
  location: location
  tags: {
    QuickstartName: 'JBoss EAP on RHEL (stand-alone VM)'
  }
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        uri(_artifactsLocation, 'scripts/jbosseap-setup-redhat.sh${_artifactsLocationSasToken}')
      ]
    }
    protectedSettings: {
      commandToExecute: 'sh jbosseap-setup-redhat.sh ${scriptArgs} ${jbossEAPUserName} \'${jbossEAPPassword}\' ${rhsmUserName} \'${rhsmPassword}\' ${rhelOSLicenseType} ${rhsmPoolEAP} ${javaVersion} ${rhsmPoolRHEL}'
    }
  }
}

output vm_Private_IP_Address string = nic.properties.ipConfigurations[0].properties.privateIPAddress
output appURL string = uri('http://${nic.properties.ipConfigurations[0].properties.privateIPAddress}', ':8080/JBoss-EAP_on_Azure/')
output adminConsole string = uri('http://${nic.properties.ipConfigurations[0].properties.privateIPAddress}', ':9990')
