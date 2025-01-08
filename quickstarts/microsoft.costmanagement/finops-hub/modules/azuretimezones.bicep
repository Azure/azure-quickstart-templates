@description('Optional. The location to use for the managed identity and deployment script to auto-start triggers. Default = (resource group location).')
param location string = resourceGroup().location

param timezoneobject object = {
  australiaeast: 'Australian Eastern Standard Time'
  australiasoutheast: 'Australian Eastern Standard Time'
  brazilsouth: 'Brasil Standard Time'
  canadacentral: 'Central Standard Time'
  canadaeast: 'Eastern Standard Time'
  centralindia: 'India Standard Time'
  centralus: 'Central Standard Time'
  eastasia: 'China Standard Time'
  eastus: 'Eastern Standard Time'
  eastus2: 'Eastern Standard Time'
  francecentral: 'Central European Time'
  germanynorth: 'Central European Time'
  germanywestcentral: 'Central European Time'
  japaneast: 'Japan Standard Time'
  japanwest: 'Japan Standard Time'
  koreacentral: 'Korea Standard Time'
  koreasouth: 'Korea Standard Time'
  northcentralus: 'Central Standard Time'
  northeurope: 'Central European Time'
  norwayeast: 'Central European Time'
  norwaywest: 'Central European Time'
  southcentralus: 'Central Standard Time'
  southindia: 'India Standard Time'
  southeastasia: 'Singapore Standard Time'
  switzerlandnorth: 'Central European Time'
  switzerlandwest: 'Central European Time'
  uksouth: 'Greenwich Mean Time'
  ukwest: 'Greenwich Mean Time'
  westcentralus: 'Central Standard Time'
  westeurope: 'Central European Time'
  westindia: 'India Standard Time'
  westus: 'Pacific Standard Time'
  westus2: 'Pacific Standard Time'
}

param utchrs string = utcNow('hh')
param utcmins string = utcNow('mm')
param utcsecs string = utcNow('ss')

var loc = toLower(replace(location, ' ', ''))

var timezone = timezoneobject[?loc] ?? 'Universal Coordinated Time'

output AzureRegion string = location

output Timezone string = timezone

output UtcHours string = utchrs

output UtcMinutes string = utcmins

output UtcSeconds string = utcsecs

