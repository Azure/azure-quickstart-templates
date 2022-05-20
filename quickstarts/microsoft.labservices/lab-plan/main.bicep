@description('The location in which the lab plan resource should be deployed.')
param location string = resourceGroup().location

@description('The name of the lab plan.  Lab plan must be unique within the resource group.')
param labPlanName string = 'lp-${uniqueString(resourceGroup().id)}'

@description('Regions labs that use this lab plan may be created in.  At least one region must be specified.')
@minLength(1)
param labCreationAllowedRegions array = [
  resourceGroup().location
]

resource labPlanResource 'Microsoft.LabServices/labPlans@2021-11-15-preview' = {
  name: labPlanName
  location: location
  tags: {}
  properties: {
    allowedRegions: labCreationAllowedRegions
    defaultAutoShutdownProfile: {
      shutdownOnIdle: 'LowUsage'
      idleDelay: 'PT15M'
      shutdownOnDisconnect: 'Enabled'
      disconnectDelay: 'PT0S'
      shutdownWhenNotConnected: 'Enabled'
      noConnectDelay: 'PT15M'
    }
  }
}
