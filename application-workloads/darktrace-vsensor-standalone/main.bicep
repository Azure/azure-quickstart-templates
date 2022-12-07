@description('Location for all resources. The default is the Resource Group location.')
param location string = resourceGroup().location

@description('Name of the Virtual Network Resource Group.')
param virtualNetworkResourceGroupName string

@description('Name of the Virtual Network, should be in the above Location.')
param virtualNetworkName string

@description('Name of the Subnet in the Virtual Network.')
param subnet1Name string

@description('Name for the Network Security Group that the template will create. Note that a pre-existing Network Security Group with the same name will be replaced.')
param networkSecurityGroupName string

@description('Provide an address range using CIDR notation (e.g. 10.1.0.0/24), or an IP address (e.g. 192.168.99.21) for Management access via ssh (port 22/TCP). You can also provide a comma-separated list of IP addresses and/or address ranges (a valid comma-separated list is 10.1.0.4,10.2.1.0/24). To allow access from any IP you can use 0.0.0.0/0.')
param MgmtSourceAddressOrRange string

@description('The name of the vSensor.')
param vsensorName string

@description('Number of vSensors to be deployed, max is 4.')
@minValue(1)
@maxValue(4)
param numberOfVsensors int = 1

@description('The vSensor disk size in GB between 30 and 1024. Check the Darktrace customer portal for more information.')
@minValue(30)
@maxValue(1024)
param diskSize int = 30

@description('The VM size. Check the Darktrace customer portal for more information about the vSensor Virtual Hardware requirements.')
param virtualMachineSize string = 'Standard_D2s_v3'

@description('Username to be created when the vSensor is spun up. Note that password authentication over ssh for newly created VMs is disabled.')
param adminUsername string

@description('Public key for the adminUsername user to ssh the vSensor.')
param adminPublicKey string = ''

@description('The FQDN or the IP of the Darktrace master instance (virtual/physical).')
param applianceHostName string

@description('Darktrace master instance connection port.')
param appliancePort int = 443

@description('Darktrace Update Key needed to install the vSensor package. Contact your Darktrace representative for more information.')
@secure()
param updateKey string

@description('The push token that vSensor will use to connect and register on the Darktrace master instance. Should be generated on the Darktrace master instance.')
@secure()
param pushToken string

@description('TThe osSensor HMAC Token.')
@secure()
param osSensorHMACToken string

var varLocation = location
var nsgId = networkSecurityGroup.id
var nsgSourceAddressPrefix = split(varMgmtSourceAddressOrRange, ',')
var varMgmtSourceAddressOrRange = replace(MgmtSourceAddressOrRange, ' ', '')
var updkey = updateKey
var pusht = pushToken
var oshmac = osSensorHMACToken
var mastername = applianceHostName
var masterport = appliancePort

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: networkSecurityGroupName
  location: varLocation
  properties: {
    securityRules: [
      {
        name: 'AllowMgmtInPorts22'
        properties: {
          description: 'Allow Inbound traffic to TCP ports 22 from customer selected IPs/Ranges.'
          direction: 'Inbound'
          priority: 1001
          access: 'Allow'
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRanges: [
            '22'
          ]
          sourceAddressPrefixes: nsgSourceAddressPrefix
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowVnetInPorts80_443'
        properties: {
          description: 'Allow Inbound traffic to TCP ports 80 and 443 from all VMs in the Vnet.'
          direction: 'Inbound'
          priority: 1011
          access: 'Allow'
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRanges: [
            '80'
            '443'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'DenyAllIn'
        properties: {
          description: 'Deny all Inbound traffic.'
          direction: 'Inbound'
          priority: 1021
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' = [for i in range(0, numberOfVsensors): {
  name: '${vsensorName}-${(i + 1)}-nic'
  location: varLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId(virtualNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets/', virtualNetworkName, subnet1Name)
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    enableAcceleratedNetworking: true
    networkSecurityGroup: {
      id: nsgId
    }
  }
}]

resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = [for i in range(0, numberOfVsensors): {
  name: '${vsensorName}-${(i + 1)}'
  location: varLocation
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        diskSizeGB: int(diskSize)
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'delete'
      }
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts-gen2'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${vsensorName}-${(i + 1)}-nic')
          properties: {
            deleteOption: 'delete'
          }
        }
      ]
    }
    osProfile: {
      computerName: vsensorName
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminPublicKey
            }
          ]
        }
        patchSettings: {
          patchMode: 'ImageDefault'
        }
      }
      customData: base64('#!/bin/bash\nbash <(wget https://packages.darktrace.com/install -O -) --updateKey "${updkey}"\n sleep 5\n/usr/sbin/set_pushtoken.sh "${pusht}" ${mastername}:${masterport}\nsleep 5\nset_ossensor_hmac.sh "${oshmac}"')
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
  dependsOn: [
    nic
  ]
}]

output allowedManagementIPsAndRanges array = nsgSourceAddressPrefix
