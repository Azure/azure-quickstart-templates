param location string
param userAssignedIdentityId string
param networkManagerName string
param configurationId string
param deploymentScriptName string
@allowed([
  'Connectivity'
])
param configType string

// the commit action is idempotent, so re-running the deployment will not cause any issues
@description('Create a Deployment Script resource to perform the commit/deployment of the Network Manager connectivity configuration.')
resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: deploymentScriptName
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  properties: {
    azPowerShellVersion: '8.3'
    retentionInterval: 'PT1H'
    timeout: 'PT1H'
    arguments: '-networkManagerName "${networkManagerName}" -targetLocations ${location} -configIds ${configurationId} -subscriptionId ${subscription().subscriptionId} -configType ${configType} -resourceGroupName ${resourceGroup().name}'
    scriptContent: '''
    param (
      # AVNM subscription id
      [parameter(mandatory=$true)][string]$subscriptionId,

      # AVNM resource name
      [parameter(mandatory=$true)][string]$networkManagerName,

      # string with comma-separated list of config ids to deploy. ids must be of the same config type
      [parameter(mandatory=$true)][string[]]$configIds,

      # string with comma-separated list of deployment target regions
      [parameter(mandatory=$true)][string[]]$targetLocations,

      # configuration type to deploy. must be either connecticity or securityadmin
      [parameter(mandatory=$true)][ValidateSet('Connectivity','SecurityAdmin','Routing')][string]$configType,

      # AVNM resource group name
      [parameter(mandatory=$true)][string]$resourceGroupName
    )
  
    $null = Login-AzAccount -Identity -Subscription $subscriptionId
  
    [System.Collections.Generic.List[string]]$configIdList = @()  
    $configIdList.addRange($configIds) 
    [System.Collections.Generic.List[string]]$targetLocationList = @() # target locations for deployment
    $targetLocationList.addRange($targetLocations)     
    
    $deployment = @{
        Name = $networkManagerName
        ResourceGroupName = $resourceGroupName
        ConfigurationId = $configIdList
        TargetLocation = $targetLocationList
        CommitType = $configType
    }
  
    try {
      Deploy-AzNetworkManagerCommit @deployment -ErrorAction Stop
    }
    catch {
      Write-Error "Deployment failed with error: $_"
      throw "Deployment failed with error: $_"
    }
    '''
    }
}
