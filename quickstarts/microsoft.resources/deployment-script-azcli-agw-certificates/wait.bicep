@minValue(1)
@maxValue(180)
param waitSeconds int

@description('The location to deploy the resources to')
param location string = resourceGroup().location

resource deployDelay 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'DeployDelay'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    retentionInterval: 'PT1H'
    azPowerShellVersion: '6.4'
    cleanupPreference: 'OnSuccess'
    environmentVariables: [
      {
        name: 'waitSeconds'
        value: '${waitSeconds}'
      }
    ]
    scriptContent: 'write-output "Sleeping for $Env:waitSeconds"; start-sleep -Seconds $Env:waitSeconds'
  }
}
