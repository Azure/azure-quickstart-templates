@description('Size of virtual machine sizes')
param vmSize string = 'Standard_B2s'

@description('Username for remote access')
param remoteAccessUsername string

@description('Password for remote access')
@secure()
param remoteAccessPassword string

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
  '2016-datacenter-gensecond'
  '2016-datacenter-server-core-g2'
  '2016-datacenter-server-core-smalldisk-g2'
  '2016-datacenter-smalldisk-g2'
  '2016-datacenter-with-containers-g2'
  '2016-datacenter-zhcn-g2'
  '2019-datacenter-core-g2'
  '2019-datacenter-core-smalldisk-g2'
  '2019-datacenter-core-with-containers-g2'
  '2019-datacenter-core-with-containers-smalldisk-g2'
  '2019-datacenter-gensecond'
  '2019-datacenter-smalldisk-g2'
  '2019-datacenter-with-containers-g2'
  '2019-datacenter-with-containers-smalldisk-g2'
  '2019-datacenter-zhcn-g2'
  '2022-datacenter-azure-edition'
  '2022-datacenter-azure-edition-core'
  '2022-datacenter-azure-edition-core-smalldisk'
  '2022-datacenter-azure-edition-smalldisk'
  '2022-datacenter-core-g2'
  '2022-datacenter-core-smalldisk-g2'
  '2022-datacenter-g2'
  '2022-datacenter-smalldisk-g2'
])
param OSVersion string = '2022-datacenter-azure-edition'

@description('Secure Boot setting of the virtual machine.')
param secureBoot bool = true

@description('vTPM setting of the virtual machine.')
param vTPM bool = true

@description('Deployment location')
param location string = resourceGroup().location

@description('Intruder Detection - Signature Overrodes Id 1')
param sigOverrideParam1 string = '2024897'

@description('Intruder Detection - Signature Overrodes Id 2')
param sigOverrideParam2 string = '2024898'

var vnetAddressSpace = '10.0.0.0/16'
var workerAddressSpace = '10.0.10.0/24'
var workerPrivateIPAddress = '10.0.10.10'
var bastionAddressSpace = '10.0.20.0/24'
var firewallAddressSpace = '10.0.100.0/24'
var firewallPrivateIPAddress = '10.0.100.4'
var keyVaultName = 'fw-quick-${uniqueString(subscription().id, resourceGroup().id)}'
var keyVaultCASecretName = 'CACert'
var extensionName = 'GuestAttestation'
var extensionPublisher = 'Microsoft.Azure.Security.WindowsAttestation'
var extensionVersion = '1.0'
var maaTenantName = 'GuestAttestation'

