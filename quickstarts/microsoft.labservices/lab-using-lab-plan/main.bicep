@description('The location in which the lab resource should be deployed.')
param location string = resourceGroup().location

@description('The name of the lab.  Lab must be unique within the resource group.')
param labName string = 'lab-${uniqueString(resourceGroup().id)}'

@description('Lab Virtual Machine Administrator User Name')
param adminUsername string

@description('Lab Virtual Machine Administrator Password')
@secure()
param adminPassword string

@description('Lab Plan Resource Id')
param labPlanId string

resource labResource 'Microsoft.LabServices/labs@2021-11-15-preview' = {
  name: labName
  location: location
  tags: {}
  properties: {
    title: labName
    labPlanId: labPlanId
    autoShutdownProfile: {
      shutdownOnDisconnect: 'Enabled'
      shutdownWhenNotConnected: 'Enabled'
      shutdownOnIdle: 'LowUsage'
      disconnectDelay: 'P0D'
      noConnectDelay: 'PT15M'
      idleDelay: 'PT15M'
    }
    connectionProfile: {
      webSshAccess: 'None'
      webRdpAccess: 'None'
      clientSshAccess: 'None'
      clientRdpAccess: 'Public'
    }
    virtualMachineProfile: {
      createOption: 'TemplateVM'
      imageReference: {
        offer: 'windows-11'
        publisher: 'microsoftwindowsdesktop'
        sku: 'win11-21h2-pro'
        version: 'latest'
      }
      sku: {
        name: 'Classic_Fsv2_2_4GB_128_S_SSD'
        capacity: 0
      }
      additionalCapabilities: {
        installGpuDrivers: 'Disabled'
      }
      usageQuota: 'PT10H'
      useSharedPassword: 'Enabled'
      adminUser: {
        username: adminUsername
        password: adminPassword
      }
    }
    securityProfile: {
      openAccess: 'Disabled'
    }
  }
}
