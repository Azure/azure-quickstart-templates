using 'main.bicep'

param newVirtualNetwork = true
param virtualNetworkRG = 'GEN-VNET-RESOURCEGROUP-NAME'
param virtualNetworkName = 'GEN-VNET-NAME'
param virtualNetworkAddressSpace = '10.0.0.0/16'
param subnetName = 'GEN-VNET-SUBNET1-NAME'
param subnetAddressPrefix = '10.0.0.0/24'
param hostPoolName = 'testdemo-hostPool'
param applicationGroupName = 'testdemo-apgroup'
param workspaceName = 'testdemo-workspace'

param virtualMachines = [
  {
    name: 'azurevm'
    licenseType: 'Windows_Client'
    vmSize: 'Standard_D2s_v3'
  }
]
param adminUsername = 'azureuser'
param adminPassword = 'GEN-PASSWORD'
param artifactsLocation = 'https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02774.414.zip'
