@description('The location in which the resources should be deployed.')
param location = resourceGroup().location // ERROR: Missing type
