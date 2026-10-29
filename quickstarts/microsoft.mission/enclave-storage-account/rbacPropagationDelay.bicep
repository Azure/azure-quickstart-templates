targetScope = 'resourceGroup'

@description('Dummy parameter to create a dependency chain')
param trigger string = ''

output done string = trigger
