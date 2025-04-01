@description('Optional. The location to use for the managed identity and deployment script to auto-start triggers. Default = (resource group location).')
param location string = resourceGroup().location

param timezoneobject object = {
  australiaeast: 'AUS Eastern Standard Time'
  australiacentral: 'AUS Eastern Standard Time'
  australiacentral2: 'AUS Eastern Standard Time'
  australiasoutheast: 'AUS Eastern Standard Time'
  brazilsouth: 'E. South America Standard Time'
  canadacentral: 'Central Standard Time'
  canadaeast: 'Eastern Standard Time'
  centralindia: 'India Standard Time'
  centralus: 'Central Standard Time'
  eastasia: 'China Standard Time'
  eastus: 'Eastern Standard Time'
  eastus2: 'Eastern Standard Time'
  francecentral: 'W. Europe Standard Time'
  germanynorth: 'W. Europe Standard Time'
  germanywestcentral: 'W. Europe Standard Time'
  japaneast: 'Japan Standard Time'
  japanwest: 'Japan Standard Time'
  koreacentral: 'Korea Standard Time'
  koreasouth: 'Korea Standard Time'
  northcentralus: 'Central Standard Time'
  northeurope: 'GMT Standard Time'
  norwayeast: 'W. Europe Standard Time'
  norwaywest: 'W. Europe Standard Time'
  southcentralus: 'Central Standard Time'
  southindia: 'India Standard Time'
  southeastasia: 'Singapore Standard Time'
  switzerlandnorth: 'W. Europe Standard Time'
  switzerlandwest: 'W. Europe Standard Time'
  uksouth: 'GMT Standard Time'
  ukwest: 'GMT Standard Time'
  westcentralus: 'Central Standard Time'
  westeurope: 'W. Europe Standard Time'
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