resource CreateAndDeployCertificates 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'CreateAndDeployCertificates'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    forceUpdateTag: '2'
    azPowerShellVersion: '3.0'
    scriptContent: '# Write the config to file\n$opensslConfig=@\'\n[ req ]\ndefault_bits        = 4096\ndistinguished_name  = req_distinguished_name\nstring_mask         = utf8only\ndefault_md          = sha512\n\n[ req_distinguished_name ]\ncountryName                     = Country Name (2 letter code)\nstateOrProvinceName             = State or Province Name\nlocalityName                    = Locality Name\n0.organizationName              = Organization Name\norganizationalUnitName          = Organizational Unit Name\ncommonName                      = Common Name\nemailAddress                    = Email Address\n\n[ rootCA_ext ]\nsubjectKeyIdentifier = hash\nauthorityKeyIdentifier = keyid:always,issuer\nbasicConstraints = critical, CA:true\nkeyUsage = critical, digitalSignature, cRLSign, keyCertSign\n\n[ interCA_ext ]\nsubjectKeyIdentifier = hash\nauthorityKeyIdentifier = keyid:always,issuer\nbasicConstraints = critical, CA:true, pathlen:1\nkeyUsage = critical, digitalSignature, cRLSign, keyCertSign\n\n[ server_ext ]\nsubjectKeyIdentifier = hash\nauthorityKeyIdentifier = keyid:always,issuer\nbasicConstraints = critical, CA:false\nkeyUsage = critical, digitalSignature\nextendedKeyUsage = serverAuth\n\'@\n\nSet-Content -Path openssl.cnf -Value $opensslConfig\n\n# Create root CA\nopenssl req -x509 -new -nodes -newkey rsa:4096 -keyout rootCA.key -sha256 -days 3650 -out rootCA.crt -subj \'/C=US/ST=US/O=Self Signed/CN=Self Signed Root CA\' -config openssl.cnf -extensions rootCA_ext\n\n# Create intermediate CA request\nopenssl req -new -nodes -newkey rsa:4096 -keyout interCA.key -sha256 -out interCA.csr -subj \'/C=US/ST=US/O=Self Signed/CN=Self Signed Intermediate CA\'\n\n# Sign on the intermediate CA\nopenssl x509 -req -in interCA.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out interCA.crt -days 3650 -sha256 -extfile openssl.cnf -extensions interCA_ext\n\n# Export the intermediate CA into PFX\nopenssl pkcs12 -export -out interCA.pfx -inkey interCA.key -in interCA.crt -password \'pass:\'\n\n# Convert the PFX and public key into base64\n$interCa = [Convert]::ToBase64String((Get-Content -Path interCA.pfx -AsByteStream -Raw))\n$rootCa = [Convert]::ToBase64String((Get-Content -Path rootCA.crt -AsByteStream -Raw))\n\n# Assign outputs\n$DeploymentScriptOutputs = @{}\n$DeploymentScriptOutputs[\'interca\'] = $interCa\n$DeploymentScriptOutputs[\'rootca\'] = $rootCa\n'
    timeout: 'PT5M'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

resource DemoIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'DemoIdentity'
  location: location
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        objectId: DemoIdentity.properties.principalId
        tenantId: DemoIdentity.properties.tenantId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource keyVaultName_keyVaultCASecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name: keyVaultCASecretName
  location: location
  properties: {
    value: CreateAndDeployCertificates.properties.outputs.interca
  }
}

resource WorkerRoute 'Microsoft.Network/routeTables@2020-05-01' = {
  name: 'WorkerRoute'
  location: location
  properties: {
    routes: [
      {
        name: 'WorkerRouteFirewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIPAddress
        }
      }
    ]
    disableBgpRoutePropagation: false
  }
}

resource DemoVnet 'Microsoft.Network/virtualNetworks@2020-07-01' = {
  name: 'DemoVnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [
      {
        name: 'WorkerSubnet'
        properties: {
          addressPrefix: workerAddressSpace
          routeTable: {
            id: WorkerRoute.id
          }
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: bastionAddressSpace
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: firewallAddressSpace
        }
      }
    ]
  }
}

resource WorkerNIC 'Microsoft.Network/networkInterfaces@2020-07-01' = {
  name: 'WorkerNIC'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'WorkerIPConfiguration'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'DemoVnet', 'WorkerSubnet')
          }
          privateIPAllocationMethod: 'Static'
          privateIPAddress: workerPrivateIPAddress
        }
      }
    ]
  }
  dependsOn: [
    DemoVnet
  ]
}

resource WorkerVM 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: 'WorkerVM'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: 'WorkerVM'
      adminUsername: remoteAccessUsername
      adminPassword: remoteAccessPassword
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: secureBoot
        vTpmEnabled: vTPM
      }
      securityType: 'TrustedLaunch'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: WorkerNIC.id
        }
      ]
    }
  }
}

resource WorkerVM_extension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if (vTPM && secureBoot) {
  parent: WorkerVM
  name: extensionName
  location: location
  properties: {
    publisher: extensionPublisher
    type: extensionName
    typeHandlerVersion: extensionVersion
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: ''
          maaTenantName: maaTenantName
        }
        AscSettings: {
          ascReportingEndpoint: ''
          ascReportingFrequency: ''
        }
        useCustomToken: 'false'
        disableAlerts: 'false'
      }
    }
  }
}

