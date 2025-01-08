@description('User name for the Virtual Machine')
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

@description('Location for all resources')
param location string = resourceGroup().location

@description('User name for the JBoss EAP Manager')
param jbossEAPUserName string

@description('Password for the JBoss EAP Manager')
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

@description('Password for Red Hat subscription Manager')
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

@description('The base URI where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated.')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated.')
@secure()
param _artifactsLocationSasToken string = ''

@description('Select the Replication Strategy for the Storage account')
@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageReplication string = 'Standard_LRS'

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

@description('Number of VMs to deploy')
param numberOfInstances int = 2

var containerName = 'eapblobcontainer'
var loadBalancersName = 'jbosseap-lb'
var vmNameMap = {
  BYOS: 'jbosseap-byos-server'
  PAYG: 'jbosseap-payg-server'
}
var vmName = vmNameMap[rhelOSLicenseType]
var availabilitySetName = 'jbosseap-as'
var skuName = 'Aligned'
var nicName = 'jbosseap-server-nic'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'jbosseap-server-subnet'
var subnetPrefix = '10.0.0.0/24'
var virtualNetworkName = 'jbosseap-vnet'
var backendPoolName = 'jbosseap-server'
var frontendName = 'LoadBalancerFrontEnd'
var healthProbeEAP = 'eap-jboss-health'
var healthProbeAdmin = 'eap-admin-health'
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
var guidName = 'pid-9c48eb09-c7f5-4cc1-9ee5-033abb031ff0'
var storageAccountName = 'jbosstrg${uniqueString(resourceGroup().id)}'
var scriptFolder = 'scripts'
var fileToBeDownloaded = 'eap-session-replication.war'
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
    QuickstartName: 'JBoss EAP on RHEL (clustered, multi-VM)'
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: virtualNetworkName
  location: location
  tags: {
    QuickstartName: 'JBoss EAP on RHEL (clustered, multi-VM)'
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

resource nic 'Microsoft.Network/networkInterfaces@2022-07-01' = [for i in range(0, numberOfInstances): {
  name: '${nicName}${i}'
  location: location
  tags: {
    QuickstartName: 'JBoss EAP on RHEL (clustered, multi-VM)'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
          loadBalancerBackendAddressPools: [
            {
              id: loadBalancer.properties.backendAddressPools[0].id
            }
          ]
        }
      }
    ]
  }
}]

resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = [for i in range(0, numberOfInstances): {
  name: '${vmName}${i}'
  location: location
  plan: ((rhelOSLicenseType == 'PAYG') ? json('null') : plan)
  tags: {
    QuickstartName: 'JBoss EAP on RHEL (clustered, multi-VM)'
  }
  properties: {
    availabilitySet: {
      id: availabilitySet.id
    }
    hardwareProfile: {
      vmSize: vmSize
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic[i].id
        }
      ]
    }
    osProfile: {
      computerName: '${vmName}${i}'
      adminUsername: adminUsername
      adminPassword: adminPasswordOrSSHKey
      linuxConfiguration: ((authenticationType == 'password') ? json('null') : linuxConfiguration)
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
      }
      imageReference: imageReference
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: bootStorageAccount.properties.primaryEndpoints.blob
      }
    }
  }
  dependsOn: [
    nic
    storageAccount
  ]
}]

resource setupJbossApp 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [for i in range(0, numberOfInstances): {
  name: '${vmName}${i}/jbosseap-setup-extension-${i}'
  location: location
  tags: {
    QuickstartName: 'JBoss EAP on RHEL (clustered, multi-VM)'
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
      commandToExecute: 'sh jbosseap-setup-redhat.sh ${scriptArgs} ${jbossEAPUserName} \'${jbossEAPPassword}\' ${rhelOSLicenseType} ${rhsmUserName} \'${rhsmPassword}\' ${rhsmPoolEAP} ${storageAccountName} ${containerName} ${base64(listKeys(storageAccount.id, '2021-02-01').keys[0].value)} ${javaVersion} ${rhsmPoolRHEL}'
    }
  }
}]

resource loadBalancer 'Microsoft.Network/loadBalancers@2022-07-01' = {
  name: loadBalancersName
  location: location
  sku: {
    name: 'Basic'
  }
  tags: {
    QuickstartName: 'JBoss EAP on RHEL (clustered, multi-VM)'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: frontendName
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv4'
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: backendPoolName
      }
    ]
    loadBalancingRules: [
      {
        name: '${loadBalancersName}-rule1'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancersName, frontendName)
          }
          frontendPort: 80
          backendPort: 8080
          enableFloatingIP: false
          idleTimeoutInMinutes: 5
          protocol: 'Tcp'
          enableTcpReset: false
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancersName, backendPoolName)
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancersName, healthProbeEAP)
          }
        }
      }
      {
        name: '${loadBalancersName}-rule2'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancersName, frontendName)
          }
          frontendPort: 9990
          backendPort: 9990
          enableFloatingIP: false
          idleTimeoutInMinutes: 5
          protocol: 'Tcp'
          enableTcpReset: false
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancersName, backendPoolName)
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancersName, healthProbeAdmin)
          }
        }
      }
    ]
    probes: [
      {
        name: healthProbeEAP
        properties: {
          protocol: 'Tcp'
          port: 8080
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
      {
        name: healthProbeAdmin
        properties: {
          protocol: 'Tcp'
          port: 9990
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
}

resource availabilitySet 'Microsoft.Compute/availabilitySets@2022-08-01' = {
  name: availabilitySetName
  location: location
  sku: {
    name: skuName
  }
  tags: {
    QuickstartName: 'JBoss EAP on RHEL (clustered, multi-VM)'
  }
  properties: {
    platformUpdateDomainCount: 2
    platformFaultDomainCount: 2
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageReplication
  }
  kind: 'Storage'
  tags: {
    QuickstartName: 'JBoss EAP on RHEL (clustered, multi-VM)'
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '${storageAccountName}/default/${containerName}'
  dependsOn: [
    storageAccount
  ]
}

output appURL string = uri('http://${loadBalancer.properties.frontendIPConfigurations[0].properties.privateIPAddress}', '/eap-session-replication/')
