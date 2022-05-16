@description('The name of the shared query.')
param queryName string = 'Count VMs by OS'

@description('The Azure Resource Graph query to be saved to the shared query.')
param queryCode string = 'Resources | where type =~ \'Microsoft.Compute/virtualMachines\' | summarize count() by tostring(properties.storageProfile.osDisk.osType)'

@description('The description of the saved Azure Resource Graph query.')
param queryDescription string = 'This shared query counts all virtual machine resources and summarizes by the OS type.'

resource query 'Microsoft.ResourceGraph/queries@2018-09-01-preview' = {
  name: queryName
  location: 'global'
  properties: {
    query: queryCode
    description: queryDescription
  }
}
