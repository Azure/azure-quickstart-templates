param location string
param existingVirtualMachineNames array
param sqlServerLicenseType string
param existingVmResourceGroup string
param groupResourceId string

@secure()
param domainAccountPassword string

@secure()
param sqlServicePassword string

resource existingVirtualMachineNames_resource 'Microsoft.SqlVirtualMachine/SqlVirtualMachines@2017-03-01-preview' = [for item in existingVirtualMachineNames: {
  name: trim(item)
  location: location
  properties: {
    virtualMachineResourceId: resourceId(existingVmResourceGroup, 'Microsoft.Compute/virtualMachines', trim(item))
    sqlServerLicenseType: sqlServerLicenseType
    sqlVirtualMachineGroupResourceId: groupResourceId
    wsfcDomainCredentials: {
      clusterBootstrapAccountPassword: domainAccountPassword
      clusterOperatorAccountPassword: domainAccountPassword
      sqlServiceAccountPassword: sqlServicePassword
    }
  }
}]
