param location string = resourceGroup().location
param csadminSshKey string = 'ssh-rsa APublicSshKey2EAAAADAQABAAACAQCpXKIzGlb9fnLJmwrVPFQyntzOngz8QE4SOMHyXueVb4bO2IgSdHk8cD2LDToX3lDOUQzzWz+AiUO3iIRNJPOzZj/6aN+BJZXpi8+cdGOyaQmDyzk0T2w0mwTxXBk3DkXAw+lw13Q9SlFY+YLKsqHyKF7aXiy7RiJl4O3QUMGLKuGtmsqRFcrarp20pyH1UXQbvXUUoPU92AU4cSmx4AS8coWaDoQxWr7EA6toF0hgXsKFf/8MlkzJty0P7IhZ8KPzJg9lFNfBCUZHFEQWSb7FQBV6mFXxVcus1eCtoLEXkIDSkkYGd+edMO6t/Hc73c66M1vL9Ae6RUx2m39kZGF9bpVmcs8pZ2Hy2QukcGR8r61Jx913a32hRmk5fWpCnEo0NfE9XQJ7ibMNU97XL/QSeNZp3yzAyZqIYBkaYp8bFNjjMnVNyVdaANw2rjmxTY2XJlc0jVgucMWim8zT4YDQgKR8UuzXZBtC5uxlqhgZ8Zj+tRqgq/ZGo1MBacj89gQJjiiyFgf9hewVtdxlAEnDUHo0KI/Ro2geI+f2ylf1m0bUuPpwjO8sybJg/ZkA48LyOMbwj9wLHbiNJnPmoJROGGO/pAdvrzMlDuD/2BLf5Xmn3RkvnseS6/qCXZAfsrwlhb/LtCkWF2j+7e5EWXArhT14fGdWHi+5f09UY7ybAQ== user@Somewhere'
param ccadminRawPassword string
param myIp string = '20.49.199.4'

var roleDefinitions = {
  owner: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}
var saName = take('cclocker${replace(guid(resourceGroup().id), '-', '')}', 24)
var customData = '#cloud-config\n#\n# installs CycleCloud on the VM\n#\n\nyum_repos:\n  azure-cli:\n    baseurl: https://packages.microsoft.com/yumrepos/azure-cli\n    enabled: true\n    gpgcheck: true\n    gpgkey: https://packages.microsoft.com/keys/microsoft.asc\n    name: Azure CLI\n  cyclecloud:\n    baseurl: https://packages.microsoft.com/yumrepos/cyclecloud\n    enabled: true\n    gpgcheck: true\n    gpgkey: https://packages.microsoft.com/keys/microsoft.asc\n    name: Cycle Cloud\n\npackages:\n- java-1.8.0-openjdk-headless\n- azure-cli\n- cyclecloud8\n\nwrite_files:\n- content: |\n    [{\n        "AdType": "Application.Setting",\n        "Name": "cycleserver.installation.initial_user",\n        "Value": "ccadmin"\n    },\n    {\n        "AdType": "Application.Setting",\n        "Name": "cycleserver.installation.complete",\n        "Value": true\n    },\n    {\n        "AdType": "AuthenticatedUser",\n        "Name": "ccadmin",\n        "RawPassword": "${ccadminRawPassword}",\n        "Superuser": true\n    }] \n  owner: root:root\n  path: ./account_data.json\n  permissions: \'0644\'\n- content: |\n    {\n      "Name": "Azure",\n      "Environment": "public",\n      "AzureRMSubscriptionId": "${subscription().subscriptionId}",\n      "AzureRMUseManagedIdentity": true,\n      "Location": "westeurope",\n      "RMStorageAccount": "${saName}",\n      "RMStorageContainer": "cyclecloud"\n    }\n  owner: root:root\n  path: ./azure_data.json\n  permissions: \'0644\'\n\nruncmd:\n- sed -i --follow-symlinks "s/webServerPort=.*/webServerPort=80/g" /opt/cycle_server/config/cycle_server.properties\n- sed -i --follow-symlinks "s/webServerSslPort=.*/webServerSslPort=443/g" /opt/cycle_server/config/cycle_server.properties\n- sed -i --follow-symlinks "s/webServerEnableHttps=.*/webServerEnableHttps=true/g" /opt/cycle_server/config/cycle_server.properties\n- systemctl restart cycle_server\n- mv ./account_data.json /opt/cycle_server/config/data/\n- sleep 5\n- /opt/cycle_server/cycle_server execute "update Application.Setting set Value = false where name == \\"authorization.check_datastore_permissions\\""\n- unzip /opt/cycle_server/tools/cyclecloud-cli\n- ./cyclecloud-cli-installer/install.sh --system\n- sleep 60\n- /usr/local/bin/cyclecloud initialize --batch --url=https://localhost --verify-ssl=false --username="ccadmin" --password="${ccadminRawPassword}"\n- /usr/local/bin/cyclecloud account create -f ./azure_data.json'

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: 'cc-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          priority: 1000
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: myIp
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
      {
        name: 'HTTP'
        properties: {
          priority: 1010
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: myIp
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'HTTPS'
        properties: {
          priority: 1020
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: myIp
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: 'cc-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/22'
      ]
    }
    subnets: [
      {
        name: 'Default'
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

resource pip 'Microsoft.Network/publicIpAddresses@2020-05-01' = {
  name: 'cycleserver-pip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: 'cycleserver-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${vnet.id}/subnets/Default'
          }
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: saName
  location: location
  kind: 'Storage'
  sku: {
    name: 'Standard_LRS'
  }
}

resource mid 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'CycleCloud-MI'
  location: location
}

resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: 'cycleserver'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${mid.id}': {}
    }
  }
  properties: {
    osProfile: {
      computerName: 'CycleServer'
      adminUsername: 'csadmin'
      customData: base64(customData)
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/csadmin/.ssh/authorized_keys'
              keyData: csadminSshKey
            }
          ]
        }
      }
    }
    hardwareProfile: {
      vmSize: 'Standard_D8s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'OpenLogic'
        offer: 'CentOS'
        sku: '8_2'
        version: 'latest'
      }
      osDisk: {
        name: 'cycleserver-os'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
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

resource rbac 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id)
  properties: {
    roleDefinitionId: tenantResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.contributor)
    principalId: mid.properties.principalId
    principalType: 'ServicePrincipal'
  }
}