resource WorkerVM_Bootstrap 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  parent: WorkerVM
  name: 'Bootstrap'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.7'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'echo ${CreateAndDeployCertificates.properties.outputs.rootca} > c:\\root.pem.base64 && powershell "Set-Content -Path c:\\root.pem -Value ([Text.Encoding]::UTF8.GetString([convert]::FromBase64String((Get-Content -Path c:\\root.pem.base64))))" && certutil -addstore root c:\\root.pem'
    }
  }
}

resource BastionPublicIP 'Microsoft.Network/publicIpAddresses@2020-07-01' = {
  name: 'BastionPublicIP'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource DemoBastion 'Microsoft.Network/bastionHosts@2020-07-01' = {
  name: 'DemoBastion'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'BastionIpConfiguration'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'DemoVnet', 'AzureBastionSubnet')
          }
          publicIPAddress: {
            id: BastionPublicIP.id
          }
        }
      }
    ]
  }
  dependsOn: [
    DemoVnet

  ]
}

resource FirewallPublicIP 'Microsoft.Network/publicIpAddresses@2020-07-01' = {
  name: 'FirewallPublicIP'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource DemoFirewallPolicy 'Microsoft.Network/firewallPolicies@2020-07-01' = {
  name: 'DemoFirewallPolicy'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${DemoIdentity.id}': {}
    }
  }
  properties: {
    sku: {
      tier: 'Premium'
    }
    transportSecurity: {
      certificateAuthority: {
        name: keyVaultCASecretName
        keyVaultSecretId: '${keyVault.properties.vaultUri}secrets/${keyVaultCASecretName}/'
      }
    }
    intrusionDetection: {
      mode: 'Alert'
      configuration: {
        signatureOverrides: [
          {
            id: sigOverrideParam1
            mode: 'Deny'
          }
          {
            id: sigOverrideParam2
            mode: 'Alert'
          }
        ]
        bypassTrafficSettings: [
          {
            name: 'SecretBypass'
            protocol: 'TCP'
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: [
              '1.1.1.1'
            ]
            destinationPorts: [
              '80'
            ]
          }
        ]
      }
    }
  }
  dependsOn: [
    keyVaultName_keyVaultCASecret

  ]
}

resource DemoFirewallPolicy_PolicyRules 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-07-01' = {
  parent: DemoFirewallPolicy
  name: 'PolicyRules'
  location: location
  properties: {
    priority: 200
    ruleCollections: [
      {
        name: 'AllowWeb'
        priority: 101
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'AllowAzure'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            targetFqdns: [
              '*azure.com'
              '*microsoft.com'
            ]
            sourceAddresses: [
              '*'
            ]
            terminateTLS: true
          }
          {
            ruleType: 'ApplicationRule'
            name: 'AllowNews'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            webCategories: [
              'business'
              'webbasedemail'
            ]
            sourceAddresses: [
              '*'
            ]
            terminateTLS: true
          }
        ]
      }
      {
        name: 'BlockPage'
        priority: 100
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Deny'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'BlockAzureEvents'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            targetUrls: [
              'azure.microsoft.com/en-us/community/events'
              'azure.microsoft.com/en-us/community/events/*'
            ]
            sourceAddresses: [
              '*'
            ]
            terminateTLS: true
          }
        ]
      }
    ]
  }
}

resource DemoFirewall 'Microsoft.Network/azureFirewalls@2020-07-01' = {
  name: 'DemoFirewall'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'FirewallIPConfiguration'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'DemoVnet', 'AzureFirewallSubnet')
          }
          publicIPAddress: {
            id: FirewallPublicIP.id
          }
        }
      }
    ]
    firewallPolicy: {
      id: DemoFirewallPolicy.id
    }
    sku: {
      name: 'AZFW_VNet'
      tier: 'Premium'
    }
  }
  dependsOn: [
    DemoVnet

    DemoFirewallPolicy_PolicyRules
  ]
}
